% seqMemTask_Curricula_Traj_anal.m
% write by XR @ April 3 2026
% Trajectory analysis for each retrieval test

% ---------- Description ----------
% YA (18-35 yrs) and OA (65-75 yrs)
% Three sub-groups within each age group:
% Interleaved, ObjectBlocked, LocationBlocked

clear
clc

%%
addpath('tight_subplot/');
addpath(genpath('HierarchicalCluster/'));
addpath(genpath('Aging-SeqMemTask/'));
% addpath(genpath('Violinplot-Matlab-master/'));
addpath('fdr_bh');

%% parameters
folder     = '/Users/ren/Projects-NeuroCode/MyExperiment/Aging-SeqMemTask';
bhvDataDir = [folder, '/AgingReplay-OnlineData'];
CLdata_folder = [bhvDataDir, '/CurriculumPaper-Data/']; % data for the summary of the curriculum learning

RChunk = 0.35;
nSes    = 8*2; % each block contain 4 sequences, the 4 unique sequences will be repeated 8 times in 8 blocks
nImgSeq = 2; % 2 unique content sequence
nPosSeq = 2; % 2 unique position sequence
nPos    = 8; % 8 positions uniformly distributed on a circle
nImg    = 8; % 8 unique images
nTrans  = 5; % each sequence contains 5 transitions; 5 transitions = 5 categories
nEpi    = nImgSeq * nPosSeq * nSes;
nDtr    = 1; % number of distractor
postTn  = 8; % trials of post-testing
trlBlc  = 8; % each block has 8 trials
uniTrl  = 4; % 4 unique trials
nBlock  = nEpi / trlBlc; % 8 blocks
nComb   = 4; % 4 unique combinations between 2 content sequence and 2 position sequence
angCir = 0 : pi/50 : 2 * pi;
centerX = 0;
centerY = 0;
xCir   = RChunk * cos(angCir) + centerX;
yCir   = RChunk * sin(angCir) + centerY;

expList = {'interleaved', 'contentBlocked', 'positionBlocked'};
nCond   = length(expList);
expId   = expList{1};
if isequal(expId, 'interleaved')
    subjList_young = {'5ad63c167f70c10001904bc5', '2023-08-30_17h17.39.428'; '5bdb51e1ba9b510001052364', '2023-08-30_15h12.00.151'; '5c4b06903566570001309394', '2023-08-30_16h55.13.543'; ...
                      '5d024a1fb58b6f001a58f74d', '2023-08-30_15h11.44.361'; '5d43404f1e6eef00011dec22', '2023-08-30_15h12.02.990'; '5ef25afb8ebcdf0b2b95d9cd', '2023-08-30_15h09.37.394'; ...
                      '5f15f96e54587538da27d452', '2023-08-30_15h40.43.668'; '5fd0c81fc79aef1882cbee94', '2023-08-30_16h25.12.136'; '60fecc838b1c231b1732cbb0', '2023-08-30_15h07.34.541'; ...
                      '601f93758d79b24eabff2e44', '2023-08-30_15h11.55.950'; '602fc5844525b3d343303a2a', '2023-08-30_14h05.56.283'; '604be8ac8e0c517878fd1d9f', '2023-08-30_14h05.21.886'; ...
                      '612ecc90331b627f7aaac5dc', '2023-08-30_16h23.19.001'; '614fca831894ddce32c1a342', '2023-08-30_15h20.32.432'; '615b5902e51bcad574d81203', '2023-08-30_15h18.25.454'; ...
                      '6016c8e7ea3f2387ae8b47d5', '2023-08-30_16h11.53.139'; '6103c08d411c6be73d9d78a7', '2023-08-30_15h20.28.394'; '6159f6b637bab134ea9bb92e', '2023-08-30_15h13.34.934'; ...
                      '61070b50a022d7360e46e985', '2023-08-30_16h08.26.937'; '61353c933f32fef782432cc7', '2023-08-30_15h10.45.788'; '605272be8568b6160f582f2e', '2023-08-30_14h38.14.393'; ...
                      '6107292e60892e4246db7425', '2023-08-30_15h12.11.729'; '61685478a9bd5239a9438f66', '2023-08-30_15h12.25.867'; '614831813dc412ccc8e2f563', '2023-08-30_15h31.25.179'};

    subjList_old   = {'5abb8dcb7ccedb0001b7f0d7', '2023-05-23_15h56.51.831'; '5be064114c6bd000013368f3', '2023-05-22_18h00.20.474'; '5c5df0475b87820001c4f21c', '2023-05-23_16h15.47.308'; ...
                      '5e9f0bc126557006ea49d1f4', '2023-05-23_16h58.16.506'; '5ea20fd571038c119083a8df', '2023-05-23_15h56.44.482'; '63b2d04ed0f53f75de4ba38e', '2023-05-23_16h30.06.501'; ...
                      '609a503448860549084c43ce', '2023-05-22_17h13.56.435'; '60534c39d754d351333bdd7c', '2023-05-23_16h15.50.361'; '597519f8262c480001bbaf8b', '2023-05-23_17h49.49.000'; ...
                      '61539b3fa541b182c0fadde1', '2023-05-26_11h37.17.532'; '574ce0a57fd0ec000db73aa6', '2023-05-26_12h33.38.572'; '55900dcffdf99b3f7aada3f5', '2023-05-26_10h08.56.439'; ...
                      '55e9aa1c735c45001043fbb6', '2023-05-26_17h56.53.674'; '64456ad3d3e7651a1dad232c', '2023-05-26_11h53.36.716'; '62aa26dd93252c8d69f7fc45', '2023-05-26_17h51.56.081'; ...
                      '5f53b958c8cfea6e2104c5b6', '2023-05-26_17h23.34.078'; '5f48e3d7f998433ac6356ad4', '2023-05-26_11h52.29.081'; '62f0f033178f89dd6f416590', '2023-05-26_17h21.29.494'; ...
                      '5c79a584670f87001646cef6', '2023-05-26_17h42.42.514'; '630be3605287a0f49b87c709', '2023-05-26_16h37.54.676'; '6121190671d1042b24d8d67b', '2023-05-26_16h16.28.267'; ...
                      '5c4cdcb14cb4630001ec4955', '2023-05-26_16h17.13.674'; '5f6e83419dd5cb3c85325fc6', '05-26-2023_16h37.34.939'}; % '63beebaa4c5884797ff00a98', '2023-05-26_17h39.52.151': attend contentBlocked

    ageList_younger    = [24, 22, 23, ...
                          25, 24, 21, ...
                          22, 23, 28, ...
                          21, 22, 23, ...
                          24, 30, 28, ...
                          27, 22, 24, ...
                          21, 20, 26, ...
                          26, 33, 28];
    genderList_younger = {'F', 'M', 'F', ...
                          'M', 'F', 'M', ... % the 4th participant: male(trans)
                          'M', 'M', 'F', ...
                          'M', 'F', 'M', ...
                          'M', 'M', 'F', ...
                          'F', 'F', 'F', ...
                          'F', 'M', 'F', ...
                          'M', 'F', 'M'}; 

    ageList_older    = [67, 68, 67, ...
                        69, 65, 66, ... % 5th participant: 64???
                        73, 73, 70, ...
                        65, 72, 72, ...
                        65, 69, 67, ...
                        67, 65, 68, ...
                        70, 72, 65, ...
                        67, 67];
    genderList_older = {'F', 'F', 'M', ...
                        'M', 'F', 'F', ...
                        'F', 'M', 'F', ...
                        'F', 'F', 'M', ...
                        'F', 'F', 'M', ...
                        'M', 'F', 'F', ...
                        'F', 'F', 'M', ...
                        'M', 'F'};

elseif isequal(expId, 'contentBlocked')
    subjList_young = {'5a6e4ecae6cc4a0001b6d38d', '2023-08-30_14h14.47.654'; '5bcdb05e1bfcbf0001d77240', '2023-08-30_15h43.03.664'; '5eceef5fa487421604c337ba', '2023-08-30_19h06.46.141'; ...
                      '5f1f1a1f443fd90bf5e2e716', '2023-08-30_15h12.16.243'; '5f4fd62570b0df0f71a35d98', '2023-08-30_16h34.02.959'; '5f5f6e9b003b2a0217bba847', '2023-08-30_16h33.19.240'; ...
                      '5f8825d4938a85280f506a83', '2023-08-30_14h12.31.867'; '60db9c9850c39eea109ef1d3', '2023-08-30_15h14.10.340'; '60f31ca80f6c233558e5a354', '2023-08-30_15h14.19.785'; ...
                      '603e2530ab9d37d734fa6ca9', '2023-08-30_15h20.00.625'; '610a5f883d6841e65838f97d', '2023-08-30_15h20.15.081'; '611d604624f673b1e62275c5', '2023-08-30_15h14.05.541'; ...
                      '612cf0efe0be33cea5c5a123', '2023-08-30_15h13.46.115'; '615cc500aab10659f82a02ab', '2023-08-30_15h20.16.812'; '616fd6aac8d209bdcd631c2a', '2023-08-30_15h15.09.944'; ...
                      '6106e9f1880fb0b44c319ced', '2023-08-30_14h13.50.009'; '6130e97d4106299f8c6120fa', '2023-08-30_15h13.59.129'; '6151e74c66fb9fb95b2f522e', '2023-08-30_15h17.08.514'; ...
                      '6159bec91e6d099cb2b032fc', '2023-08-30_15h14.49.228'; '60561bed5ea5ad8dbe3fae07', '2023-08-30_14h38.38.277'; '61698b3f8623f619b602b00b', '2023-08-30_15h07.19.062'; ...
                      '610063b7b50c4e9488e77eca', '2023-08-30_15h16.38.986'; '617091df73f7dd1c8448b3f4', '2023-08-30_15h14.45.308'; '615024818c0798f950215d49', '2023-08-30_15h13.03.877'};

    subjList_old   = {'5c964575c7f75b000167754e', '2023-05-23_16h14.31.968'; '5dfb7cbd01423f8a774d893b', '2023-05-23_18h31.24.688'; '5e8f569436e20a234f89a6f4', '2023-05-23_16h13.25.490'; ...
                      '5ea0b2cbf710490ac2644b7e', '2023-05-23_16h20.30.392'; '5ea3319a6a1a5b2a1175ed6e', '2023-05-23_16h15.41.365'; '5ea159434ac916016387488e', '2023-05-23_15h58.15.599'; ...
                      '58e79d86fe9c8c0001c77ced', '2023-05-23_16h11.20.170'; '574da26c7f1e770007f42d11', '2023-05-23_16h16.02.150'; '614c5dc3cda534db7afc2e73', '2023-05-23_16h09.12.297'; ...
                      '614f874e5b46971822dfa61a', '2023-05-23_18h55.58.563'; '6161bdbff67e4b4621b530e7', '2023-05-23_17h11.58.970'; '59eb2cc98c371000010bb196', '2023-05-26_18h01.10.451'; ...
                      '5e86c11942701c2ffda5d113', '2023-05-26_11h48.52.812'; '6086c333d6eb73cfdd564e90', '2023-05-26_17h01.07.280'; '5eb2695f1745801c7c919e35', '2023-05-26_16h36.21.594'; ...
                      '5af32f9d003f6c0001f2905b', '2023-05-26_16h27.35.772'; '61703be3748d6f5ddc01170a', '2023-05-26_17h11.26.871'; '610c67785d74ee2c4a39def8', '2023-05-26_16h24.47.208'; ...
                      '5c8ee6c36ca70b0001fe979d', '2023-05-26_11h13.31.213'; '63beebaa4c5884797ff00a98', '2023-05-26_16h33.19.754'; '62162ab683fc823e78c025e5', '2023-05-26_16h09.16.187'; ...
                      '5ab14bdeb0ca80000197e6b6', '2023-05-26_16h15.01.130'; '6452058d0baefbe199f321e0', '2023-05-26_15h56.07.802'; '5e510d0760dd0913e45370dc', '2023-05-26_15h56.04.808'; ...
                      '5c081c45fd9c080001709937', '2023-05-26_15h51.35.355'};

elseif isequal(expId, 'positionBlocked')
    subjList_young = {'5eac7f2a11f5972d923bcd8e', '2023-08-30_15h14.56.423'; '5ecfdd84dc64e1061b97e321', '2023-08-30_15h16.52.236'; '5f82fd997dab234303560326', '2023-08-30_16h05.14.338'; ...
                      '60aadeb9e6e8147089f7eced', '2023-08-30_15h10.48.242'; '60cca032f398af85575618e3', '2023-08-30_15h14.23.924'; '60d333a37d135f2ee2592457', '2023-08-30_14h06.57.777'; ...
                      '60f5db51ea1f75902fc20970', '2023-08-30_14h26.24.581'; '60f6a19c247160dce8d5a69c', '2023-08-30_17h45.57.432'; '60fb0d1ef1ea8d2bcb8166dd', '2023-08-30_16h02.38.876'; ...
                      '64c12183ab9cf635c69df81b', '2023-08-30_15h10.11.992'; '603e5d265ed1c2e3ea13ebad', '2023-08-30_15h12.42.164'; '611b87ab5cc971129768ead2', '2023-08-30_15h16.28.053'; ...
                      '611d06c0bcc92ba3d7669ef6', '2023-08-30_15h20.29.244'; '611e60a6a1fd59a57341b862', '2023-08-30_15h18.11.988'; '60940b7855b3a885f925856b', '2023-08-30_14h06.05.080'; ...
                      '61544c72236c88d054490ea6', '2023-08-30_15h06.40.921'; '64736ec17f1a9b745c8fad92', '2023-08-30_14h24.33.592'; '613615da1eacf6204ce33479', '2023-08-30_14h05.15.755'; ...
                      '64526929d8f9b780b29d4d8d', '2023-08-30_16h31.49.928'; '6175733727b1e3ce2d72dbe4', '2023-08-30_15h24.49.630'; '61412724735027d42bf53011', '2023-08-30_15h12.53.447'};

    subjList_old   = {'5a9e9fc46219a30001f54994', '2023-05-23_17h08.22.534'; '5ab8d182e1546900019b7195', '2023-05-23_16h22.50.058'; '5b017ef1293d310001023bd8', '2023-05-23_16h11.23.900'; ...
                      '5d812e3c613aa900188746a6', '2023-05-23_16h31.34.361'; '60ce6af707bcd42cbc885210', '2023-05-23_16h30.17.733'; '60f34fcae3c49524b0903a5d', '2023-05-23_16h19.52.799'; ...
                      '60f728553a37102574b585c4', '2023-05-23_11h34.06.217'; '612cc22830e71399b7a86841', '2023-05-23_16h23.00.515'; '6130a32cd30a251765045601', '2023-05-23_16h57.41.603'; ...
                      '64457bc906c125cebd4bf66b', '2023-05-23_16h49.30.176'; '608e2cb9067eb028500433d5', '2023-05-26_12h31.32.235'; '60c119b30aa5205b493541b6', '2023-05-26_14h42.15.132'; ...
                      '64071f8576c48034c00df845', '2023-05-27_01h35.27.844'; '5b33a01fa8327d0001003821', '2023-05-26_13h12.16.403'; '5f9ec66a5a97fa0748bc61a3', '2023-05-26_12h09.26.191'; ...
                      '6148c0a6e2353cbbac1cd506', '2023-05-26_10h08.10.469'; '597e0aa515837000016ae8db', '2023-05-26_17h13.06.495'; '5e9027110aacc7320bd9a84b', '2023-05-26_17h49.02.839'; ...
                      '5b4e50fb369f840001136070', '2023-05-26_17h21.53.119'; '558bb476fdf99b21155f2dbf', '2023-05-26_17h05.08.565'; '5e54367e80cd0944205b27f9', '2023-05-26_17h00.55.134'; ...
                      '57dc590ddcda780001a0e157', '2023-05-26_17h35.13.259'; '612fa816410c4ea2f08fe22c', '2023-05-26_17h21.19.703'; '5c28b31a0091e40001ca5030', '2023-05-26_17h05.03.096'; ...
                      '5be92cf1ba2782000117743e', '2023-05-26_17h00.40.846'}; %% '622a29743b7c0ca5eee56e24', '2023-05-23_16h04.13.134': this participant did nothing in reconstruction report

end
nGroup = 2; %% younger and older adults
nSub_group = nan(2, 3); % 2: YA and OA; 3: interleaved/contentBlocked/positionBlocked
nSub_group(:, 1) = [24, 23]';
nSub_group(:, 2) = [24, 25]';
nSub_group(:, 3) = [21, 25]';

%% Extracting the mouse trajectory and computing distance to each stimulus
% For each retrieval trial and each time sample in the trajectory,
% compute the Euclidean distance from the mouse to every on-screen stimulus.
%
% Content report  : 6 images in a fixed horizontal row (imgDispX / imgDispY,
%                   saved once per session in the genStim row).
% Location report : 6 circle slots (5 targets + 1 distractor) that vary per
%                   trial (locSeqXTrl / locSeqYTrl, in each episodeStart row).
% Both report     : 6 draggable images at inner-circle positions
%                   (bothConPosXTrl / bothConPosYTrl) + 6 outer-circle empty
%                   slots (locSeqXTrl / locSeqYTrl).
%
% Output per subject:
%   mouse_*.trajectory  – [nT × 3]  (x, y, t) samples during the report
%   mouse_*.stimX/Y     – [1 × 6]   on-screen positions of the 6 stimuli
%   mouse_*.slotX/Y     – [1 × 6]   slot positions (both report only)
%   mouse_*.distToStim  – [nT × 6]  distance to each stimulus at each sample
%   mouse_*.distToSlot  – [nT × 6]  distance to each slot   (both only)
%   mouse_*.trialNo     – scalar     0-based trial index from the JS

suffixWord = expId;

% Group-level containers: all_mouse_*_grp{iGrp}{iSub} = struct array of trials
all_mouse_con_grp  = cell(nGroup, 1);
all_mouse_loc_grp  = cell(nGroup, 1);
all_mouse_both_grp = cell(nGroup, 1);

for iGrp = 1 : nGroup
    if iGrp == 1
        groupName = 'younger';
        subj_list = subjList_young;
    elseif iGrp == 2
        groupName = 'older';
        subj_list = subjList_old;
    end
    subLen   = size(subj_list, 1);
    subjPath = [bhvDataDir, '/AgingReplay-v2-', suffixWord, '/', suffixWord, '-', groupName, '/'];

    all_mouse_con  = cell(subLen, 1);
    all_mouse_loc  = cell(subLen, 1);
    all_mouse_both = cell(subLen, 1);

    for iSub = 1 : subLen
        %%
        subjBv = subj_list{iSub, 1};
        subjTm = subj_list{iSub, 2};

        % ------ Read the csv file ------
        filename = [subjPath, subjBv, '_EpisodicMemoryTask-', suffixWord, '_', subjTm, '.csv'];

        opts = detectImportOptions(filename, ...
                'Delimiter', ',', ...
                'VariableNamingRule', 'preserve');
        opts = setvartype(opts, opts.VariableNames, 'string');
        seqMem_subj = readtable(filename, opts);

        % ------ Extract mouse trajectories for each retrieval type ------
        mouse_con  = extractMouseClosestToReport(seqMem_subj, 'mouseX',     'mouseY',     'mouseT',     'conReportTrue');
        mouse_loc  = extractMouseClosestToReport(seqMem_subj, 'mouseXloc',  'mouseYloc',  'mouseTloc',  'locReportTrue');
        mouse_both = extractMouseClosestToReport(seqMem_subj, 'mouseXboth', 'mouseYboth', 'mouseTboth', 'bothReportTrue');

        fprintf('[%s | Sub %02d]  con: %d   loc: %d   both: %d\n', ...
            groupName, iSub, length(mouse_con), length(mouse_loc), length(mouse_both));

        % ------ Compute content-report image positions from JS parameters ------
        % imgDispX/Y are determined by three constants hardcoded in the JS
        % (imgSize=0.15, nTrans=5, nDtr=1) and are identical for every
        % participant and trial, so we derive them directly rather than
        % reading from the CSV (genStim runs outside any TrialHandler loop,
        % so the column may never appear in the CSV output).
        imgSize_js      = 0.15;
        imgStart        = -imgSize_js * nTrans / 2;
        imgEnd          =  imgSize_js * nTrans / 2;
        iX_vec          = 0 : (nTrans + nDtr - 1);
        imgDispX_global = (imgStart - imgSize_js) + ...
                          (imgEnd + imgSize_js - (imgStart - imgSize_js)) / nTrans .* iX_vec; % [1×6]
        imgDispY_global = repmat(imgSize_js, 1, nTrans + nDtr); % [1×6], all 0.15

        % ------ Locate episode-start rows (per-trial position data lives here) ------
        % trialNo is saved only in the episodeStart routine, once per formal trial.
        epi_rows = find(~ismissing(seqMem_subj.('trialNo')) & ...
                        strlength(seqMem_subj.('trialNo')) > 0);

        % ------ Attach on-screen stimulus positions to each trajectory trial ------
        mouse_con  = addStimPos(mouse_con,  'con',  seqMem_subj, epi_rows, imgDispX_global, imgDispY_global);
        mouse_loc  = addStimPos(mouse_loc,  'loc',  seqMem_subj, epi_rows, [], []);
        mouse_both = addStimPos(mouse_both, 'both', seqMem_subj, epi_rows, [], []);

        % ------ Compute Euclidean distance from each trajectory sample to each stimulus ------
        mouse_con  = computeDistToStim(mouse_con);
        mouse_loc  = computeDistToStim(mouse_loc);
        mouse_both = computeDistToStim(mouse_both);

        % ------ Analyze mind-changing before each sequential choice ------
        mouse_con  = analyzeChoiceHesitation(mouse_con,  seqMem_subj, 'con',  nTrans, nDtr);
        mouse_loc  = analyzeChoiceHesitation(mouse_loc,  seqMem_subj, 'loc',  nTrans, nDtr);
        mouse_both = analyzeChoiceHesitation(mouse_both, seqMem_subj, 'both', nTrans, nDtr);

        % Collect per-subject results
        all_mouse_con{iSub}  = mouse_con;
        all_mouse_loc{iSub}  = mouse_loc;
        all_mouse_both{iSub} = mouse_both;
    end

    all_mouse_con_grp{iGrp}  = all_mouse_con;
    all_mouse_loc_grp{iGrp}  = all_mouse_loc;
    all_mouse_both_grp{iGrp} = all_mouse_both;
end

%% Plot choice hesitation by choice position — YA vs OA
% Two figures:
%   Fig 1 — P(mind change): binary, proportion of trials with ≥1 switch
%   Fig 2 — mean # switches: graded count, more sensitive to group differences
% Three panels each: content / location / both-reconstruction

condNames  = {'Content', 'Location', 'Reconstruction'};
grpColors  = [0.23 0.45 0.79;   % YA blue
              0.85 0.33 0.10];  % OA red
grpLabels  = {'Young', 'Older'};
dataVars   = {all_mouse_con_grp,   all_mouse_loc_grp,   all_mouse_both_grp};

plotSpec = struct( ...
    'field',  {'mindChanged',        'mindChanges'}, ...
    'ylabel', {'P(mind change)',      'Mean # switches'}, ...
    'title',  {'Choice hesitation (binary)', 'Choice hesitation (count)'} ...
);

for iFig = 1 : 2

    fig = figure('Name', plotSpec(iFig).title, 'Color', 'w', ...
                 'Units', 'centimeters', 'Position', [2, 2 + (iFig-1)*10, 24, 8]);

    for iCond = 1 : 3

        ax = subplot(1, 3, iCond);
        hold(ax, 'on');

        allGrpMeans = NaN(nGroup, nTrans);

        for iGrp = 1 : nGroup

            mouse_grp = dataVars{iCond}{iGrp};
            nSub_plt  = numel(mouse_grp);
            subMeans  = NaN(nSub_plt, nTrans);

            for iSub = 1 : nSub_plt
                md = mouse_grp{iSub};
                if isempty(md), continue; end

                mc = vertcat(md.(plotSpec(iFig).field));
                if isempty(mc), continue; end

                subMeans(iSub, :) = mean(mc, 1, 'omitnan');
            end

            nValid   = sum(~isnan(subMeans(:, 1)));
            grpMean  = mean(subMeans, 1, 'omitnan');
            grpSEM   = std(subMeans, 0, 1, 'omitnan') ./ sqrt(nValid);
            allGrpMeans(iGrp, :) = grpMean;

            xPos = 1 : nTrans;
            clr  = grpColors(iGrp, :);

            xFill = [xPos, fliplr(xPos)];
            yFill = [grpMean + grpSEM, fliplr(grpMean - grpSEM)];
            fill(ax, xFill, yFill, clr, 'FaceAlpha', 0.15, 'EdgeColor', 'none', ...
                 'HandleVisibility', 'off');

            plot(ax, xPos, grpMean, '-o', ...
                'Color', clr, 'LineWidth', 1.8, 'MarkerSize', 6, ...
                'MarkerFaceColor', clr, 'DisplayName', grpLabels{iGrp});
        end

        xlabel(ax, 'Choice position');
        if iCond == 1
            ylabel(ax, plotSpec(iFig).ylabel);
        end
        title(ax, condNames{iCond});
        xlim(ax, [0.5, nTrans + 0.5]);
        xticks(ax, 1 : nTrans);

        % Auto y-limits with 10% padding — avoids compressing real differences
        yAll = allGrpMeans(~isnan(allGrpMeans));
        if ~isempty(yAll)
            yPad = max(0.1 * range(yAll), 0.02);
            ylim(ax, [max(0, min(yAll) - yPad), max(yAll) + yPad]);
        end

        set(ax, 'Box', 'off', 'FontSize', 11, 'TickDir', 'out');
        if iCond == 3
            legend(ax, grpLabels, 'Location', 'best', 'Box', 'off', 'FontSize', 10);
        end
    end

    sgtitle([plotSpec(iFig).title, ' — ', expId], 'FontSize', 13, 'FontWeight', 'bold');
end

%% Plot fraction of deliberation time closest to the chosen stimulus — YA vs OA
% timeInChosen: fraction of the deliberation window (after cursor leaves the
% previous stimulus) where the cursor is nearest to the eventually chosen stimulus.
% timeInOther = 1 - timeInChosen is its complement and is not plotted separately.
% Dashed grey line: 1/(nTrans+nDtr) = 1/6 chance level (uniform cursor wandering).

chanceLvl = 1 / (nTrans + nDtr);   % = 1/6 ≈ 0.167

figure('Name', 'Time closest to chosen stimulus', 'Color', 'w', ...
       'Units', 'centimeters', 'Position', [2, 22, 24, 8]);

for iCond = 1 : 3

    ax = subplot(1, 3, iCond);
    hold(ax, 'on');

    % Chance reference
    plot(ax, [0.5, nTrans+0.5], [chanceLvl, chanceLvl], '--', ...
         'Color', [0.6 0.6 0.6], 'LineWidth', 1, 'HandleVisibility', 'off');

    allGrpMeans_chosen = NaN(nGroup, nTrans);

    for iGrp = 1 : nGroup

        mouse_grp = dataVars{iCond}{iGrp};
        nSub_plt  = numel(mouse_grp);
        subChosen = NaN(nSub_plt, nTrans);

        for iSub = 1 : nSub_plt
            md = mouse_grp{iSub};
            if isempty(md), continue; end

            mc = vertcat(md.timeInChosen);
            if isempty(mc), continue; end

            subChosen(iSub, :) = mean(mc, 1, 'omitnan');
        end

        nValid     = sum(~isnan(subChosen(:, 1)));
        meanChosen = mean(subChosen, 1, 'omitnan');
        semChosen  = std(subChosen,  0, 1, 'omitnan') ./ sqrt(nValid);
        allGrpMeans_chosen(iGrp, :) = meanChosen;

        xPos = 1 : nTrans;
        clr  = grpColors(iGrp, :);

        xFill = [xPos, fliplr(xPos)];
        fill(ax, xFill, [meanChosen+semChosen, fliplr(meanChosen-semChosen)], ...
             clr, 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');

        plot(ax, xPos, meanChosen, '-o', 'Color', clr, 'LineWidth', 1.8, ...
            'MarkerSize', 6, 'MarkerFaceColor', clr, 'DisplayName', grpLabels{iGrp});
    end

    xlabel(ax, 'Choice position');
    if iCond == 1
        ylabel(ax, 'Fraction of deliberation time (chosen)');
    end
    title(ax, condNames{iCond});
    xlim(ax, [0.5, nTrans + 0.5]);
    xticks(ax, 1 : nTrans);

    yAll = allGrpMeans_chosen(~isnan(allGrpMeans_chosen));
    if ~isempty(yAll)
        yPad = max(0.1 * range([yAll; chanceLvl]), 0.02);
        ylim(ax, [max(0, min([yAll; chanceLvl]) - yPad), ...
                  min(1, max([yAll; chanceLvl]) + yPad)]);
    end

    set(ax, 'Box', 'off', 'FontSize', 11, 'TickDir', 'out');
    if iCond == 3
        legend(ax, grpLabels, 'Location', 'best', 'Box', 'off', 'FontSize', 10);
    end
end

sgtitle(['Time closest to chosen stimulus — ', expId], ...
        'FontSize', 13, 'FontWeight', 'bold');

%% Accuracy-conditioned mind changes and dwell time — YA vs OA
% For each retrieval trial, mindChanges and timeInChosen are averaged
% separately over correct clicks and incorrect clicks (collapsed across
% all nTrans transitions). This figure shows whether hesitation and
% dwell-time differ between correct and incorrect choices.
%
% Layout: 2 rows (mindChanges | timeInChosen) × 3 cols (content | loc | both)
% Each panel: 2 grouped bars [Correct, Incorrect] × [YA, OA]

accFields  = {'mindChanges_corr', 'mindChanges_incorr'; ...
              'timeInChosen_corr','timeInChosen_incorr'};
rowLabels  = {'Mean # switches', 'Dwell time (chosen)'};
accLabels  = {'Correct', 'Incorrect'};
corrColors = [0 0 0; 0.6 0.6 0.6];   % correct=dark, incorrect=light

figure('Name', 'Accuracy-conditioned hesitation', 'Color', 'w', ...
       'Units', 'centimeters', 'Position', [28, 2, 24, 14]);

for iRow = 1 : 2         % metric: mindChanges or timeInChosen
    for iCond = 1 : 3    % condition: content / location / both

        ax = subplot(2, 3, (iRow-1)*3 + iCond);
        hold(ax, 'on');

        % Aggregate: for each group, collect [nSub × 2] matrix (corr, incorr)
        grpMeans = NaN(nGroup, 2);
        grpSEMs  = NaN(nGroup, 2);
        allSubVals = cell(nGroup, 2);

        for iGrp = 1 : nGroup
            mouse_grp = dataVars{iCond}{iGrp};
            nSub_plt  = numel(mouse_grp);

            subCorr   = NaN(nSub_plt, 1);
            subIncorr = NaN(nSub_plt, 1);

            for iSub = 1 : nSub_plt
                md = mouse_grp{iSub};
                if isempty(md), continue; end
                subCorr(iSub)   = mean([md.(accFields{iRow,1})], 'omitnan');
                subIncorr(iSub) = mean([md.(accFields{iRow,2})], 'omitnan');
            end

            nV = sum(~isnan(subCorr));
            grpMeans(iGrp, :) = [mean(subCorr,'omitnan'),   mean(subIncorr,'omitnan')];
            grpSEMs(iGrp, :)  = [std(subCorr,0,'omitnan'),  std(subIncorr,0,'omitnan')] ./ sqrt(nV);
            allSubVals{iGrp,1} = subCorr;
            allSubVals{iGrp,2} = subIncorr;
        end

        % Bar positions: [YA_corr, OA_corr, YA_incorr, OA_incorr]
        xCorr   = [1, 1.45];   % YA and OA positions for correct
        xIncorr = [2.3, 2.75]; % YA and OA positions for incorrect

        xAll = [xCorr, xIncorr];
        means_all = [grpMeans(1,1), grpMeans(2,1), grpMeans(1,2), grpMeans(2,2)];
        sems_all  = [grpSEMs(1,1),  grpSEMs(2,1),  grpSEMs(1,2),  grpSEMs(2,2)];
        colors_all = [grpColors(1,:); grpColors(2,:); grpColors(1,:); grpColors(2,:)];
        alpha_all  = [1, 1, 0.45, 0.45];  % correct=solid, incorrect=faded

        for ib = 1 : 4
            bar(ax, xAll(ib), means_all(ib), 0.38, ...
                'FaceColor', colors_all(ib,:), 'FaceAlpha', alpha_all(ib), ...
                'EdgeColor', 'none', 'HandleVisibility', 'off');
            errorbar(ax, xAll(ib), means_all(ib), sems_all(ib), ...
                'k', 'LineWidth', 1.2, 'CapSize', 4, 'HandleVisibility', 'off');
        end

        % Individual subject dots (jittered)
        rng(0);
        subXAll   = {allSubVals{1,1}, allSubVals{2,1}, allSubVals{1,2}, allSubVals{2,2}};
        for ib = 1 : 4
            vals = subXAll{ib};
            vals = vals(~isnan(vals));
            scatter(ax, xAll(ib) + (rand(size(vals))-0.5)*0.15, vals, 18, ...
                colors_all(ib,:), 'filled', 'MarkerFaceAlpha', 0.4, ...
                'HandleVisibility', 'off');
        end

        % Legend proxy patches (only on last panel)
        if iCond == 3 && iRow == 1
            patch(ax, NaN, NaN, grpColors(1,:), 'DisplayName', grpLabels{1}, 'EdgeColor','none');
            patch(ax, NaN, NaN, grpColors(2,:), 'DisplayName', grpLabels{2}, 'EdgeColor','none');
            legend(ax, 'Location', 'best', 'Box', 'off', 'FontSize', 9);
        end

        % Axis decoration
        set(ax, 'XTick', [mean(xCorr), mean(xIncorr)], ...
                'XTickLabel', accLabels, 'Box', 'off', ...
                'FontSize', 10, 'TickDir', 'out');
        xlim(ax, [0.6, 3.15]);
        if iCond == 1, ylabel(ax, rowLabels{iRow}); end
        if iRow == 1,  title(ax, condNames{iCond}); end

        yAll = means_all(~isnan(means_all));
        if ~isempty(yAll)
            yPad = max(0.15 * range(yAll), 0.02);
            ylim(ax, [max(0, min(yAll) - yPad), max(yAll) + yPad]);
        end
    end
end

sgtitle(['Correct vs incorrect — ', expId], 'FontSize', 13, 'FontWeight', 'bold');


%% Example participant: mouse trajectory and distance to stimuli over time
% Fig 5 — x-y trajectory colored by time (cool colormap); stimuli/slots as squares
% Fig 6 — distance to each stimulus/slot over time; one colored line per stimulus
%
% Example trial selection: first YA subject that has valid trajectory + distance
% data for all three retrieval conditions; first valid trial per condition.

imgSize_plot = 0.15;   % image width in PsychoJS normalized units
sqHW         = imgSize_plot / 2;   % half-width for drawn squares

% ---- Select example participant and trial (edit these four lines) ----
% exGrp: 1 = younger adults, 2 = older adults
% exSub: subject index within the group (1-based)
% exTrial*: trial index for each retrieval type (1-based); set to 0 to
%           auto-pick the first valid trial for that condition
exGrp       = 2;
exSub       = 5;
exTrialCon  = 0;
exTrialLoc  = 0;
exTrialBoth = 0;

% Auto-pick first valid trial for any condition left at 0
md_c = all_mouse_con_grp{exGrp}{exSub};
md_l = all_mouse_loc_grp{exGrp}{exSub};
md_b = all_mouse_both_grp{exGrp}{exSub};
if exTrialCon  == 0
    exTrialCon  = find(~cellfun(@isempty, {md_c.trajectory}) & ...
                       ~cellfun(@isempty, {md_c.distToStim}), 1);
end
if exTrialLoc  == 0
    exTrialLoc  = find(~cellfun(@isempty, {md_l.trajectory}) & ...
                       ~cellfun(@isempty, {md_l.distToStim}), 1);
end
if exTrialBoth == 0
    exTrialBoth = find(~cellfun(@isempty, {md_b.trajectory}) & ...
                       ~cellfun(@isempty, {md_b.distToSlot}), 1);
end

if isempty(exTrialCon) || isempty(exTrialLoc) || isempty(exTrialBoth)
    warning('No valid trial found for one or more conditions (grp=%d, sub=%d); skipping trajectory figures.', exGrp, exSub);
else
    exData = { all_mouse_con_grp{exGrp}{exSub}(exTrialCon), ...
               all_mouse_loc_grp{exGrp}{exSub}(exTrialLoc), ...
               all_mouse_both_grp{exGrp}{exSub}(exTrialBoth) };
    % For 'both', analysis uses distance to target slots; con/loc use distToStim
    distFieldEx = {'distToStim', 'distToStim', 'distToSlot'};

    nStim    = nTrans + nDtr;          % 6
    stimCmap = lines(nStim);           % 6 distinct colors, one per stimulus/slot

    %% Figure 5 — Mouse trajectory colored by time
    figure('Name', 'Example trajectory', 'Color', 'w', ...
           'Units', 'centimeters', 'Position', [2, 2, 26, 9]);

    for iCond = 1 : 3
        ax = subplot(1, 3, iCond);
        hold(ax, 'on');

        md   = exData{iCond};
        traj = md.trajectory;   % [nT×3]: x, y, t

        if isempty(traj)
            title(ax, condNames{iCond}); continue;
        end

        xT    = traj(:, 1);
        yT    = traj(:, 2);
        tT    = traj(:, 3);
        tNorm = (tT - tT(1)) / max(tT(end) - tT(1), eps);

        % Trajectory points colored by normalized time (early=blue, late=red)
        scatter(ax, xT, yT, 10, tNorm, 'filled', 'MarkerFaceAlpha', 0.8);
        colormap(ax, 'cool');
        cb = colorbar(ax);
        cb.Label.String = 'Time (norm.)';
        caxis(ax, [0, 1]);

        % Draw stimulus positions as colored squares (solid border)
        stimX   = md.stimX;
        stimY   = md.stimY;
        trueOrd = md.trueOrder;   % [1×6]: true click order per slot; nTrans+1 = distractor
        if ~isempty(stimX)
            for iS = 1 : length(stimX)
                rectangle(ax, 'Position', ...
                    [stimX(iS)-sqHW, stimY(iS)-sqHW, 2*sqHW, 2*sqHW], ...
                    'EdgeColor', stimCmap(iS,:), 'LineWidth', 2, 'FaceColor', 'none');
                if ~isempty(trueOrd) && iS <= length(trueOrd)
                    tOrdVal = trueOrd(iS);
                    if tOrdVal == nTrans + nDtr
                        lbl = 'dtr';
                    else
                        lbl = num2str(tOrdVal);
                    end
                else
                    lbl = num2str(iS);
                end
                text(ax, stimX(iS), stimY(iS) - sqHW - 0.02, lbl, ...
                    'Color', stimCmap(iS,:), 'FontSize', 9, 'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                    'BackgroundColor', 'w', 'Margin', 1);
            end
        end

        % For 'both': also draw target slot positions as dashed squares
        if iCond == 3 && ~isempty(md.slotX)
            for iS = 1 : length(md.slotX)
                rectangle(ax, 'Position', ...
                    [md.slotX(iS)-sqHW, md.slotY(iS)-sqHW, 2*sqHW, 2*sqHW], ...
                    'EdgeColor', stimCmap(iS,:), 'LineWidth', 1.5, ...
                    'FaceColor', 'none', 'LineStyle', '--');
            end
        end

        % Mark click moments with downward triangles; label by click order
        clickT = md.clickTimes;
        if ~isempty(clickT)
            for iK = 1 : length(clickT)
                [~, tidx] = min(abs(tT - clickT(iK)));
                plot(ax, xT(tidx), yT(tidx), 'v', ...
                    'Color', 'k', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
            end
        end

        xlabel(ax, 'x (norm.)');
        if iCond == 1, ylabel(ax, 'y (norm.)'); end
        title(ax, condNames{iCond}, 'FontSize', 11);
        axis(ax, 'equal');
        set(ax, 'Box', 'off', 'FontSize', 11, 'TickDir', 'out');
    end

    sgtitle(sprintf('Mouse trajectory — YA sub %d, trial %d/%d/%d — %s', ...
                    exSub, exTrialCon, exTrialLoc, exTrialBoth, expId), ...
            'FontSize', 12, 'FontWeight', 'bold');

    %% Figure 6 — Distance to each stimulus/slot over time
    % Each colored line = distance from mouse to one stimulus (col index = stim ID).
    % For the 'both' condition distances are to the target slots (distToSlot),
    % matching the metric used in the hesitation analysis.
    % Dashed vertical lines mark click times; 'C1'–'C5' labels each click.

    figure('Name', 'Distance to stimuli over time', 'Color', 'w', ...
           'Units', 'centimeters', 'Position', [2, 14, 26, 9]);

    for iCond = 1 : 3
        ax = subplot(1, 3, iCond);
        hold(ax, 'on');

        md      = exData{iCond};
        traj    = md.trajectory;
        distMat = md.(distFieldEx{iCond});   % [nT×6]

        if isempty(traj) || isempty(distMat)
            title(ax, condNames{iCond}); continue;
        end

        tT   = traj(:, 3);
        tOff = (tT - tT(1)) / max(tT(end) - tT(1), eps);   % normalized 0–1

        % Distance to each stimulus as a separate line, labeled by true order
        trueOrd = md.trueOrder;   % [1×6]: true click order per slot; nTrans+1 = distractor
        for iS = 1 : size(distMat, 2)
            if ~isempty(trueOrd) && iS <= length(trueOrd)
                tOrdVal = trueOrd(iS);
                if tOrdVal == nTrans + nDtr
                    legLabel = sprintf('S%d (dtr)', iS);
                else
                    legLabel = sprintf('S%d (true=%d)', iS, tOrdVal);
                end
            else
                legLabel = ['S', num2str(iS)];
            end
            plot(ax, tOff, distMat(:, iS), '-', ...
                'Color', stimCmap(iS,:), 'LineWidth', 1.3, ...
                'DisplayName', legLabel);
        end

        % Vertical dashed lines at click times
        clickT = md.clickTimes;
        yTop   = max(distMat(:)) * 1.1;
        if ~isempty(clickT)
            for iK = 1 : length(clickT)
                tClick = (clickT(iK) - tT(1)) / max(tT(end) - tT(1), eps);
                plot(ax, [tClick, tClick], [0, yTop], '--k', ...
                    'LineWidth', 0.8, 'HandleVisibility', 'off');
                text(ax, tClick, yTop * 0.96, ['C', num2str(iK)], ...
                    'FontSize', 7, 'HorizontalAlignment', 'center', 'Color', 'k');
            end
        end

        xlabel(ax, 'Time (norm.)');
        if iCond == 1, ylabel(ax, 'Distance (norm. units)'); end
        title(ax, condNames{iCond}, 'FontSize', 11);
        ylim(ax, [0, yTop]);
        set(ax, 'Box', 'off', 'FontSize', 11, 'TickDir', 'out');
        legend(ax, 'Location', 'northeast', 'Box', 'off', 'FontSize', 8);
    end

    sgtitle(sprintf('Distance to stimuli — YA sub %d, trial %d/%d/%d — %s', ...
                    exSub, exTrialCon, exTrialLoc, exTrialBoth, expId), ...
            'FontSize', 12, 'FontWeight', 'bold');
end


%% ------ Define the function ------
function mouse_data = extractMouseClosestToReport(seqMem_subj, xName, yName, tName, reportName)

    x_col = seqMem_subj.(xName);
    y_col = seqMem_subj.(yName);
    t_col = seqMem_subj.(tName);
    report_col = seqMem_subj.(reportName);

    % rows with valid report
    valid_report_rows = find(~ismissing(report_col) & strlength(report_col) > 0);

    % rows with valid mouse trajectory (raw availability only)
    valid_mouse_rows = find(~ismissing(x_col) & ~ismissing(y_col) & ~ismissing(t_col) & ...
                            strlength(x_col) > 0 & strlength(y_col) > 0 & strlength(t_col) > 0);

    nTrial = length(valid_report_rows);

    % -------- PREALLOCATE (important) --------
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

        % ---------- find closest mouse row ----------
        if isempty(valid_mouse_rows)
            mouse_data(iRep).rowMouse   = NaN;
            mouse_data(iRep).trajectory = [];
            continue;
        end

        [~, idxClosest] = min(abs(valid_mouse_rows - reportRow));
        mouseRow = valid_mouse_rows(idxClosest);

        mouse_data(iRep).rowMouse = mouseRow;

        % ---------- parse ----------
        x_arr = parseMouseArray(x_col(mouseRow));
        y_arr = parseMouseArray(y_col(mouseRow));
        t_arr = parseMouseArray(t_col(mouseRow));

        % ---------- validity check ----------
        if isempty(x_arr) || isempty(y_arr) || isempty(t_arr) || ...
           length(x_arr) ~= length(y_arr) || length(x_arr) ~= length(t_arr)

            % DO NOT SKIP — mark as missing
            mouse_data(iRep).trajectory = [];

        else
            mouse_data(iRep).trajectory = [x_arr(:), y_arr(:), t_arr(:)];
        end
    end
end

% function mouse_data = extractMouseClosestToReport(seqMem_subj, xName, yName, tName, reportName)
% 
%     x_col = seqMem_subj.(xName);
%     y_col = seqMem_subj.(yName);
%     t_col = seqMem_subj.(tName);
%     report_col = seqMem_subj.(reportName);
% 
%     % rows with valid report
%     valid_report_rows = find(~ismissing(report_col) & strlength(report_col) > 0);
% 
%     % rows with valid mouse trajectory
%     valid_mouse_rows = find(~ismissing(x_col) & ~ismissing(y_col) & ~ismissing(t_col) & ...
%                             strlength(x_col) > 0 & strlength(y_col) > 0 & strlength(t_col) > 0);
% 
%     mouse_data = struct( ...
%         'rowReport', {}, ...
%         'rowMouse', {}, ...
%         'reportTrue', {}, ...
%         'trajectory', {} ...
%     );
% 
%     count = 1;
% 
%     for iRep = 1:length(valid_report_rows)
% 
%         reportRow = valid_report_rows(iRep);
%         report_str = report_col(reportRow);
% 
%         % find mouse row closest to this report row
%         [~, idxClosest] = min(abs(valid_mouse_rows - reportRow));
%         mouseRow = valid_mouse_rows(idxClosest);
% 
%         x_arr = parseMouseArray(x_col(mouseRow));
%         y_arr = parseMouseArray(y_col(mouseRow));
%         t_arr = parseMouseArray(t_col(mouseRow));
% 
%         if ~isempty(x_arr) && length(x_arr)==length(y_arr) && length(x_arr)==length(t_arr)
% 
%             mouse_data(count).rowReport  = reportRow;
%             mouse_data(count).rowMouse   = mouseRow;
%             mouse_data(count).reportTrue = report_str;
%             mouse_data(count).trajectory = [x_arr(:), y_arr(:), t_arr(:)];
% 
%             count = count + 1;
%         end
%     end
% end


function mouse_data = addStimPos(mouse_data, reportType, seqMem_subj, epi_rows, imgDispX_global, imgDispY_global)
% Add on-screen stimulus positions to each trial entry in mouse_data.
%
% Strategy: for each trial's report row, find the last episodeStart row
% (identified by a non-empty trialNo column) that precedes it — that row
% holds the per-trial position columns saved by the JS at trial onset.
%
% New fields added to each struct element:
%   .stimX / .stimY  – [1×6] positions of the 6 clickable / draggable stimuli
%                       con : fixed horizontal image slots (imgDispX/Y)
%                       loc : outer-circle slot positions (locSeqXTrl/Y)
%                       both: inner-circle draggable image positions (bothConPosXTrl/Y)
%   .slotX / .slotY  – [1×6] outer-circle slot positions (both report only, else [])
%   .trialNo         – scalar  0-based trial index from the JS

for iRep = 1 : length(mouse_data)

    % Defaults
    mouse_data(iRep).stimX   = [];
    mouse_data(iRep).stimY   = [];
    mouse_data(iRep).slotX   = [];
    mouse_data(iRep).slotY   = [];
    mouse_data(iRep).trialNo = NaN;

    reportRow = mouse_data(iRep).rowReport;
    if isempty(reportRow), continue; end

    % --- Content report: positions are identical every trial ---
    if strcmp(reportType, 'con')
        mouse_data(iRep).stimX = imgDispX_global;
        mouse_data(iRep).stimY = imgDispY_global;
        % trialNo: find the episodeStart row that precedes this report
        idx = find(epi_rows <= reportRow, 1, 'last');
        if ~isempty(idx)
            tNoStr = seqMem_subj.('trialNo')(epi_rows(idx));
            if ~ismissing(tNoStr) && strlength(tNoStr) > 0
                mouse_data(iRep).trialNo = str2double(char(tNoStr));
            end
        end
        continue;
    end

    % --- Location and Both reports: per-trial positions from episodeStart row ---
    idx = find(epi_rows <= reportRow, 1, 'last');
    if isempty(idx), continue; end
    epiRow = epi_rows(idx);

    % Record trial number
    tNoStr = seqMem_subj.('trialNo')(epiRow);
    if ~ismissing(tNoStr) && strlength(tNoStr) > 0
        mouse_data(iRep).trialNo = str2double(char(tNoStr));
    end

    % Outer-circle slot positions (shared by both loc and both reports)
    locX = parseMouseArray(seqMem_subj.('locSeqXTrl')(epiRow));  % [1×6]
    locY = parseMouseArray(seqMem_subj.('locSeqYTrl')(epiRow));  % [1×6]
    if isempty(locX) || isempty(locY), continue; end

    switch reportType
        case 'loc'
            % Participant clicks the empty circle slots
            mouse_data(iRep).stimX = locX;
            mouse_data(iRep).stimY = locY;

        case 'both'
            % Draggable images start at inner-circle positions
            conX = parseMouseArray(seqMem_subj.('bothConPosXTrl')(epiRow)); % [1×6]
            conY = parseMouseArray(seqMem_subj.('bothConPosYTrl')(epiRow)); % [1×6]
            if isempty(conX) || isempty(conY), continue; end
            mouse_data(iRep).stimX = conX;   % inner-circle image origins
            mouse_data(iRep).stimY = conY;
            mouse_data(iRep).slotX = locX;   % outer-circle target slots
            mouse_data(iRep).slotY = locY;
    end
end
end


function mouse_data = computeDistToStim(mouse_data)
% Compute Euclidean distance from every trajectory sample to every stimulus.
%
% For each trial, uses:
%   .trajectory  – [nT × 3]  columns x, y, t
%   .stimX/Y     – [1 × 6]   stimulus positions
%   .slotX/Y     – [1 × 6]   slot positions (both report only)
%
% Adds:
%   .distToStim  – [nT × 6]  distance to each stimulus at every sample
%   .distToSlot  – [nT × 6]  distance to each slot   (both report only)
%
% Column order in distToStim / distToSlot matches the slot order A–F as
% stored in stimX/Y (i.e., the JS display order for that trial).

for iRep = 1 : length(mouse_data)

    mouse_data(iRep).distToStim = []; % Object retrieval 
    mouse_data(iRep).distToSlot = [];

    traj  = mouse_data(iRep).trajectory;
    stimX = mouse_data(iRep).stimX;
    stimY = mouse_data(iRep).stimY;

    if isempty(traj) || isempty(stimX) || isempty(stimY)
        continue;
    end

    tx = traj(:, 1);   % [nT × 1]  mouse x
    ty = traj(:, 2);   % [nT × 1]  mouse y
    sx = stimX(:)';    % [1 × nStim]  broadcast across rows
    sy = stimY(:)';

    % Euclidean distance: broadcasting gives [nT × nStim]
    mouse_data(iRep).distToStim = sqrt((tx - sx).^2 + (ty - sy).^2);

    % Slot distances for the both report
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
% For each retrieval trial, segment the mouse trajectory by click time,
% find which stimulus/slot was closest (argmin distToStim or distToSlot)
% at each sample within that segment, and count how many times the
% closest-stimulus identity switches before the participant's click.
%
% Per-click fields [1×nTrans]:
%   .chosenSlots    — 1-based stimulus indices in click order
%   .clickTimes     — RT (s) for each of the nTrans choices
%   .isCorrect      — 1 if click matched true sequence order, 0 if not, NaN if unknown
%   .mindChanges    — # closest-stimulus identity switches per deliberation window
%   .mindChanged    — binary: any switch (0/1)
%   .timeInChosen   — time-weighted fraction of deliberation time closest to chosen stim
%   .timeInOther    — 1 - timeInChosen
%   .closestAtClick — closest stim index at moment of click
%
% Accuracy-conditioned scalars (collapsed across all transitions per trial):
%   .mindChanges_corr    — mean mindChanges over correct clicks
%   .mindChanges_incorr  — mean mindChanges over incorrect clicks
%   .timeInChosen_corr   — mean timeInChosen over correct clicks
%   .timeInChosen_incorr — mean timeInChosen over incorrect clicks

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

    % Default empty outputs
    mouse_data(iRep).chosenSlots         = [];
    mouse_data(iRep).clickTimes          = [];
    mouse_data(iRep).isCorrect           = [];
    mouse_data(iRep).mindChanges         = [];
    mouse_data(iRep).mindChanged         = [];
    mouse_data(iRep).timeInChosen        = [];
    mouse_data(iRep).timeInOther         = [];
    mouse_data(iRep).closestAtClick      = [];
    mouse_data(iRep).mindChanges_corr    = NaN;
    mouse_data(iRep).mindChanges_incorr  = NaN;
    mouse_data(iRep).timeInChosen_corr   = NaN;
    mouse_data(iRep).timeInChosen_incorr = NaN;
    mouse_data(iRep).trueOrder           = [];   % [1×(nTrans+nDtr)] true order per slot

    traj      = mouse_data(iRep).trajectory;
    distMat   = mouse_data(iRep).(distField);
    reportRow = mouse_data(iRep).rowReport;

    if isempty(traj) || isempty(distMat) || isempty(reportRow)
        continue;
    end

    ordStr = seqMem_subj.(ordColName)(reportRow);
    rtsStr = seqMem_subj.(rtsColName)(reportRow);

    allNums = parseMouseArray(ordStr);
    repRTs  = parseMouseArray(rtsStr);

    mat = [];   % [nSlot×2] for 'both': col1=content order, col2=location order
    if strcmp(reportType, 'both')
        % bothReportOrd is a flattened [6×2] JS array (12 numbers).
        % reshape(., 2, 6)' → [6×2]: col1=content order, col2=location order per slot.
        if length(allNums) ~= 12
            continue;
        end
        mat    = reshape(allNums, 2, 6)';  % [6×2]
        repOrd = mat(:, 2)';               % [1×6]: location click order per slot
    else
        repOrd = allNums;
    end

    if length(repOrd) ~= 6 || length(repRTs) ~= 6
        continue;
    end

    % Sort slots by click order (1 = first chosen, 2 = second, …)
    [sortedOrd, slotIdx] = sort(repOrd);
    validMask = sortedOrd >= 1 & sortedOrd <= nTrans;
    if sum(validMask) ~= nTrans
        continue;
    end

    chosenSlots = slotIdx(validMask)';   % [nTrans×1], 1-based stimulus indices
    clickTimes  = repRTs(chosenSlots);   % [nTrans×1], RTs in click order

    % Determine per-click correctness.
    % con/loc: click k correct iff trueNums(chosen slot) == k
    %          (distractor has trueNums = nTrans+1, never equals k=1..nTrans)
    % both: requires BOTH content AND location correct simultaneously:
    %          content: mat(s,1) == s  [content order at slot s equals slot index]
    %          location: s == k        [the slot dropped at position k equals slot index]
    %          (mirrors: bothRep_i(1,j)==j && bothRep_i(2,j)==j in the summary script)
    trueStr  = seqMem_subj.(trueColName)(reportRow);
    trueNums = parseMouseArray(trueStr);
    if length(trueNums) == nTrans + nDtr
        mouse_data(iRep).trueOrder = trueNums(:)';
    end
    isCorrect = NaN(1, nTrans);
    if length(trueNums) == nTrans + nDtr
        switch reportType
            case {'con', 'loc'}
                for k = 1 : nTrans
                    s = chosenSlots(k);
                    isCorrect(k) = double(trueNums(s) == k);
                end
            case 'both'
                for k = 1 : nTrans
                    s = chosenSlots(k);
                    if s >= 1 && s <= size(mat, 1)
                        conCorrect = (mat(s, 1) == s);
                        locCorrect = (s == k);
                        isCorrect(k) = double(conCorrect && locCorrect);
                    end
                end
        end
    end

    tAxis = traj(:, 3);  % time column of trajectory

    mindChanges    = NaN(1, nTrans);
    mindChanged    = NaN(1, nTrans);
    timeInChosen   = NaN(1, nTrans);
    timeInOther    = NaN(1, nTrans);
    closestAtClick = NaN(1, nTrans);

    for iChoice = 1 : nTrans
        t_end   = clickTimes(iChoice);
        t_start = 0;
        if iChoice > 1
            t_start = clickTimes(iChoice - 1);
        end

        segMask = tAxis > t_start & tAxis <= t_end;
        if sum(segMask) < 2
            continue;
        end

        tSeg    = tAxis(segMask);                 % [nSamp × 1] sample timestamps
        distSeg = distMat(segMask, :);            % [nSamp × nStim]
        [~, closestIdx] = min(distSeg, [], 2);    % [nSamp × 1]

        % For choices after the first: the cursor may linger on the just-clicked
        % stimulus at the start of the window (inertia, not deliberation).
        % Trim the leading portion where the previously chosen stimulus is still
        % closest — deliberation about the next choice only begins once the
        % cursor leaves that territory.
        if iChoice > 1
            prevChosen = chosenSlots(iChoice - 1);
            leftPrev   = find(closestIdx ~= prevChosen, 1, 'first');
            if isempty(leftPrev)
                % Cursor never left previous stimulus → nothing to analyse
                continue;
            end
            closestIdx = closestIdx(leftPrev : end);
            tSeg       = tSeg(leftPrev : end);
        end

        if length(closestIdx) < 2
            continue;
        end

        % Time-weighted metrics: each sample k "owns" the interval [tSeg(k), tSeg(k+1)].
        % dt(k) is that interval's duration; closestIdx(k) is the nearest stimulus
        % throughout it. This accounts for variable frame rates across samples.
        dt       = diff(tSeg);                              % [nSamp-1 × 1]
        totalT   = sum(dt);
        isChosen = closestIdx(1:end-1) == chosenSlots(iChoice);

        nChanges = sum(diff(closestIdx) ~= 0);
        mindChanges(iChoice)    = nChanges;
        mindChanged(iChoice)    = double(nChanges > 0);
        timeInChosen(iChoice)   = sum(dt(isChosen)) / totalT;
        timeInOther(iChoice)    = 1 - timeInChosen(iChoice);
        closestAtClick(iChoice) = closestIdx(end);
    end

    % Accuracy-conditioned collapsed metrics (mean across transitions per trial).
    % NaN clicks (insufficient trajectory samples) and unknown-correctness clicks
    % (NaN isCorrect) are excluded. NaN == x is always false in MATLAB, so
    % corrMask / incorrMask naturally exclude those positions.
    corrMask   = (isCorrect == 1) & ~isnan(mindChanges);
    incorrMask = (isCorrect == 0) & ~isnan(mindChanges);
    corrMaskT  = (isCorrect == 1) & ~isnan(timeInChosen);
    incorrMaskT= (isCorrect == 0) & ~isnan(timeInChosen);

    mindChanges_corr    = NaN;
    mindChanges_incorr  = NaN;
    timeInChosen_corr   = NaN;
    timeInChosen_incorr = NaN;
    if any(corrMask),    mindChanges_corr    = mean(mindChanges(corrMask));    end
    if any(incorrMask),  mindChanges_incorr  = mean(mindChanges(incorrMask));  end
    if any(corrMaskT),   timeInChosen_corr   = mean(timeInChosen(corrMaskT));  end
    if any(incorrMaskT), timeInChosen_incorr = mean(timeInChosen(incorrMaskT));end

    mouse_data(iRep).chosenSlots         = chosenSlots;
    mouse_data(iRep).clickTimes          = clickTimes;
    mouse_data(iRep).isCorrect           = isCorrect;
    mouse_data(iRep).mindChanges         = mindChanges;
    mouse_data(iRep).mindChanged         = mindChanged;
    mouse_data(iRep).timeInChosen        = timeInChosen;
    mouse_data(iRep).timeInOther         = timeInOther;
    mouse_data(iRep).closestAtClick      = closestAtClick;
    mouse_data(iRep).mindChanges_corr    = mindChanges_corr;
    mouse_data(iRep).mindChanges_incorr  = mindChanges_incorr;
    mouse_data(iRep).timeInChosen_corr   = timeInChosen_corr;
    mouse_data(iRep).timeInChosen_incorr = timeInChosen_incorr;
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


%% Plotting the mouse trajectory along with time information for examplar participant





