% seqMemTask_Curricula_ConfEntropy_anal.m
% write by XR @ August 19 2026

% ---------- Description ----------
% For every sequential retrieval response (content report & position
% report, marginal-report trials only) this script tests whether a
% trajectory-derived confidence metric — interClickTime, selSpeed,
% dwellTime — exactly as defined in
% seqMemTask_Curricula_Traj_anal.m (analyzeChoiceHesitation) — correlates
% with the Shannon entropy of the model's predicted choice-probability
% distribution for that same response (see
% SeqMem_featureCompetition_update_v3_ChoiceProb.m, derived from the
% fitted featureCompetitionRW_update_v3 model / SeqMem_featureCompetition_update_v3.m).
%
% Sequential position "k" (1..nTrans) is shared between the two data
% sources: it is both the click-order index used throughout
% analyzeChoiceHesitation() and the retrieval-step index "ic"/"ip" used
% inside the model's per-trial reporting loop, so mouse_con(iRep).*(k) and
% H_con(iT, k) refer to the same response once trial iT is mapped to the
% matching marginal-report trial iRep (see trialIdx_marg below).
%
% Correct and incorrect responses are analyzed separately, mirroring the
% correct/incorrect split used throughout seqMemTask_Curricula_Traj_anal.m
% (e.g. Figs 10-27 there). Two levels of correlation are computed:
%   (1) within-participant — across all individual (trial x position)
%       responses for that participant
%   (2) between-participant — on each participant's response-averaged
%       confidence metric and response-averaged entropy
%
% Model scope: the featureCompetitionRW_update_v3 model is fit to the
% marginal (content-only / position-only) reports, so only 'con' (content)
% and 'loc' (location) report types have a matching model-predicted choice
% probability. The 'both' (full/reconstruction) report type analyzed in
% seqMemTask_Curricula_Traj_anal.m has no counterpart here and is omitted.

clear
clc

%% ---------- paths ----------
addpath(genpath('Aging-SeqMemTask/'));
addpath('fdr_bh');

%% ---------- task parameters ----------
folder     = '/Users/ren/Projects-NeuroCode/MyExperiment/Aging-SeqMemTask';
bhvDataDir = [folder, '/AgingReplay-OnlineData'];
CLdata_folder   = [bhvDataDir, '/CurriculumPaper-Data/'];
CLscript_folder = [folder, '/AgingStudy-Curriculum/BehaviorAnal/'];

nSes    = 8 * 2;
nImgSeq = 2;
nPosSeq = 2;
nPos    = 8;
nImg    = 8;
nTrans  = 5;
nDtr    = 1;
nEpi    = nImgSeq * nPosSeq * nSes; % 64

expList  = {'interleaved', 'contentBlocked', 'positionBlocked'};
nCond    = length(expList);
nGroup   = 2; % 1-younger, 2-older
grpNames = {'younger', 'older'};
grpLabels_age = {'YA', 'OA'};

%% ---------- model settings (must match the cached fits from seqMemTask_modelPred_main.m) ----------
Midx        = 'featureCompetitionRW_update_v3';
fitWord     = 'allLearning-marginalRep';
bindingDirec = '';
optimzerIdx  = 0; % fminsearchbnd (matches how the cached fits were produced)
refit = 0;       % 0 => load cached parameter estimates, do not refit
nFit  = 100;

%% ---------- image similarity matrix (needed only to reproduce the trial-encoding
%  bookkeeping identically to how the cached fits were built; the v3 model
%  itself assumes no image confusion) ----------
imgNameList = {'car', 'castle', 'cat', 'cream', 'female', 'hat', 'key', 'sunflower'};
similaritySource = 'CLIP';
confMat_dir = [CLscript_folder, similaritySource, '_results/'];
confMat     = load([confMat_dir, similaritySource, '_visual_similarity.mat']);
conSimMat   = confMat.clipSimMat;

%% ---------- content-report stimulus display positions (constant across subjects/trials) ----------
imgSize_js      = 0.15;
imgStart        = -imgSize_js * nTrans / 2;
imgEnd          =  imgSize_js * nTrans / 2;
iX_vec          = 0 : (nTrans + nDtr - 1);
imgDispX_global = (imgStart - imgSize_js) + ...
                  (imgEnd + imgSize_js - (imgStart - imgSize_js)) / nTrans .* iX_vec;
imgDispY_global = repmat(imgSize_js, 1, nTrans + nDtr);

%% ---------- string-typed import options for the mouse-trajectory helper functions ----------
% (seqMemTask_Curricula_Traj_anal.m forces every column to string so that
% parseMouseArray()/ismissing() behave consistently on bracketed number
% lists; the model-side bookkeeping below instead relies on MATLAB's
% default per-column type inference, exactly as in
% seqMemTask_modelPred_main.m, so the CSV is read twice with two different
% import options.)

%% ==========================================================================
%% Build the per-response table: one row per (subject, report type, trial, position)
%% ==========================================================================
respRows = {}; % accumulate rows, convert to table at the end

for iAge = 1 : nGroup
    for iCond = 1 : nCond
        [subj_list, groupName, suffixWord] = getSubjList_ConfEntropy(iAge, iCond);
        subjPath = [bhvDataDir, '/AgingReplay-v2-', suffixWord, '/', suffixWord, '-', groupName, '/'];
        subLen   = size(subj_list, 1);

        for iSub = 1 : subLen
            subjBv = subj_list{iSub, 1};
            subjTm = subj_list{iSub, 2};
            subUID = iAge * 10000 + iCond * 1000 + iSub;
            csvFile = [subjPath, subjBv, '_EpisodicMemoryTask-', suffixWord, '_', subjTm, '.csv'];

            fprintf('[%s | %s | sub %02d] %s\n', grpNames{iAge}, suffixWord, iSub, subjBv);

            % ------ read the CSV twice: default typing (model prep) and
            %        forced-string typing (mouse trajectory helpers) ------
            seqMem_subj_model = readtable(csvFile);

            optsStr = detectImportOptions(csvFile, 'Delimiter', ',', 'VariableNamingRule', 'preserve');
            optsStr = setvartype(optsStr, optsStr.VariableNames, 'string');
            seqMem_subj_traj  = readtable(csvFile, optsStr);

            %% ================= model-side trial-encoding bookkeeping =================
            % (verbatim structure of seqMemTask_modelPred_main.m, 'allLearning-marginalRep' branch)
            seqMem_subj = seqMem_subj_model;

            testOrd = seqMem_subj.trlTestOrd;
            testOrd = testOrd(~isnan(testOrd));

            uniCombSeq_tmp = seqMem_subj.trlComb;
            uniCombSeq_tmp = uniCombSeq_tmp(~cellfun('isempty', uniCombSeq_tmp));
            uniCombSeq = nan(nEpi, 2);
            for i = 1 : nEpi
                uniCombSeq(i, :) = str2num(uniCombSeq_tmp{i}); %#ok<ST2NM>
            end

            reconsOnly = seqMem_subj.reconsMark;
            reconsOnly = reconsOnly(~isnan(reconsOnly));

            posX_tmp = seqMem_subj.locSeqXTrl;
            posX_tmp = posX_tmp(~cellfun('isempty', posX_tmp));
            posY_tmp = seqMem_subj.locSeqYTrl;
            posY_tmp = posY_tmp(~cellfun('isempty', posY_tmp));
            posX_col = cell(nEpi, 1);
            posY_col = cell(nEpi, 1);
            for i = 1 : nEpi
                posX_col{i} = str2num(posX_tmp{i}); %#ok<ST2NM>
                posY_col{i} = str2num(posY_tmp{i}); %#ok<ST2NM>
            end

            % ---------- content report ----------
            conTrue_tmp_raw = seqMem_subj.conReportTrue;
            conTrue_tmp_raw = conTrue_tmp_raw(~cellfun('isempty', conTrue_tmp_raw));
            conTrue_tmp = cell(nEpi, 1);
            conTrue_tmp(reconsOnly == 0) = conTrue_tmp_raw;
            conRep_tmp_raw  = seqMem_subj.conReportOrd;
            conRep_tmp_raw  = conRep_tmp_raw(~cellfun('isempty', conRep_tmp_raw));
            conRep_tmp = cell(nEpi, 1);
            conRep_tmp(reconsOnly == 0) = conRep_tmp_raw;
            conTrue_col = cell(nEpi, 1);
            conRep_col  = cell(nEpi, 1);
            for i = 1 : nEpi
                if reconsOnly(i) == 0
                    conTrue_col{i} = str2num(conTrue_tmp{i}); %#ok<ST2NM>
                    conRep_col{i}  = str2num(conRep_tmp{i}); %#ok<ST2NM>
                end
            end

            % ---------- position report ----------
            locTrue_tmp_raw = seqMem_subj.locReportTrue;
            locTrue_tmp_raw = locTrue_tmp_raw(~cellfun('isempty', locTrue_tmp_raw));
            locTrue_tmp = cell(nEpi, 1);
            locTrue_tmp(reconsOnly == 0) = locTrue_tmp_raw;
            locRep_tmp_raw  = seqMem_subj.locReportOrd;
            locRep_tmp_raw  = locRep_tmp_raw(~cellfun('isempty', locRep_tmp_raw));
            locRep_tmp = cell(nEpi, 1);
            locRep_tmp(reconsOnly == 0) = locRep_tmp_raw;
            locTrue_col = cell(nEpi, 1);
            locRep_col  = cell(nEpi, 1);
            for i = 1 : nEpi
                if reconsOnly(i) == 0
                    locTrue_col{i} = str2num(locTrue_tmp{i}); %#ok<ST2NM>
                    locRep_col{i}  = str2num(locRep_tmp{i}); %#ok<ST2NM>
                end
            end
            locTrue_recon_trial = cell(sum(reconsOnly), 1);
            for i = 1 : sum(reconsOnly)
                locTrue_recon_trial{i} = 1 : 1 : (nTrans + 1);
            end

            % ---------- reconstruction report (needed to backfill true-order
            % labels on recons-only trials, matching modelPred_main) ----------
            bothTrue_tmp = seqMem_subj.bothReportTrue;
            bothTrue_tmp = bothTrue_tmp(~cellfun('isempty', bothTrue_tmp));
            bothTrue_col = cell(nEpi, 1);
            for i = 1 : nEpi
                bothTrue_col{i} = str2num(bothTrue_tmp{i}); %#ok<ST2NM>
            end
            conTrue_col(reconsOnly == 1) = bothTrue_col(reconsOnly == 1);
            locTrue_col(reconsOnly == 1) = locTrue_recon_trial;

            % ---------- unique-sequence-combination label ----------
            seqLab = nan(nEpi, 1);
            for i = 1 : nEpi
                uniC_i = uniCombSeq(i, :);
                if     uniC_i(1) == 0 && uniC_i(2) == 0, seqLab(i) = 1;
                elseif uniC_i(1) == 0 && uniC_i(2) == 1, seqLab(i) = 2;
                elseif uniC_i(1) == 1 && uniC_i(2) == 0, seqLab(i) = 3;
                elseif uniC_i(1) == 1 && uniC_i(2) == 1, seqLab(i) = 4;
                end
            end

            % ================ the two content transition sequences ================
            conSeqAll = seqMem_subj.conSeqTrl;
            conSeqAll = conSeqAll(~cellfun('isempty', conSeqAll));
            contentString = cell(nEpi, nTrans + 1);
            for i = 1 : nEpi
                input_str  = conSeqAll{i};
                file_paths = strsplit(input_str, ',');
                names = cell(size(file_paths));
                for iS = 1 : length(file_paths)
                    file_path = strtrim(file_paths{iS});
                    file_path = erase(file_path, '"');
                    [~, file_name, ~] = fileparts(file_path);
                    parts = strsplit(file_name, '/');
                    names{iS} = parts{end};
                end
                contentString(i, :) = names;
            end
            conA_id = find(uniCombSeq(:, 1) == 0 & reconsOnly == 0);
            conB_id = find(uniCombSeq(:, 1) == 1 & reconsOnly == 0);
            conAB_string = cell(nTrans, 2);

            itemIdxA = conTrue_col{conA_id(1)};
            [~, itemIdxA_sort] = sort(itemIdxA);
            conStrA = contentString(conA_id(1), itemIdxA_sort);
            conStrA(end) = [];
            conAB_string(:, 1) = conStrA;

            itemIdxB = conTrue_col{conB_id(1)};
            [~, itemIdxB_sort] = sort(itemIdxB);
            conStrB = contentString(conB_id(1), itemIdxB_sort);
            conStrB(end) = [];
            conAB_string(:, 2) = conStrB;

            imgList  = [conAB_string(:, 1); conAB_string([2, 4, 5], 2)];
            conA_seq = (1 : 1 : nTrans);
            conB_seq = [3, 6, 1, 7, 8];

            conStimIdx_report = cell(nEpi, 1);
            conSeq_encode     = cell(nEpi, 1);
            for i = 1 : nEpi
                conRep_str   = contentString(i, :);
                conStimIdx_i = nan(1, nTrans + 1);
                for id = 1 : (nTrans + 1)
                    index = find(ismember(imgList, conRep_str{id}));
                    conStimIdx_i(id) = index;
                end
                conStimIdx_report{i} = conStimIdx_i;
                itemIdx_i = conTrue_col{i};
                conStimIdx_i(itemIdx_i > nTrans) = [];
                if sum(sort(conStimIdx_i) == conA_seq) == nTrans
                    conSeq_encode{i} = conA_seq;
                else
                    conSeq_encode{i} = conB_seq;
                end
            end

            [tf, idx] = ismember(imgList, imgNameList);
            if ~all(tf)
                error('Some images in imgList are not found in imgNameList (sub %s).', subjBv);
            end
            imageSimilarity = conSimMat(idx, idx); % passed through for parity with the cached-fit call signature; v3 assumes no image confusion internally

            % ================ the two position transition sequences ================
            posA_id = find(uniCombSeq(:, 2) == 0 & reconsOnly == 0);
            posB_id = find(uniCombSeq(:, 2) == 1 & reconsOnly == 0);
            posA_seq = zeros(nTrans, 2);
            posA_seq(:, 1) = posX_col{posA_id(1)}(1 : nTrans);
            posA_seq(:, 2) = posY_col{posA_id(1)}(1 : nTrans);
            posB_seq = zeros(nTrans, 2);
            posB_seq(:, 1) = posX_col{posB_id(1)}(1 : nTrans);
            posB_seq(:, 2) = posY_col{posB_id(1)}(1 : nTrans);

            if (posA_seq(2, 1) == posB_seq(nTrans, 1) && posA_seq(2, 2) == posB_seq(nTrans, 2)) && ...
               (posA_seq(4, 1) == posB_seq(1, 1)      && posA_seq(4, 2) == posB_seq(1, 2))
                positionTrans = [1, 3, 8, 6, 4; ...
                                 6, 2, 5, 7, 3];
            elseif (posB_seq(2, 1) == posA_seq(nTrans, 1) && posB_seq(2, 2) == posA_seq(nTrans, 2)) && ...
                   (posB_seq(4, 1) == posA_seq(1, 1)      && posB_seq(4, 2) == posA_seq(1, 2))
                positionTrans = [6, 2, 5, 7, 3; ...
                                 1, 3, 8, 6, 4];
            end

            posList = nan(nPos, 2);
            for ip = 1 : nPos
                ip_find = find(positionTrans(1, :) == ip);
                if ~isempty(ip_find)
                    posList(ip, :) = posA_seq(ip_find, :);
                else
                    ip_find = find(positionTrans(2, :) == ip);
                    posList(ip, :) = posB_seq(ip_find, :);
                end
            end
            angList = nan(nPos, 1);
            for ip = 1 : nPos
                angList(ip) = atan2(posList(ip, 2), posList(ip, 1));
            end

            posStimIdx_report = cell(nEpi, 1);
            posSeq_encode     = cell(nEpi, 1);
            angSeq_encode     = cell(nEpi, 1);
            for i = 1 : nEpi
                posX_col_i = posX_col{i};
                posY_col_i = posY_col{i};
                posStimIdx_i = nan(1, nTrans + 1);
                for id = 1 : (nTrans + 1)
                    index_X = find(ismember(posList(:, 1), posX_col_i(id)));
                    index_Y = find(ismember(posList(:, 2), posY_col_i(id)));
                    index   = intersect(index_X, index_Y);
                    posStimIdx_i(id) = index;
                end
                posStimIdx_report{i} = posStimIdx_i;

                itemIdx_i = locTrue_col{i};
                posStimIdx_i(itemIdx_i > nTrans) = [];
                if sum(sort(posStimIdx_i) == sort(positionTrans(1, :))) == nTrans
                    posSeq_encode{i} = positionTrans(1, :);
                else
                    posSeq_encode{i} = positionTrans(2, :);
                end
                angSeq_encode{i} = angList((posSeq_encode{i})');
            end

            % ================ assemble fitting-format inputs (allLearning-marginalRep) ================
            stim_encode = cell(nEpi, 2);
            stim_encode(:, 1) = conSeq_encode;
            stim_encode(:, 2) = posSeq_encode;

            disp_con = conStimIdx_report;
            disp_pos = posStimIdx_report;
            disp_rec = [];

            resp_con = conRep_col;
            resp_pos = locRep_col;
            resp_rec = [];

            context_arr = seqLab;
            testOrd_arr = testOrd;

            trialLen = length(context_arr); % = nEpi = 64
            Minit    = eye(nImg, nImg);      % 'allLearning-marginalRep' always uses the diagonal prior

            %% ================= load the cached model fit =================
            % Guard against SeqMemTask_fitting silently launching a fresh
            % 100-restart fminsearchbnd fit (refit==0 only skips fitting if
            % the cache file already exists) — this script must only ever
            % read cached parameter estimates, never fit.
            subID = ['sub', num2str(iSub)];
            fnDir_check = [folder, '/ModelFitting_Results/', groupName, '/', suffixWord, '/', Midx, '-ModelFits-', fitWord, '/'];
            fn_check    = [fnDir_check, groupName, '-', suffixWord, '-', subID, '-rep', num2str(nFit), '.mat'];
            if ~exist(fn_check, 'file')
                warning('No cached fit found for %s-%s-%s (expected %s); skipping subject.', ...
                    groupName, suffixWord, subID, fn_check);
                continue;
            end

            [~, paramsEst] = SeqMemTask_fitting(folder, groupName, suffixWord, Midx, subID, fitWord, refit, nFit, ...
                nImg, nPos, nTrans, trialLen, stim_encode, disp_con, disp_pos, disp_rec, resp_con, resp_pos, resp_rec, ...
                context_arr, testOrd_arr, reconsOnly, Minit, angList, angSeq_encode, bindingDirec, optimzerIdx, 0, imageSimilarity);

            if isempty(paramsEst)
                warning('Empty parameter estimate for %s-%s-%s; skipping subject.', groupName, suffixWord, subID);
                continue;
            end

            %% ================= per-response model choice-probability predictors =================
            % H/Hnorm: Shannon entropy of the choice-probability distribution (raw / normalized).
            % PMax:    the model's probability for its most likely candidate at that step.
            % PDiff:   gap between the top and 2nd-most-likely candidate's probability.
            [H_con, H_pos, Hnorm_con, Hnorm_pos, PMax_con, PMax_pos, PDiff_con, PDiff_pos] = ...
                SeqMem_featureCompetition_update_v3_ChoiceProb( ...
                paramsEst, nImg, nPos, nTrans, trialLen, stim_encode, disp_con, disp_pos, disp_rec, ...
                resp_con, resp_pos, resp_rec, context_arr, testOrd_arr, reconsOnly, Minit, angList, angSeq_encode, ...
                bindingDirec, imageSimilarity);

            %% ================= trajectory-derived confidence metrics =================
            mouse_con = extractMouseClosestToReport(seqMem_subj_traj, 'mouseX',    'mouseY',    'mouseT',    'conReportTrue');
            mouse_loc = extractMouseClosestToReport(seqMem_subj_traj, 'mouseXloc', 'mouseYloc', 'mouseTloc', 'locReportTrue');

            epi_rows = find(~ismissing(seqMem_subj_traj.('trialNo')) & strlength(seqMem_subj_traj.('trialNo')) > 0);

            mouse_con = addStimPos(mouse_con, 'con', seqMem_subj_traj, epi_rows, imgDispX_global, imgDispY_global);
            mouse_loc = addStimPos(mouse_loc, 'loc', seqMem_subj_traj, epi_rows, [], []);

            mouse_con = computeDistToStim(mouse_con);
            mouse_loc = computeDistToStim(mouse_loc);

            mouse_con = analyzeChoiceHesitation(mouse_con, seqMem_subj_traj, 'con', nTrans, nDtr);
            mouse_loc = analyzeChoiceHesitation(mouse_loc, seqMem_subj_traj, 'loc', nTrans, nDtr);

            %% ================= align trials and append rows =================
            % mouse_con / mouse_loc contain one entry per marginal-report trial,
            % in the same chronological order as find(reconsOnly==0).
            trialIdx_marg = find(reconsOnly == 0);

            if length(mouse_con) ~= length(trialIdx_marg) || length(mouse_loc) ~= length(trialIdx_marg)
                warning('Trial-count mismatch for %s-%s-%s (con:%d, loc:%d, model:%d); skipping subject.', ...
                    groupName, suffixWord, subID, length(mouse_con), length(mouse_loc), length(trialIdx_marg));
                continue;
            end

            for k = 1 : length(trialIdx_marg)
                iT = trialIdx_marg(k);

                % ---- content report ----
                mc = mouse_con(k);
                if ~isempty(mc.isCorrect)
                    for pos = 1 : nTrans
                        Hval  = H_con(iT, pos);
                        isCor = mc.isCorrect(pos);
                        if isnan(Hval) || isnan(isCor)
                            continue;
                        end
                        respRows(end+1, :) = { iAge, iCond, subUID, "Content", iT, pos, logical(isCor), ...
                            Hval, Hnorm_con(iT, pos), PMax_con(iT, pos), PDiff_con(iT, pos), ...
                            mc.interClickTime(pos), mc.selSpeed(pos), mc.dwellTime(pos) }; %#ok<SAGROW>
                    end
                end

                % ---- position report ----
                ml = mouse_loc(k);
                if ~isempty(ml.isCorrect)
                    for pos = 1 : nTrans
                        Hval  = H_pos(iT, pos);
                        isCor = ml.isCorrect(pos);
                        if isnan(Hval) || isnan(isCor)
                            continue;
                        end
                        respRows(end+1, :) = { iAge, iCond, subUID, "Location", iT, pos, logical(isCor), ...
                            Hval, Hnorm_pos(iT, pos), PMax_pos(iT, pos), PDiff_pos(iT, pos), ...
                            ml.interClickTime(pos), ml.selSpeed(pos), ml.dwellTime(pos) }; %#ok<SAGROW>
                    end
                end
            end
        end
    end
end

varNames = {'AgeGrp', 'Cond', 'SubID', 'ReportType', 'TrialIdx', 'SeqPos', 'IsCorrect', ...
            'H', 'Hnorm', 'PMax', 'PDiff', 'InterClickTime', 'SelSpeed', 'DwellTime'};
respTable = cell2table(respRows, 'VariableNames', varNames);
respTable.AgeGrp = categorical(respTable.AgeGrp, [1, 2], grpLabels_age);
respTable.Cond   = categorical(respTable.Cond, 1 : nCond, expList);

fprintf('\nAssembled %d responses from %d unique participants.\n', ...
    height(respTable), length(unique(respTable.SubID)));

%% ------ save the per-response table for reuse ------
% save([CLdata_folder, 'respTable_ConfEntropy_YAOA.mat'], 'respTable');

%% ==========================================================================
%% Correlation analysis: confidence metric vs. model choice-probability predictors
%% (Shannon entropy H/Hnorm, best-choice probability PMax, top-2 gap PDiff)
%% ==========================================================================
predictorFields = {'H', 'Hnorm', 'PMax', 'PDiff'};
predictorLabels = {'Raw entropy (bits)', 'Normalized entropy', 'P(best choice)', 'P(best) - P(2nd best)'};
metricFields   = {'InterClickTime', 'SelSpeed', 'DwellTime'};
reportTypes    = {'Content', 'Location'};
minRespPerSubj = 5; % minimum valid (metric, entropy) pairs required to compute a within-subject r

withinRows  = {};
betweenRows = {};
betweenByCondRows = {}; % between-subject correlation stratified by curriculum x age group (feeds the illustrative scatter figure)
rDetailRows = {}; % one row per (subject, combination) with a defined within-subject r, for plotting

for iEnt = 1 : length(predictorFields)
    predField = predictorFields{iEnt};

    for iRT = 1 : length(reportTypes)
        rtName = reportTypes{iRT};

        for iMet = 1 : length(metricFields)
            metField = metricFields{iMet};

            for isCorrVal = [true, false]
                corrLabel = "Incorrect";
                if isCorrVal, corrLabel = "Correct"; end

                rowsMask = respTable.ReportType == rtName & respTable.IsCorrect == isCorrVal;
                subIDs   = unique(respTable.SubID(rowsMask));

                %% ---- (1) within-participant correlation, per response ----
                rSubj   = nan(length(subIDs), 1);
                nSubj   = nan(length(subIDs), 1);
                ageSubj = strings(length(subIDs), 1);
                condSubj = strings(length(subIDs), 1);

                %% ---- (2) between-participant inputs: per-subject means ----
                metMeanSubj = nan(length(subIDs), 1);
                predMeanSubj = nan(length(subIDs), 1);

                for iS = 1 : length(subIDs)
                    subMask = rowsMask & respTable.SubID == subIDs(iS);
                    x = respTable.(predField)(subMask);
                    y = respTable.(metField)(subMask);
                    valid = ~isnan(x) & ~isnan(y);
                    nSubj(iS) = sum(valid);

                    firstIdx = find(subMask, 1);
                    ageSubj(iS)  = string(respTable.AgeGrp(firstIdx));
                    condSubj(iS) = string(respTable.Cond(firstIdx));

                    if nSubj(iS) >= minRespPerSubj
                        rSubj(iS) = corr(x(valid), y(valid), 'Type', 'Spearman');
                    end
                    if any(valid)
                        predMeanSubj(iS) = mean(x(valid));
                        metMeanSubj(iS) = mean(y(valid));
                    end

                    if ~isnan(rSubj(iS))
                        rDetailRows(end+1, :) = {string(predField), string(rtName), string(metField), ...
                            corrLabel, subIDs(iS), ageSubj(iS), condSubj(iS), rSubj(iS)}; %#ok<SAGROW>
                    end
                end

                % ---- within-subject summary: pooled + per age group ----
                ageGroupsToTest = ["All", grpLabels_age];
                for iAgeTest = 1 : length(ageGroupsToTest)
                    ageSel = ageGroupsToTest(iAgeTest);
                    if ageSel == "All"
                        sel = ~isnan(rSubj);
                    else
                        sel = ~isnan(rSubj) & ageSubj == ageSel;
                    end
                    nGood = sum(sel);
                    if nGood >= 3
                        fz = atanh(min(max(rSubj(sel), -0.999999), 0.999999)); % Fisher-z transforms each participant's r, so the values are approximately normal and poolable across subjects.
                        [~, p, ~, stats] = ttest(fz);
                        meanR = tanh(mean(fz));
                    else
                        p = NaN; meanR = NaN; stats.tstat = NaN;
                    end
                    withinRows(end+1, :) = {string(predField), string(rtName), string(metField), corrLabel, ageSel, nGood, meanR, stats.tstat, p}; %#ok<SAGROW>
                end

                % ---- between-subject summary: pooled + per age group ----
                validBetween = ~isnan(predMeanSubj) & ~isnan(metMeanSubj);
                for iAgeTest = 1 : length(ageGroupsToTest)
                    ageSel = ageGroupsToTest(iAgeTest);
                    if ageSel == "All"
                        sel = validBetween;
                    else
                        sel = validBetween & ageSubj == ageSel;
                    end
                    nGood = sum(sel);
                    if nGood >= 3
                        [rB, pB] = corr(predMeanSubj(sel), metMeanSubj(sel), 'Type', 'Spearman');
                    else
                        rB = NaN; pB = NaN;
                    end
                    betweenRows(end+1, :) = {string(predField), string(rtName), string(metField), corrLabel, ageSel, nGood, rB, pB}; %#ok<SAGROW>
                end

                % ---- between-subject summary: per curriculum x per age group ----
                % (finer-grained than the pooled block above; this is what the
                % illustrative scatter figure's per-panel r/p labels draw from,
                % so that the plotted p-values go through the same FDR correction.)
                for iCondTest = 1 : nCond
                    condSel = string(expList{iCondTest});
                    for iAgeTest2 = 1 : nGroup
                        ageSel2 = string(grpLabels_age{iAgeTest2});
                        sel = validBetween & ageSubj == ageSel2 & condSubj == condSel;
                        nGood = sum(sel);
                        if nGood >= 3
                            [rBC, pBC] = corr(predMeanSubj(sel), metMeanSubj(sel), 'Type', 'Spearman');
                        else
                            rBC = NaN; pBC = NaN;
                        end
                        betweenByCondRows(end+1, :) = {string(predField), string(rtName), string(metField), ...
                            corrLabel, condSel, ageSel2, nGood, rBC, pBC}; %#ok<SAGROW>
                    end
                end
            end
        end
    end
end

withinSummary  = cell2table(withinRows, 'VariableNames', ...
    {'PredictorType', 'ReportType', 'Metric', 'Correctness', 'AgeGrp', 'N_subj', 'MeanR_FisherZ', 'tStat', 'p'});
betweenSummary = cell2table(betweenRows, 'VariableNames', ...
    {'PredictorType', 'ReportType', 'Metric', 'Correctness', 'AgeGrp', 'N_subj', 'R', 'p'});
betweenByCondSummary = cell2table(betweenByCondRows, 'VariableNames', ...
    {'PredictorType', 'ReportType', 'Metric', 'Correctness', 'Cond', 'AgeGrp', 'N_subj', 'R', 'p'});
rDetailTable = cell2table(rDetailRows, 'VariableNames', ...
    {'PredictorType', 'ReportType', 'Metric', 'Correctness', 'SubID', 'AgeGrp', 'Cond', 'R'});

% FDR correction across all tests within each summary table (Benjamini-Hochberg).
% Only the tests with an actual p-value (nGood >= 3) enter the correction
% family; feeding fdr_bh() the NaN rows too would inflate its family size m
% and make the correction needlessly conservative for the real tests.
withinSummary.p_fdr  = nan(height(withinSummary), 1);
validP  = ~isnan(withinSummary.p);
[~, ~, ~, adjP] = fdr_bh(withinSummary.p(validP), 0.05, 'pdep');
withinSummary.p_fdr(validP) = adjP;

betweenSummary.p_fdr = nan(height(betweenSummary), 1);
validP  = ~isnan(betweenSummary.p);
[~, ~, ~, adjP] = fdr_bh(betweenSummary.p(validP), 0.05, 'pdep');
betweenSummary.p_fdr(validP) = adjP;

betweenByCondSummary.p_fdr = nan(height(betweenByCondSummary), 1);
validP  = ~isnan(betweenByCondSummary.p);
[~, ~, ~, adjP] = fdr_bh(betweenByCondSummary.p(validP), 0.05, 'pdep');
betweenByCondSummary.p_fdr(validP) = adjP;

fprintf('\n=== Within-participant correlations (confidence metric vs. model entropy, per response) ===\n');
disp(withinSummary);

fprintf('\n=== Between-participant correlations (subject-averaged confidence metric vs. subject-averaged model entropy) ===\n');
disp(betweenSummary);

fprintf('\n=== Between-participant correlations, per curriculum x age group (feeds the scatter figure labels) ===\n');
disp(betweenByCondSummary);

%% ------ save summaries ------
% save([CLdata_folder, 'ConfEntropy_corrSummary_YAOA.mat'], 'respTable', 'withinSummary', 'betweenSummary', 'betweenByCondSummary');

%% ==========================================================================
%% plotting the within-subject correlations
%% ==========================================================================
% Same format as the proximity-proportion figure in
% seqMemTask_Curricula_anal_summary.m (lines 3037-3065): one x-position per
% age group (YA and OA together), each participant's own within-subject r
% plotted as a jittered dot, with the group mean +/- SEM overlaid as a
% larger dot. One figure per (report type, metric); rows = correct/incorrect,
% columns = the 3 curricula (interleaved / contentBlocked / positionBlocked),
% so the three curricula are shown separately rather than pooled.

grpColors     = [248, 218, 172; ...     % YA
                 184, 204, 225] ./ 255; % OA
predFieldPlot_r = 'Hnorm'; % which predictor to plot: 'H' | 'Hnorm' | 'PMax' | 'PDiff' (all available in rDetailTable)
barPos_r      = [1; 2.5];   % one x-position per age group, as in the reference figure
figKey        = 1;
errLineWid    = (figKey == 0) * 3 + (figKey == 1) * 1.5;

for iRT = 1 : length(reportTypes)
    rtName = reportTypes{iRT};
    for iMet = 1 : length(metricFields)
        metField = metricFields{iMet};

        figure('Name', ['Within-subject r - ', rtName, ' - ', metField], ...
               'Color', 'w', 'Position', [100 100 780 340]), clf;

        for iCorrRow = 1 : 2
            corrLabel_col = "Correct";
            if iCorrRow == 2, corrLabel_col = "Incorrect"; end

            for iCond = 1 : nCond
                condName = expList{iCond};
                panelIdx = (iCorrRow - 1) * nCond + iCond;
                ax = subplot(2, nCond, panelIdx); hold(ax, 'on');

                for iAgeP = 1 : nGroup
                    ageSel = grpLabels_age{iAgeP};
                    rowsMask = rDetailTable.PredictorType == predFieldPlot_r & ...
                               rDetailTable.ReportType   == rtName & ...
                               rDetailTable.Metric        == metField & ...
                               rDetailTable.Correctness   == corrLabel_col & ...
                               rDetailTable.Cond          == condName & ...
                               rDetailTable.AgeGrp         == ageSel;
                    dat = rDetailTable.R(rowsMask); % one within-subject r per participant

                    dat_avg = nanmean(dat);
                    dat_sem = nanstd(dat) / sqrt(sum(~isnan(dat)));
                    bP = barPos_r(iAgeP);

                    xRand_iGrp  = unifrnd(bP - 0.2, bP + 0.2, length(dat), 1);
                    xRand_color = 0.4 * grpColors(iAgeP, :) + 0.6 * [1, 1, 1];
                    for iSub = 1 : length(dat)
                        plot(ax, xRand_iGrp(iSub), dat(iSub), 'Marker', 'o', 'MarkerSize', 6, ...
                            'MarkerFaceColor', xRand_color, 'MarkerEdgeColor', 'k', ...
                            'LineStyle', 'none', 'LineWidth', 0.6);
                    end
                    errorbar(ax, bP, dat_avg, dat_sem, 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid);
                    plot(ax, bP, dat_avg, 'Marker', 'o', 'MarkerSize', 8, ...
                        'MarkerFaceColor', grpColors(iAgeP, :), 'MarkerEdgeColor', 'k', ...
                        'LineStyle', 'none', 'LineWidth', 0.8);
                end

                plot(ax, [0.4, 3.1], [0, 0], 'k--', 'LineWidth', 0.6); % reference: r = 0 (no correlation)

                xlim(ax, [0.4, 3.1]);
                ylim(ax, [-1, 1]);
                set(ax, 'LineWidth', 0.8, 'FontSize', 9, 'FontWeight', 'bold', 'FontName', 'Arial');
                set(ax, 'XTick', barPos_r', 'XTickLabel', {'YA', 'OA'});
                if iCond == 1
                    ylabel(ax, 'Within-subject r');
                end
                title(ax, [char(corrLabel_col), ' - ', condName], 'FontSize', 8);
                box(ax, 'off');
            end
        end
    end
end

%% ==========================================================================
%% Illustrative figure: between-participant scatter (predFieldPlot vs. each metric)
%% One figure per (report type, metric, correctness) — correct and incorrect
%% responses are now separate figures. Columns = the 3 curricula (interleaved /
%% contentBlocked / positionBlocked). YA and OA are shown together within each
%% panel, but fit SEPARATELY: each age group gets its own linear regression
%% line + labeled 95% CI band, colored to match its scatter color.
%% ==========================================================================
grpColors = [248, 218, 172; ...     % YA
             184, 204, 225] ./ 255; % OA
predFieldPlot = 'Hnorm'; % which predictor to plot: 'H' | 'Hnorm' | 'PMax' | 'PDiff'
figPos = [100 100 900 240];
minSubjForFit = 3; % minimum subjects (within one age group) required to fit/draw its regression line

for iRT = 1 : length(reportTypes)
    rtName = reportTypes{iRT};
    for iMet = 1 : length(metricFields)
        metField = metricFields{iMet};

        for isCorrVal = [true, false]
            corrLabelStr = 'Incorrect';
            if isCorrVal, corrLabelStr = 'Correct'; end

            figure('Name', ['ConfEntropy scatter - ', rtName, ' - ', metField, ' - ', corrLabelStr], ...
                   'Color', 'w', 'Position', figPos), clf;

            for iCond = 1 : nCond
                condName = expList{iCond};
                ax = subplot(1, nCond, iCond); hold(ax, 'on');

                for iAgeP = 1 : nGroup
                    ageSel = grpLabels_age{iAgeP};
                    rowsMask = respTable.ReportType == rtName & respTable.IsCorrect == isCorrVal & ...
                               respTable.AgeGrp == ageSel & respTable.Cond == condName;
                    subIDs = unique(respTable.SubID(rowsMask));

                    xPlot = nan(length(subIDs), 1);
                    yPlot = nan(length(subIDs), 1);
                    for iS = 1 : length(subIDs)
                        subMask = rowsMask & respTable.SubID == subIDs(iS);
                        xVal = respTable.(predFieldPlot)(subMask);
                        yVal = respTable.(metField)(subMask);
                        valid = ~isnan(xVal) & ~isnan(yVal);
                        if any(valid)
                            xPlot(iS) = mean(xVal(valid));
                            yPlot(iS) = mean(yVal(valid));
                        end
                    end
                    scatter(ax, xPlot, yPlot, 30, grpColors(iAgeP, :), 'filled', ...
                        'MarkerEdgeColor', 'k', 'DisplayName', ageSel);

                    % ---- per-age-group linear fit with its own labeled 95% CI band ----
                    validFit = ~isnan(xPlot) & ~isnan(yPlot);
                    if sum(validFit) >= minSubjForFit
                        mdl = fitlm(xPlot(validFit), yPlot(validFit));

                        xfit = linspace(min(xPlot(validFit)), max(xPlot(validFit)), 100)';
                        [yfit, yCI] = predict(mdl, xfit);

                        fitColor = grpColors(iAgeP, :) * 0.6; % darker than the scatter fill, for legibility
                        patch(ax, [xfit; flipud(xfit)], [yCI(:, 1); flipud(yCI(:, 2))], ...
                            grpColors(iAgeP, :), 'FaceAlpha', 0.25, 'EdgeColor', 'none', ...
                            'DisplayName', [ageSel, ' 95% CI']);
                        plot(ax, xfit, yfit, 'Color', fitColor, 'LineWidth', 2, ...
                            'DisplayName', [ageSel, ' fit']);

                        % Spearman r/p come from betweenByCondSummary (built above) so the
                        % displayed p-value is the same FDR-corrected one reported in that
                        % table, rather than a fresh uncorrected p computed just for the plot.
                        lookupIdx = find(betweenByCondSummary.PredictorType == predFieldPlot & ...
                                         betweenByCondSummary.ReportType   == rtName & ...
                                         betweenByCondSummary.Metric        == metField & ...
                                         betweenByCondSummary.Correctness   == corrLabelStr & ...
                                         betweenByCondSummary.Cond          == condName & ...
                                         betweenByCondSummary.AgeGrp         == ageSel, 1);
                        rSp    = betweenByCondSummary.R(lookupIdx);
                        pSpFDR = betweenByCondSummary.p_fdr(lookupIdx);

                        yAnnot = 0.95 - 0.10 * (iAgeP - 1); % stack YA/OA annotations vertically
                        text(ax, 0.05, yAnnot, sprintf('%s: r=%.2f, p_{FDR}=%.3f', ageSel, rSp, pSpFDR), ...
                            'Units', 'normalized', 'FontSize', 6.5, 'VerticalAlignment', 'top', ...
                            'Color', fitColor);
                    end
                end

                xlabel(ax, predictorLabels{strcmp(predictorFields, predFieldPlot)});
                ylabel(ax, metField);
                title(ax, condName, 'FontSize', 8);
                set(ax, 'LineWidth', 1, 'FontSize', 9, 'FontName', 'Arial', 'TickDir', 'out', 'Box', 'off');
            end
        end
    end
end

%% ==========================================================================
%% Illustrative figure: between-participant scatter, pooled across curricula
%% (YA and OA each pool their subjects across all 3 curricula), with correct
%% vs. incorrect responses kept as two separate panels in one figure per
%% (report type, metric). YA and OA are fit SEPARATELY here too — same as
%% the per-curriculum figure — each with its own labeled regression line,
%% 95% CI band, and r/p_FDR annotation.
%% ==========================================================================
grpColors = [248, 218, 172; ...     % YA
             184, 204, 225] ./ 255; % OA
predFieldPlot = 'PDiff'; % which predictor to plot: 'H' | 'Hnorm' | 'PMax' | 'PDiff'
figPos = [100 100 560 260];
minSubjForFit = 3; % minimum subjects (within one age group) required to fit/draw its regression line

for iRT = 1 : length(reportTypes)
    rtName = reportTypes{iRT};
    for iMet = 1 : length(metricFields)
        metField = metricFields{iMet};

        figure('Name', ['ConfEntropy scatter (pooled) - ', rtName, ' - ', metField], ...
               'Color', 'w', 'Position', figPos), clf;

        for iCorrCol = 1 : 2
            isCorrVal = (iCorrCol == 1); % col1: correct, col2: incorrect
            corrLabelStr = 'Incorrect';
            if isCorrVal, corrLabelStr = 'Correct'; end

            ax = subplot(1, 2, iCorrCol); hold(ax, 'on');

            for iAgeP = 1 : nGroup
                ageSel = grpLabels_age{iAgeP};
                % No Cond filter here: each age group is pooled across all 3 curricula.
                rowsMask = respTable.ReportType == rtName & respTable.IsCorrect == isCorrVal & ...
                           respTable.AgeGrp == ageSel;
                subIDs = unique(respTable.SubID(rowsMask));

                xPlot = nan(length(subIDs), 1);
                yPlot = nan(length(subIDs), 1);
                for iS = 1 : length(subIDs)
                    subMask = rowsMask & respTable.SubID == subIDs(iS);
                    xVal = respTable.(predFieldPlot)(subMask);
                    yVal = respTable.(metField)(subMask);
                    valid = ~isnan(xVal) & ~isnan(yVal);
                    if any(valid)
                        xPlot(iS) = mean(xVal(valid));
                        yPlot(iS) = mean(yVal(valid));
                    end
                end
                scatter(ax, xPlot, yPlot, 30, grpColors(iAgeP, :), 'filled', 'MarkerEdgeColor', 'k');

                % ---- per-age-group linear fit with its own labeled 95% CI band ----
                validFit = ~isnan(xPlot) & ~isnan(yPlot);
                if sum(validFit) >= minSubjForFit
                    mdl = fitlm(xPlot(validFit), yPlot(validFit));

                    xfit = linspace(min(xPlot(validFit)), max(xPlot(validFit)), 100)';
                    [yfit, yCI] = predict(mdl, xfit);

                    fitColor = grpColors(iAgeP, :) * 0.6; % darker than the scatter fill, for legibility
                    patch(ax, [xfit; flipud(xfit)], [yCI(:, 1); flipud(yCI(:, 2))], ...
                        grpColors(iAgeP, :), 'FaceAlpha', 0.25, 'EdgeColor', 'none');
                    plot(ax, xfit, yfit, 'Color', fitColor, 'LineWidth', 2);

                    % Spearman r/p come from betweenSummary (AgeGrp == ageSel), which
                    % is already pooled across curricula for that age group, so the
                    % displayed p-value is the same FDR-corrected one reported there.
                    lookupIdx = find(betweenSummary.PredictorType == predFieldPlot & ...
                                     betweenSummary.ReportType   == rtName & ...
                                     betweenSummary.Metric        == metField & ...
                                     betweenSummary.Correctness   == corrLabelStr & ...
                                     betweenSummary.AgeGrp         == ageSel, 1);
                    rSp    = betweenSummary.R(lookupIdx);
                    pSpFDR = betweenSummary.p_fdr(lookupIdx);

                    yAnnot = 0.95 - 0.10 * (iAgeP - 1); % stack YA/OA annotations vertically
                    text(ax, 0.20, yAnnot, sprintf('%s: r=%.2f, p_{FDR}=%.3f', ageSel, rSp, pSpFDR), ...
                        'Units', 'normalized', 'FontSize', 7, 'VerticalAlignment', 'top', ...
                        'Color', fitColor);
                end
            end

            xlabel(ax, predictorLabels{strcmp(predictorFields, predFieldPlot)});
            ylabel(ax, metField);
            title(ax, corrLabelStr);
            set(ax, 'LineWidth', 1, 'FontSize', 9, 'FontName', 'Arial', 'TickDir', 'out', 'Box', 'off');
        end

        % ---- save figure (whole figure, not just one axes, since both
        % correct/incorrect panels live in this one figure) ----
        figH = gcf;
        save_name = sprintf('ConfEntropy_pooled_%s_%s.png', rtName, metField);
        exportgraphics(figH, save_name, 'Resolution', 600);
    end
end

%% ------ Define the helper functions ------

function [subj_list, groupName, suffixWord] = getSubjList_ConfEntropy(iAge, iCond)
% Returns the subject ID/timestamp list, age-group folder name, and
% curriculum-condition suffix for a given (age, condition) combination.
% Subject lists copied verbatim from seqMemTask_modelPred_main.m /
% seqMemTask_Curricula_Traj_anal.m.

expList = {'interleaved', 'contentBlocked', 'positionBlocked'};
suffixWord = expList{iCond};

if iAge == 1
    groupName = 'younger';
    switch iCond
        case 1 % interleaved
            subj_list = {'5ad63c167f70c10001904bc5', '2023-08-30_17h17.39.428'; '5bdb51e1ba9b510001052364', '2023-08-30_15h12.00.151'; '5c4b06903566570001309394', '2023-08-30_16h55.13.543'; ...
                         '5d024a1fb58b6f001a58f74d', '2023-08-30_15h11.44.361'; '5d43404f1e6eef00011dec22', '2023-08-30_15h12.02.990'; '5ef25afb8ebcdf0b2b95d9cd', '2023-08-30_15h09.37.394'; ...
                         '5f15f96e54587538da27d452', '2023-08-30_15h40.43.668'; '5fd0c81fc79aef1882cbee94', '2023-08-30_16h25.12.136'; '60fecc838b1c231b1732cbb0', '2023-08-30_15h07.34.541'; ...
                         '601f93758d79b24eabff2e44', '2023-08-30_15h11.55.950'; '602fc5844525b3d343303a2a', '2023-08-30_14h05.56.283'; '604be8ac8e0c517878fd1d9f', '2023-08-30_14h05.21.886'; ...
                         '612ecc90331b627f7aaac5dc', '2023-08-30_16h23.19.001'; '614fca831894ddce32c1a342', '2023-08-30_15h20.32.432'; '615b5902e51bcad574d81203', '2023-08-30_15h18.25.454'; ...
                         '6016c8e7ea3f2387ae8b47d5', '2023-08-30_16h11.53.139'; '6103c08d411c6be73d9d78a7', '2023-08-30_15h20.28.394'; '6159f6b637bab134ea9bb92e', '2023-08-30_15h13.34.934'; ...
                         '61070b50a022d7360e46e985', '2023-08-30_16h08.26.937'; '61353c933f32fef782432cc7', '2023-08-30_15h10.45.788'; '605272be8568b6160f582f2e', '2023-08-30_14h38.14.393'; ...
                         '6107292e60892e4246db7425', '2023-08-30_15h12.11.729'; '61685478a9bd5239a9438f66', '2023-08-30_15h12.25.867'; '614831813dc412ccc8e2f563', '2023-08-30_15h31.25.179'};
        case 2 % contentBlocked
            subj_list = {'5a6e4ecae6cc4a0001b6d38d', '2023-08-30_14h14.47.654'; '5bcdb05e1bfcbf0001d77240', '2023-08-30_15h43.03.664'; '5eceef5fa487421604c337ba', '2023-08-30_19h06.46.141'; ...
                         '5f1f1a1f443fd90bf5e2e716', '2023-08-30_15h12.16.243'; '5f4fd62570b0df0f71a35d98', '2023-08-30_16h34.02.959'; '5f5f6e9b003b2a0217bba847', '2023-08-30_16h33.19.240'; ...
                         '5f8825d4938a85280f506a83', '2023-08-30_14h12.31.867'; '60db9c9850c39eea109ef1d3', '2023-08-30_15h14.10.340'; '60f31ca80f6c233558e5a354', '2023-08-30_15h14.19.785'; ...
                         '603e2530ab9d37d734fa6ca9', '2023-08-30_15h20.00.625'; '610a5f883d6841e65838f97d', '2023-08-30_15h20.15.081'; '611d604624f673b1e62275c5', '2023-08-30_15h14.05.541'; ...
                         '612cf0efe0be33cea5c5a123', '2023-08-30_15h13.46.115'; '615cc500aab10659f82a02ab', '2023-08-30_15h20.16.812'; '616fd6aac8d209bdcd631c2a', '2023-08-30_15h15.09.944'; ...
                         '6106e9f1880fb0b44c319ced', '2023-08-30_14h13.50.009'; '6130e97d4106299f8c6120fa', '2023-08-30_15h13.59.129'; '6151e74c66fb9fb95b2f522e', '2023-08-30_15h17.08.514'; ...
                         '6159bec91e6d099cb2b032fc', '2023-08-30_15h14.49.228'; '60561bed5ea5ad8dbe3fae07', '2023-08-30_14h38.38.277'; '61698b3f8623f619b602b00b', '2023-08-30_15h07.19.062'; ...
                         '610063b7b50c4e9488e77eca', '2023-08-30_15h16.38.986'; '617091df73f7dd1c8448b3f4', '2023-08-30_15h14.45.308'; '615024818c0798f950215d49', '2023-08-30_15h13.03.877'};
        case 3 % positionBlocked
            subj_list = {'5eac7f2a11f5972d923bcd8e', '2023-08-30_15h14.56.423'; '5ecfdd84dc64e1061b97e321', '2023-08-30_15h16.52.236'; '5f82fd997dab234303560326', '2023-08-30_16h05.14.338'; ...
                         '60aadeb9e6e8147089f7eced', '2023-08-30_15h10.48.242'; '60cca032f398af85575618e3', '2023-08-30_15h14.23.924'; '60d333a37d135f2ee2592457', '2023-08-30_14h06.57.777'; ...
                         '60f5db51ea1f75902fc20970', '2023-08-30_14h26.24.581'; '60f6a19c247160dce8d5a69c', '2023-08-30_17h45.57.432'; '60fb0d1ef1ea8d2bcb8166dd', '2023-08-30_16h02.38.876'; ...
                         '64c12183ab9cf635c69df81b', '2023-08-30_15h10.11.992'; '603e5d265ed1c2e3ea13ebad', '2023-08-30_15h12.42.164'; '611b87ab5cc971129768ead2', '2023-08-30_15h16.28.053'; ...
                         '611d06c0bcc92ba3d7669ef6', '2023-08-30_15h20.29.244'; '611e60a6a1fd59a57341b862', '2023-08-30_15h18.11.988'; '60940b7855b3a885f925856b', '2023-08-30_14h06.05.080'; ...
                         '61544c72236c88d054490ea6', '2023-08-30_15h06.40.921'; '64736ec17f1a9b745c8fad92', '2023-08-30_14h24.33.592'; '613615da1eacf6204ce33479', '2023-08-30_14h05.15.755'; ...
                         '64526929d8f9b780b29d4d8d', '2023-08-30_16h31.49.928'; '6175733727b1e3ce2d72dbe4', '2023-08-30_15h24.49.630'; '61412724735027d42bf53011', '2023-08-30_15h12.53.447'};
    end
else
    groupName = 'older';
    switch iCond
        case 1 % interleaved
            subj_list = {'5abb8dcb7ccedb0001b7f0d7', '2023-05-23_15h56.51.831'; '5be064114c6bd000013368f3', '2023-05-22_18h00.20.474'; '5c5df0475b87820001c4f21c', '2023-05-23_16h15.47.308'; ...
                         '5e9f0bc126557006ea49d1f4', '2023-05-23_16h58.16.506'; '5ea20fd571038c119083a8df', '2023-05-23_15h56.44.482'; '63b2d04ed0f53f75de4ba38e', '2023-05-23_16h30.06.501'; ...
                         '609a503448860549084c43ce', '2023-05-22_17h13.56.435'; '60534c39d754d351333bdd7c', '2023-05-23_16h15.50.361'; '597519f8262c480001bbaf8b', '2023-05-23_17h49.49.000'; ...
                         '61539b3fa541b182c0fadde1', '2023-05-26_11h37.17.532'; '574ce0a57fd0ec000db73aa6', '2023-05-26_12h33.38.572'; '55900dcffdf99b3f7aada3f5', '2023-05-26_10h08.56.439'; ...
                         '55e9aa1c735c45001043fbb6', '2023-05-26_17h56.53.674'; '64456ad3d3e7651a1dad232c', '2023-05-26_11h53.36.716'; '62aa26dd93252c8d69f7fc45', '2023-05-26_17h51.56.081'; ...
                         '5f53b958c8cfea6e2104c5b6', '2023-05-26_17h23.34.078'; '5f48e3d7f998433ac6356ad4', '2023-05-26_11h52.29.081'; '62f0f033178f89dd6f416590', '2023-05-26_17h21.29.494'; ...
                         '5c79a584670f87001646cef6', '2023-05-26_17h42.42.514'; '630be3605287a0f49b87c709', '2023-05-26_16h37.54.676'; '6121190671d1042b24d8d67b', '2023-05-26_16h16.28.267'; ...
                         '5c4cdcb14cb4630001ec4955', '2023-05-26_16h17.13.674'; '5f6e83419dd5cb3c85325fc6', '05-26-2023_16h37.34.939'};
        case 2 % contentBlocked
            subj_list = {'5c964575c7f75b000167754e', '2023-05-23_16h14.31.968'; '5dfb7cbd01423f8a774d893b', '2023-05-23_18h31.24.688'; '5e8f569436e20a234f89a6f4', '2023-05-23_16h13.25.490'; ...
                         '5ea0b2cbf710490ac2644b7e', '2023-05-23_16h20.30.392'; '5ea3319a6a1a5b2a1175ed6e', '2023-05-23_16h15.41.365'; '5ea159434ac916016387488e', '2023-05-23_15h58.15.599'; ...
                         '58e79d86fe9c8c0001c77ced', '2023-05-23_16h11.20.170'; '574da26c7f1e770007f42d11', '2023-05-23_16h16.02.150'; '614c5dc3cda534db7afc2e73', '2023-05-23_16h09.12.297'; ...
                         '614f874e5b46971822dfa61a', '2023-05-23_18h55.58.563'; '6161bdbff67e4b4621b530e7', '2023-05-23_17h11.58.970'; '59eb2cc98c371000010bb196', '2023-05-26_18h01.10.451'; ...
                         '5e86c11942701c2ffda5d113', '2023-05-26_11h48.52.812'; '6086c333d6eb73cfdd564e90', '2023-05-26_17h01.07.280'; '5eb2695f1745801c7c919e35', '2023-05-26_16h36.21.594'; ...
                         '5af32f9d003f6c0001f2905b', '2023-05-26_16h27.35.772'; '61703be3748d6f5ddc01170a', '2023-05-26_17h11.26.871'; '610c67785d74ee2c4a39def8', '2023-05-26_16h24.47.208'; ...
                         '5c8ee6c36ca70b0001fe979d', '2023-05-26_11h13.31.213'; '63beebaa4c5884797ff00a98', '2023-05-26_16h33.19.754'; '62162ab683fc823e78c025e5', '2023-05-26_16h09.16.187'; ...
                         '5ab14bdeb0ca80000197e6b6', '2023-05-26_16h15.01.130'; '6452058d0baefbe199f321e0', '2023-05-26_15h56.07.802'; '5e510d0760dd0913e45370dc', '2023-05-26_15h56.04.808'; ...
                         '5c081c45fd9c080001709937', '2023-05-26_15h51.35.355'};
        case 3 % positionBlocked
            subj_list = {'5a9e9fc46219a30001f54994', '2023-05-23_17h08.22.534'; '5ab8d182e1546900019b7195', '2023-05-23_16h22.50.058'; '5b017ef1293d310001023bd8', '2023-05-23_16h11.23.900'; ...
                         '5d812e3c613aa900188746a6', '2023-05-23_16h31.34.361'; '60ce6af707bcd42cbc885210', '2023-05-23_16h30.17.733'; '60f34fcae3c49524b0903a5d', '2023-05-23_16h19.52.799'; ...
                         '60f728553a37102574b585c4', '2023-05-23_11h34.06.217'; '612cc22830e71399b7a86841', '2023-05-23_16h23.00.515'; '6130a32cd30a251765045601', '2023-05-23_16h57.41.603'; ...
                         '64457bc906c125cebd4bf66b', '2023-05-23_16h49.30.176'; '608e2cb9067eb028500433d5', '2023-05-26_12h31.32.235'; '60c119b30aa5205b493541b6', '2023-05-26_14h42.15.132'; ...
                         '64071f8576c48034c00df845', '2023-05-27_01h35.27.844'; '5b33a01fa8327d0001003821', '2023-05-26_13h12.16.403'; '5f9ec66a5a97fa0748bc61a3', '2023-05-26_12h09.26.191'; ...
                         '6148c0a6e2353cbbac1cd506', '2023-05-26_10h08.10.469'; '597e0aa515837000016ae8db', '2023-05-26_17h13.06.495'; '5e9027110aacc7320bd9a84b', '2023-05-26_17h49.02.839'; ...
                         '5b4e50fb369f840001136070', '2023-05-26_17h21.53.119'; '558bb476fdf99b21155f2dbf', '2023-05-26_17h05.08.565'; '5e54367e80cd0944205b27f9', '2023-05-26_17h00.55.134'; ...
                         '57dc590ddcda780001a0e157', '2023-05-26_17h35.13.259'; '612fa816410c4ea2f08fe22c', '2023-05-26_17h21.19.703'; '5c28b31a0091e40001ca5030', '2023-05-26_17h05.03.096'; ...
                         '5be92cf1ba2782000117743e', '2023-05-26_17h00.40.846'};
    end
end
end


function mouse_data = extractMouseClosestToReport(seqMem_subj, xName, yName, tName, reportName)
% Extract the rows containing the mouse trajectory from the .csv
% (verbatim from seqMemTask_Curricula_Traj_anal.m)

    x_col = seqMem_subj.(xName);
    y_col = seqMem_subj.(yName);
    t_col = seqMem_subj.(tName);
    report_col = seqMem_subj.(reportName);

    valid_report_rows = find(~ismissing(report_col) & strlength(report_col) > 0);
    valid_mouse_rows = find(~ismissing(x_col) & ~ismissing(y_col) & ~ismissing(t_col) & ...
                            strlength(x_col) > 0 & strlength(y_col) > 0 & strlength(t_col) > 0);

    nTrial = length(valid_report_rows);

    mouse_data = struct( ...
        'rowReport', cell(nTrial,1), ...
        'rowMouse', cell(nTrial,1), ...
        'reportTrue', cell(nTrial,1), ...
        'trajectory', cell(nTrial,1) ...
    );

    for iRep = 1 : nTrial
        reportRow  = valid_report_rows(iRep);
        report_str = report_col(reportRow);

        mouse_data(iRep).rowReport  = reportRow;
        mouse_data(iRep).reportTrue = report_str;

        if isempty(valid_mouse_rows)
            mouse_data(iRep).rowMouse   = NaN;
            mouse_data(iRep).trajectory = [];
            continue;
        end

        [~, idxClosest] = min(abs(valid_mouse_rows - reportRow));
        mouseRow = valid_mouse_rows(idxClosest);
        mouse_data(iRep).rowMouse = mouseRow;

        x_arr = parseMouseArray(x_col(mouseRow));
        y_arr = parseMouseArray(y_col(mouseRow));
        t_arr = parseMouseArray(t_col(mouseRow));

        if isempty(x_arr) || isempty(y_arr) || isempty(t_arr) || ...
           length(x_arr) ~= length(y_arr) || length(x_arr) ~= length(t_arr)
            mouse_data(iRep).trajectory = [];
        else
            mouse_data(iRep).trajectory = [x_arr(:), y_arr(:), t_arr(:)];
        end
    end
end

function mouse_data = addStimPos(mouse_data, reportType, seqMem_subj, epi_rows, imgDispX_global, imgDispY_global)
% Add on-screen stimulus positions to each trial entry in mouse_data.
% (verbatim from seqMemTask_Curricula_Traj_anal.m)

for iRep = 1 : length(mouse_data)
    mouse_data(iRep).stimX   = [];
    mouse_data(iRep).stimY   = [];
    mouse_data(iRep).slotX   = [];
    mouse_data(iRep).slotY   = [];
    mouse_data(iRep).trialNo = NaN;

    reportRow = mouse_data(iRep).rowReport;
    if isempty(reportRow), continue; end

    if strcmp(reportType, 'con')
        mouse_data(iRep).stimX = imgDispX_global;
        mouse_data(iRep).stimY = imgDispY_global;
        idx = find(epi_rows <= reportRow, 1, 'last');
        if ~isempty(idx)
            tNoStr = seqMem_subj.('trialNo')(epi_rows(idx));
            if ~ismissing(tNoStr) && strlength(tNoStr) > 0
                mouse_data(iRep).trialNo = str2double(char(tNoStr));
            end
        end
        continue;
    end

    idx = find(epi_rows <= reportRow, 1, 'last');
    if isempty(idx), continue; end
    epiRow = epi_rows(idx);

    tNoStr = seqMem_subj.('trialNo')(epiRow);
    if ~ismissing(tNoStr) && strlength(tNoStr) > 0
        mouse_data(iRep).trialNo = str2double(char(tNoStr));
    end

    locX = parseMouseArray(seqMem_subj.('locSeqXTrl')(epiRow));
    locY = parseMouseArray(seqMem_subj.('locSeqYTrl')(epiRow));
    if isempty(locX) || isempty(locY), continue; end

    switch reportType
        case 'loc'
            mouse_data(iRep).stimX = locX;
            mouse_data(iRep).stimY = locY;
        case 'both'
            conX = parseMouseArray(seqMem_subj.('bothConPosXTrl')(epiRow));
            conY = parseMouseArray(seqMem_subj.('bothConPosYTrl')(epiRow));
            if isempty(conX) || isempty(conY), continue; end
            mouse_data(iRep).stimX = conX;
            mouse_data(iRep).stimY = conY;
            mouse_data(iRep).slotX = locX;
            mouse_data(iRep).slotY = locY;
    end
end
end

function mouse_data = computeDistToStim(mouse_data)
% (verbatim from seqMemTask_Curricula_Traj_anal.m)
for iRep = 1 : length(mouse_data)
    mouse_data(iRep).distToStim = [];
    mouse_data(iRep).distToSlot = [];

    traj  = mouse_data(iRep).trajectory;
    stimX = mouse_data(iRep).stimX;
    stimY = mouse_data(iRep).stimY;

    if isempty(traj) || isempty(stimX) || isempty(stimY)
        continue;
    end

    tx = traj(:, 1);
    ty = traj(:, 2);
    sx = stimX(:)';
    sy = stimY(:)';

    mouse_data(iRep).distToStim = sqrt((tx - sx).^2 + (ty - sy).^2);

    slotX = mouse_data(iRep).slotX;
    slotY = mouse_data(iRep).slotY;
    if ~isempty(slotX) && ~isempty(slotY)
        sx2 = slotX(:)';
        sy2 = slotY(:)';
        mouse_data(iRep).distToSlot = sqrt((tx - sx2).^2 + (ty - sy2).^2);
    end
end
end

function mouse_data = analyzeChoiceHesitation(mouse_data, seqMem_subj, reportType, nTrans, nDtr)
% (verbatim from seqMemTask_Curricula_Traj_anal.m)

switch reportType
    case 'con'
        ordColName  = 'conReportOrd';
        rtsColName  = 'conRTs';
        trueColName = 'conReportTrue';
        distField   = 'distToStim';
    case 'loc'
        ordColName  = 'locReportOrd';
        rtsColName  = 'locRTs';
        trueColName = 'locReportTrue';
        distField   = 'distToStim';
    case 'both'
        ordColName  = 'bothReportOrd';
        rtsColName  = 'bothRTs';
        trueColName = 'bothReportTrue';
        distField   = 'distToSlot';
end

for iRep = 1 : length(mouse_data)
    mouse_data(iRep).nResp               = 0;
    mouse_data(iRep).chosenSlots         = [];
    mouse_data(iRep).clickTimes          = [];
    mouse_data(iRep).isCorrect           = [];
    mouse_data(iRep).mindChanges         = [];
    mouse_data(iRep).mindChanged         = [];
    mouse_data(iRep).timeInChosen        = [];
    mouse_data(iRep).timeInOther         = [];
    mouse_data(iRep).closestAtClick      = [];
    mouse_data(iRep).interClickTime      = [];
    mouse_data(iRep).selSpeed            = [];
    mouse_data(iRep).dwellTime           = [];
    mouse_data(iRep).trueOrder           = [];

    traj      = mouse_data(iRep).trajectory;
    distMat   = mouse_data(iRep).(distField);
    reportRow = mouse_data(iRep).rowReport;
    distStimMat = [];
    if strcmp(reportType, 'both')
        distStimMat = mouse_data(iRep).distToStim;
    end

    if isempty(traj) || isempty(distMat) || isempty(reportRow)
        continue;
    end

    ordStr = seqMem_subj.(ordColName)(reportRow);
    rtsStr = seqMem_subj.(rtsColName)(reportRow);

    allNums = parseMouseArray(ordStr);
    repRTs  = parseMouseArray(rtsStr);

    mat = [];
    if strcmp(reportType, 'both')
        if length(allNums) ~= 2 * (nTrans + nDtr)
            continue;
        end
        mat    = reshape(allNums, 2, 6)';
        repOrd = mat(:, 2)';
    else
        repOrd = allNums;
    end

    if length(repOrd) ~= nTrans + nDtr || length(repRTs) ~= nTrans + nDtr
        continue;
    end

    [sortedOrd, slotIdx] = sort(repOrd);
    validMask = sortedOrd >= 1 & sortedOrd <= nTrans;
    nResp = sum(validMask);
    if nResp == 0
        continue;
    end

    chosenSlots = slotIdx(validMask);
    clickTimes  = repRTs(chosenSlots);

    if any(diff(clickTimes) <= 0)
        continue;
    end

    interClickTime    = NaN(1, nResp);
    interClickTime(1) = clickTimes(1);
    if nResp > 1
        interClickTime(2:end) = diff(clickTimes);
    end

    trueStr  = seqMem_subj.(trueColName)(reportRow);
    trueNums = parseMouseArray(trueStr);
    if length(trueNums) == nTrans + nDtr
        mouse_data(iRep).trueOrder = trueNums(:)';
    end

    isCorrect = NaN(1, nResp);
    if length(trueNums) == nTrans + nDtr
        switch reportType
            case {'con', 'loc'}
                for k = 1 : nResp
                    s = chosenSlots(k);
                    isCorrect(k) = double(trueNums(s) == k);
                end
            case 'both'
                for k = 1 : nResp
                    s = chosenSlots(k);
                    if s >= 1 && s <= size(mat, 1)
                        conCorrect = (mat(s, 1) == trueNums(s));
                        locCorrect = (trueNums(s) == k);
                        isCorrect(k) = double(conCorrect && locCorrect);
                    end
                end
        end
    end

    txAll = traj(:, 1);
    tyAll = traj(:, 2);
    tAxis = traj(:, 3);

    mindChanges    = NaN(1, nResp);
    mindChanged    = NaN(1, nResp);
    timeInChosen   = NaN(1, nResp);
    timeInOther    = NaN(1, nResp);
    closestAtClick = NaN(1, nResp);
    selSpeed       = NaN(1, nResp);
    dwellTime      = NaN(1, nResp);

    for iChoice = 1 : nResp
        t_end   = clickTimes(iChoice);
        t_start = -inf;
        if iChoice > 1
            t_start = clickTimes(iChoice - 1);
        end

        segMask = tAxis > t_start & tAxis <= t_end;
        if sum(segMask) < 2
            continue;
        end

        tSeg    = tAxis(segMask);
        distSeg = distMat(segMask, :);
        [~, closestIdx] = min(distSeg, [], 2);

        xSeg_full = txAll(segMask);
        ySeg_full = tyAll(segMask);
        if ~strcmp(reportType, 'both')
            pathLen = sum(sqrt(diff(xSeg_full).^2 + diff(ySeg_full).^2));
            if interClickTime(iChoice) > 0
                selSpeed(iChoice) = pathLen / interClickTime(iChoice);
            end
        end

        trimStart = 1;
        if iChoice > 1
            prevChosen = chosenSlots(iChoice - 1);
            leftPrev   = find(closestIdx ~= prevChosen, 1, 'first');
            if isempty(leftPrev)
                continue;
            end
            trimStart = leftPrev;
        end
        closestIdx = closestIdx(trimStart : end);
        tSeg       = tSeg(trimStart : end);
        xSeg_full  = xSeg_full(trimStart : end);
        ySeg_full  = ySeg_full(trimStart : end);

        if strcmp(reportType, 'both') && ~isempty(distStimMat)
            dStim = distStimMat(segMask, :);
            dStim = dStim(trimStart : end, :);
            dSlot = distSeg(trimStart : end, :);

            inInner   = min(dStim, [], 2) < min(dSlot, [], 2);
            lastInner = find(inInner, 1, 'last');
            leftDrag  = 1;
            if ~isempty(lastInner)
                leftDrag = lastInner + 1;
            end
            closestIdx = closestIdx(leftDrag : end);
            tSeg       = tSeg(leftDrag : end);

            xDrag = xSeg_full(leftDrag : end);
            yDrag = ySeg_full(leftDrag : end);
            if length(xDrag) > 1
                dragLen  = sum(sqrt(diff(xDrag).^2 + diff(yDrag).^2));
                dragTime = tSeg(end) - tSeg(1);
                if dragTime > 0
                    selSpeed(iChoice) = dragLen / dragTime;
                end
            end
        end

        if length(closestIdx) < 2
            continue;
        end

        dt     = diff(tSeg);
        totalT = sum(dt);
        if totalT == 0
            continue;
        end
        isChosen = closestIdx(1:end-1) == chosenSlots(iChoice);

        closestIdx_eff = double(closestIdx);
        if iChoice > 1
            closestIdx_eff(ismember(closestIdx, chosenSlots(1:iChoice-1))) = NaN;
        end
        pairs      = [closestIdx_eff(1:end-1), closestIdx_eff(2:end)];
        validPairs = ~isnan(pairs(:,1)) & ~isnan(pairs(:,2));
        nChanges   = sum(pairs(validPairs, 1) ~= pairs(validPairs, 2));

        mindChanges(iChoice)    = nChanges;
        mindChanged(iChoice)    = double(nChanges > 0);
        timeInChosen(iChoice)   = sum(dt(isChosen)) / totalT;
        timeInOther(iChoice)    = 1 - timeInChosen(iChoice);
        closestAtClick(iChoice) = closestIdx(end);
        dwellTime(iChoice)      = sum(dt(isChosen));
    end

    if nResp < nTrans
        pad            = NaN(1, nTrans - nResp);
        isCorrect      = [isCorrect,      pad];
        mindChanges    = [mindChanges,    pad];
        mindChanged    = [mindChanged,    pad];
        timeInChosen   = [timeInChosen,   pad];
        timeInOther    = [timeInOther,    pad];
        closestAtClick = [closestAtClick, pad];
        interClickTime = [interClickTime, pad];
        selSpeed       = [selSpeed,       pad];
        dwellTime      = [dwellTime,      pad];
    end

    mouse_data(iRep).nResp           = nResp;
    mouse_data(iRep).chosenSlots     = chosenSlots;
    mouse_data(iRep).clickTimes      = clickTimes;
    mouse_data(iRep).isCorrect       = isCorrect;
    mouse_data(iRep).mindChanges     = mindChanges;
    mouse_data(iRep).mindChanged     = mindChanged;
    mouse_data(iRep).timeInChosen    = timeInChosen;
    mouse_data(iRep).timeInOther     = timeInOther;
    mouse_data(iRep).closestAtClick  = closestAtClick;
    mouse_data(iRep).interClickTime  = interClickTime;
    mouse_data(iRep).selSpeed        = selSpeed;
    mouse_data(iRep).dwellTime       = dwellTime;
end
end

function arr = parseMouseArray(cellStr)
    if ismissing(cellStr) || strlength(cellStr) == 0
        arr = [];
        return;
    end
    cellStr = char(cellStr);
    cellStr = regexprep(cellStr, '[\[\]]', '');
    cellStr = strrep(cellStr, ',', ' ');
    nums = regexp(cellStr, '[-+]?\d*\.?\d+', 'match');
    if isempty(nums)
        arr = [];
    else
        arr = str2double(nums);
    end
end
