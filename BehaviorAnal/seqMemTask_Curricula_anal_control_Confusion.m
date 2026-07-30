% seqMemTask_Curricula_anal_control_Confusion.m
% Extended from seqMemTask_Curricula_anal_control.m
% Adds proximity confusion quantification (location & content) to the null
% model analysis.
%
% Key design: for each null model trial, the 5 simulated non-lure responses
% are mapped to the actual trial's 5 non-lure steps via locTrue_col, and the
% lure step response is inferred as the one remaining display slot.  This
% produces a full 6-step response that can be processed with the same
% proximity-confusion logic as seqMemTask_Curricula_anal_summary.m.
%
% Written by XR @ July 2026, based on seqMemTask_Curricula_anal_control.m

clear
clc

%%
addpath('tight_subplot/');
addpath(genpath('HierarchicalCluster/'));
addpath(genpath('Aging-SeqMemTask/'));
addpath('fdr_bh');

%% parameters
folder          = '/Users/ren/Projects-NeuroCode/MyExperiment/Aging-SeqMemTask';
bhvDataDir      = [folder, '/AgingReplay-OnlineData'];
CLdata_folder   = [bhvDataDir, '/CurriculumPaper-Data/'];
CLscript_folder = [folder, '/AgingStudy-Curriculum/BehaviorAnal/'];

RChunk = 0.35;
nSes    = 8*2;
nImgSeq = 2;
nPosSeq = 2;
nPos    = 8;
nImg    = 8;
nTrans  = 5;
nEpi    = nImgSeq * nPosSeq * nSes;
nDtr    = 1;
postTn  = 8;
trlBlc  = 8;
uniTrl  = 4;
nBlock  = nEpi / trlBlc;
nComb   = 4;
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

%% data analysis
acc_group     = cell(1, nGroup);
rt_group      = cell(1, nGroup);
acc_dim_group = cell(1, nGroup);
acc_marginalDim_inJointRep_group = cell(1, nGroup);
acc_blc_group          = cell(1, nGroup);
acc_subj_order_group   = cell(1, nGroup);
acc_subj_orderUP_group = cell(1, nGroup);
trialPerc_group = cell(1, nGroup);
acc_trial_group = cell(1, nGroup);

nSim = 50;

binds_conPctr_group  = cell(1, nGroup);
transAcc_count_group = cell(1, nGroup);

% ------Proximity confusion (null model): location & content------
% Error classification excludes steps where the true slot/position was already occupied.
% Two chance variants (both use the pre-response pool):
%   proxChance_group      = "inconsistent" — over ALL non-lure steps
%   proxChance_free_group = "consistent"   — only when true slot is still free
locErrType_group        = cell(1, nGroup);   % [subLen × 2 × nSim]
proxChance_group        = cell(1, nGroup);   % [subLen × nSim]
proxChance_free_group   = cell(1, nGroup);   % [subLen × nSim]
conErrType_group        = cell(1, nGroup);   % [subLen × 2 × nSim]
conSimChance_group      = cell(1, nGroup);   % [subLen × nSim]
conSimChance_free_group = cell(1, nGroup);   % [subLen × nSim]

%% Image confusion matrix
imgNameList = {'car', 'castle', 'cat', 'cream', 'female', 'hat', 'key', 'sunflower'};

similaritySource_list = {'CLIP', 'DINOv2', 'WordNet'};
similarityId          = 1;
similaritySource      = similaritySource_list{similarityId};
imgIdxMap = containers.Map(imgNameList, 1 : 8);
if isequal(similaritySource, 'CLIP')
    confMat_dir = [CLscript_folder, similaritySource, '_results/'];
    confMat     = load([confMat_dir, similaritySource, '_visual_similarity.mat']);
    conSimMat   = confMat.clipSimMat;
elseif isequal(similaritySource, 'DINOv2')
    confMat_dir = [CLscript_folder, similaritySource, '_results/'];
    confMat     = load([confMat_dir, similaritySource, '_visual_similarity.mat']);
    conSimMat   = confMat.visSimMat;
elseif isequal(similaritySource, 'WordNet')
    conSimMat   = [
                    1.0000  0.5000  0.3200  0.6316  0.4211  0.5000  0.6316  0.3478;
                    0.5000  1.0000  0.3478  0.5882  0.4706  0.5556  0.5882  0.3810;
                    0.3200  0.3478  1.0000  0.3636  0.5455  0.3478  0.3636  0.4615;
                    0.6316  0.5882  0.3636  1.0000  0.5000  0.5882  0.7500  0.4000;
                    0.4211  0.4706  0.5455  0.5000  1.0000  0.4706  0.5000  0.6000;
                    0.5000  0.5556  0.3478  0.5882  0.4706  1.0000  0.5882  0.3810;
                    0.6316  0.5882  0.3636  0.7500  0.5000  0.5882  1.0000  0.4000;
                    0.3478  0.3810  0.4615  0.4000  0.6000  0.3810  0.4000  1.0000;
                    ];
end
conProxK   = 2;
proxThresh = 3 * pi / 8;   % 67.5°: midpoint between 1-step (45°) and 2-step (90°)

%% Null model
modelsList = {'Null', 'Independent'};
modelId    = 1;
modelUsed  = modelsList{modelId};
if isequal(modelUsed, 'Null')
    nDisp    = nTrans + nDtr;
    seq      = 1 : nDisp;
    allPerms = perms(seq);
    allPerms = allPerms(:, 1 : nTrans);
end

%% Main loop
suffixWord = expId;
for iGrp = 1 : nGroup
    if iGrp == 1
        groupName = 'younger';
        subj_list = subjList_young;
    elseif iGrp == 2
        groupName = 'older';
        subj_list = subjList_old;
    end
    subLen   = length(subj_list);
    subjPath = [bhvDataDir, '/AgingReplay-v2-', suffixWord, '/', suffixWord, '-', groupName, '/'];

    acc_trial_subj = nan(subLen, 5, (nEpi + postTn));
    rt_trial_subj  = nan(subLen, 5, (nEpi + postTn));
    acc_subj       = nan(subLen, 14);
    rt_subj        = nan(subLen, 8);
    acc_blc_subj   = nan(subLen, (nBlock+1)*2, 3);
    acc_marginalDim_inJointRep_sub = nan(subLen, 2, 3);
    acc_subj_order   = nan(subLen, 2, 3);
    acc_subj_orderUp = nan(subLen, 3, 3);
    trialPerc_subj   = nan(subLen, 4);
    acc_dim_subj     = nan(subLen, 11);
    binds_conPctr_marg_subj  = nan(subLen, 4, 4, nSim);
    transAcc_count_marg_subj = nan(subLen, 4, 2, nSim);

    % ------Proximity confusion subject containers------
    locErrType_subj        = nan(subLen, 2, nSim);
    proxChance_subj        = nan(subLen, nSim);  % inconsistent: all non-lure steps
    proxChance_free_subj   = nan(subLen, nSim);  % consistent: only when true slot free
    conErrType_subj        = nan(subLen, 2, nSim);
    conSimChance_subj      = nan(subLen, nSim);  % inconsistent
    conSimChance_free_subj = nan(subLen, nSim);  % consistent

    %%
    for iSub = 1 : subLen
        subjBv = subj_list{iSub, 1};
        subjTm = subj_list{iSub, 2};
        seqMem_subj = readtable([subjPath, subjBv, '_EpisodicMemoryTask-', suffixWord, '_', subjTm, '.csv']);

        testOrd = seqMem_subj.trlTestOrd;
        testOrd = testOrd(~isnan(testOrd));

        uniCombSeq_tmp = seqMem_subj.trlComb;
        uniCombSeq_tmp = uniCombSeq_tmp(~cellfun('isempty', uniCombSeq_tmp));
        uniCombSeq = nan(nEpi, 2);
        for i = 1 : nEpi
            uniCombSeq(i, :) = str2num(uniCombSeq_tmp{i});
        end

        shortWTI = seqMem_subj.sWTImark;
        shortWTI = shortWTI(~isnan(shortWTI));

        reconsOnly = seqMem_subj.reconsMark;
        reconsOnly = reconsOnly(~isnan(reconsOnly));

        shortWTI_recons = seqMem_subj.sWTIrecons;
        shortWTI_recons = shortWTI_recons(~isnan(shortWTI_recons));

        longWTI_recons = seqMem_subj.lWTIrecons;
        longWTI_recons = longWTI_recons(~isnan(longWTI_recons));

        posX_tmp = seqMem_subj.locSeqXTrl;
        posX_tmp = posX_tmp(~cellfun('isempty', posX_tmp));
        posY_tmp = seqMem_subj.locSeqYTrl;
        posY_tmp = posY_tmp(~cellfun('isempty', posY_tmp));
        posX_col = cell(nEpi, 1);
        posY_col = cell(nEpi, 1);
        for i = 1 : nEpi
            posX_col{i} = str2num(posX_tmp{i});
            posY_col{i} = str2num(posY_tmp{i});
        end

        conSeqTrl_tmp = seqMem_subj.conSeqTrl;
        conSeqTrl_tmp = conSeqTrl_tmp(~cellfun('isempty', conSeqTrl_tmp));
        conSeqTrl_col = cell(nEpi, 1);
        for i = 1 : nEpi
            raw    = conSeqTrl_tmp{i};
            tokens = regexp(raw, '"([^"]+)"', 'tokens');
            imgIds_i = zeros(1, nTrans + nDtr);
            for k = 1 : length(tokens)
                [~, nm] = fileparts(tokens{k}{1});
                imgIds_i(k) = imgIdxMap(lower(nm));
            end
            conSeqTrl_col{i} = imgIds_i;
        end

        %% content report
        conTrue_tmp_raw = seqMem_subj.conReportTrue;
        conTrue_tmp_raw = conTrue_tmp_raw(~cellfun('isempty', conTrue_tmp_raw));
        conTrue_tmp = cell(nEpi, 1);
        conTrue_tmp(reconsOnly == 0) = conTrue_tmp_raw;
        conRep_tmp_raw  = seqMem_subj.conReportOrd;
        conRep_tmp_raw  = conRep_tmp_raw(~cellfun('isempty', conRep_tmp_raw));
        conRep_tmp = cell(nEpi, 1);
        conRep_tmp(reconsOnly == 0) = conRep_tmp_raw;
        conRT_tmp_raw   = seqMem_subj.conRTs;
        conRT_tmp_raw   = conRT_tmp_raw(~cellfun('isempty', conRT_tmp_raw));
        conRT_tmp = cell(nEpi, 1);
        conRT_tmp(reconsOnly == 0) = conRT_tmp_raw;
        conTrue_col = cell(nEpi, 1);
        conRep_col  = cell(nEpi, 1);
        conRT_col   = cell(nEpi, 1);
        for i = 1 : nEpi
            if reconsOnly(i) == 0
                conTrue_col{i} = str2num(conTrue_tmp{i});
                conRep_noRef   = str2num(conRep_tmp{i});
                conRep_col{i}  = conRep_noRef;
                conRT_noRef = str2num(conRT_tmp{i});
                conRT_Ref   = nan(1, (nTrans + nDtr));
                for j = 1 : nTrans
                    if j == 1
                        conRT_j = conRT_noRef(conRep_noRef == j);
                    else
                        conRT_j = conRT_noRef(conRep_noRef == j) - conRT_noRef(conRep_noRef == (j - 1));
                    end
                    conRT_Ref(conRep_noRef == j) = conRT_j;
                end
                conRT_col{i} = conRT_Ref;
            end
        end

        %% position report
        locTrue_tmp_raw = seqMem_subj.locReportTrue;
        locTrue_tmp_raw = locTrue_tmp_raw(~cellfun('isempty', locTrue_tmp_raw));
        locTrue_tmp = cell(nEpi, 1);
        locTrue_tmp(reconsOnly == 0) = locTrue_tmp_raw;
        locRep_tmp_raw  = seqMem_subj.locReportOrd;
        locRep_tmp_raw  = locRep_tmp_raw(~cellfun('isempty', locRep_tmp_raw));
        locRep_tmp  = cell(nEpi, 1);
        locRep_tmp(reconsOnly == 0) = locRep_tmp_raw;
        locRT_tmp_raw   = seqMem_subj.locRTs;
        locRT_tmp_raw   = locRT_tmp_raw(~cellfun('isempty', locRT_tmp_raw));
        locRT_tmp   = cell(nEpi, 1);
        locRT_tmp(reconsOnly == 0) = locRT_tmp_raw;
        locTrue_col = cell(nEpi, 1);
        locRep_col  = cell(nEpi, 1);
        locRT_col   = cell(nEpi, 1);
        for i = 1 : nEpi
            if reconsOnly(i) == 0
                locTrue_col{i} = str2num(locTrue_tmp{i});
                locRep_noRef   = str2num(locRep_tmp{i});
                locRep_col{i}  = locRep_noRef;
                locRT_noRef = str2num(locRT_tmp{i});
                locRT_Ref   = nan(1, (nTrans + nDtr));
                for j = 1 : nTrans
                    if j == 1
                        locRT_j = locRT_noRef(locRep_noRef == j);
                    else
                        locRT_j = locRT_noRef(locRep_noRef == j) - locRT_noRef(locRep_noRef == (j - 1));
                    end
                    locRT_Ref(locRep_noRef == j) = locRT_j;
                end
                locRT_col{i} = locRT_Ref;
            end
        end

        %% reconstruction report
        bothTrue_tmp = seqMem_subj.bothReportTrue;
        bothTrue_tmp = bothTrue_tmp(~cellfun('isempty', bothTrue_tmp));
        bothRep_tmp  = seqMem_subj.bothReportOrd;
        bothRep_tmp  = bothRep_tmp(~cellfun('isempty', bothRep_tmp));
        bothRT_tmp   = seqMem_subj.bothRTs;
        bothRT_tmp   = bothRT_tmp(~cellfun('isempty', bothRT_tmp));
        bothTrue_col = cell(nEpi + postTn, 1);
        bothRep_col  = cell(nEpi + postTn, 1);
        bothRT_col   = cell(nEpi + postTn, 1);
        for i = 1 : (nEpi + postTn)
            bothTrue_col{i} = str2num(bothTrue_tmp{i});
            bothCol = str2num(bothRep_tmp{i});
            if i <= nEpi
                bothCol = reshape(bothCol, 2, (nTrans+nDtr));
            else
                bothCol = reshape(bothCol, 2, nTrans);
            end
            bothRep_col{i} = bothCol;
            bothRep_con = bothCol(1, :);
            bothRep_loc = bothCol(2, :);
            bothRT_noRef = str2num(bothRT_tmp{i});
            if i <= nEpi
                bothRT_Ref = nan(2, (nTrans + nDtr));
            else
                bothRT_Ref = nan(2, nTrans);
            end
            for j = 1 : nTrans
                if j == 1
                    bothRT_j = bothRT_noRef(bothRep_loc == j);
                else
                    bothRT_j = bothRT_noRef(bothRep_loc == j) - bothRT_noRef(bothRep_loc == (j - 1));
                end
                if ~isempty(bothRT_j)
                    bothRT_Ref(1, bothRep_con == j) = bothRT_j;
                    bothRT_Ref(2, bothRep_loc == j) = bothRT_j;
                end
            end
            bothRT_col{i} = bothRT_Ref;
        end

        %% Accuracy & RT
        choice_con_iSub = nan(nEpi, 5);
        choice_pos_iSub = nan(nEpi, 5);
        for i = 1 : nEpi
            if reconsOnly(i) == 0
                conTrue_i = conTrue_col{i};
                conRep_i  = conRep_col{i};
                conRT_i   = conRT_col{i};
                conRep_i  = conRep_i(conTrue_i ~= 6);
                conRT_i   = conRT_i(conTrue_i ~= 6);
                conTrue_i = conTrue_i(conTrue_i ~= 6);
                acc_trial_subj(iSub, 1, i) = (sum(conRep_i == conTrue_i)) / nTrans;
                choice_con_iSub(i, :) = (conRep_i == conTrue_i);
                if sum(conRep_i == conTrue_i) ~= 0
                    rt_trial_subj(iSub, 1, i) = nanmean(conRT_i(conRep_i == conTrue_i));
                end
                locTrue_i = locTrue_col{i};
                locRep_i  = locRep_col{i};
                locRT_i   = locRT_col{i};
                locRep_i  = locRep_i(locTrue_i ~= 6);
                locRT_i   = locRT_i(locTrue_i ~= 6);
                locTrue_i = locTrue_i(locTrue_i ~= 6);
                acc_trial_subj(iSub, 2, i) = (sum(locRep_i == locTrue_i)) / nTrans;
                choice_pos_iSub(i, :) = (locRep_i == locTrue_i);
                if sum(locRep_i == locTrue_i) ~= 0
                    rt_trial_subj(iSub, 2, i) = nanmean(locRT_i(locRep_i == locTrue_i));
                end
            end
        end
        choice_con_iSub(reconsOnly == 1, :) = [];
        choice_pos_iSub(reconsOnly == 1, :) = [];

        choice_both_iSub      = nan(nEpi, 5);
        choice_both_item_iSub = nan(nEpi, 5);
        choice_both_loc_iSub  = nan(nEpi, 5);
        for i = 1 : (nEpi + postTn)
            bothTrue_i = bothTrue_col{i};
            bothRep_i  = bothRep_col{i};
            bothRT_i   = bothRT_col{i};
            acc_j = zeros(nTrans, 1);
            for j = 1 : nTrans
                if bothRep_i(1, j) == j && bothRep_i(2, j) == j
                    acc_j(j) = 1;
                end
            end
            acc_trial_subj(iSub, 3, i) = sum(acc_j) / nTrans;
            if i <= nEpi
                choice_both_iSub(i, :)      = acc_j;
                choice_both_item_iSub(i, :) = (bothRep_i(1, 1:nTrans) == (1:nTrans));
                choice_both_loc_iSub(i, :)  = (bothRep_i(2, 1:nTrans) == (1:nTrans));
            end
            if sum(acc_j) ~= 0
                bothRT_ij = bothRT_i(1, 1:nTrans);
                rt_trial_subj(iSub, 3, i) = nanmean(bothRT_ij(acc_j == 1));
            end
            true_Tmp = 1 : nTrans;
            bothRT_ij = bothRT_i(:, 1:nTrans);
            acc_trial_subj(iSub, 4, i) = (sum(bothRep_i(1, 1:nTrans) == true_Tmp)) / nTrans;
            acc_trial_subj(iSub, 5, i) = (sum(bothRep_i(2, 1:nTrans) == true_Tmp)) / nTrans;
            rt_trial_subj(iSub, 4, i)  = nanmean(bothRT_ij(1, (bothRep_i(1, 1:nTrans) == true_Tmp)));
            rt_trial_subj(iSub, 5, i)  = nanmean(bothRT_ij(2, (bothRep_i(2, 1:nTrans) == true_Tmp)));
        end

        acc_subj(iSub, 1:5) = squeeze(nanmean(acc_trial_subj(iSub, :, 1:nEpi), 3));
        rt_subj(iSub, 1:5)  = squeeze(nanmean(rt_trial_subj(iSub, :, 1:nEpi), 3));
        acc_subj(iSub, 6:8) = squeeze(nanmean(acc_trial_subj(iSub, 3:end, (nEpi+1):end), 3));
        rt_subj(iSub, 6:8)  = squeeze(nanmean(rt_trial_subj(iSub, 3:end, (nEpi+1):end), 3));

        acc_trial_con_iSub = squeeze(acc_trial_subj(iSub, 1, 1:nEpi));
        acc_trial_pos_iSub = squeeze(acc_trial_subj(iSub, 2, 1:nEpi));
        acc_trial_rec_iSub = squeeze(acc_trial_subj(iSub, 3, 1:nEpi));
        acc_trial_con_iSub = acc_trial_con_iSub(reconsOnly == 0);
        acc_trial_pos_iSub = acc_trial_pos_iSub(reconsOnly == 0);
        acc_trial_rec_iSub = acc_trial_rec_iSub(reconsOnly == 0);
        acc_subj(iSub, 9)  = nanmean(acc_trial_con_iSub);
        acc_subj(iSub, 10) = nanmean(acc_trial_pos_iSub);
        acc_subj(iSub, 11) = nanmean(acc_trial_rec_iSub);
        acc_subj(iSub, 12) = nanmean(acc_trial_con_iSub .* acc_trial_pos_iSub);
        acc_subj(iSub, 13) = nanmean(squeeze(acc_trial_subj(iSub, 4, 1:nEpi)) .* squeeze(acc_trial_subj(iSub, 5, 1:nEpi)));

        acc_trial_iSub = squeeze(acc_trial_subj(iSub, :, 1:nEpi));
        acc_dim_subj(iSub, 1:2)       = nanmean(acc_trial_iSub(1:2, :), 2);
        acc_dim_subj(iSub, [3,4,5])   = nanmean(acc_trial_iSub([3,4,5], reconsOnly == 0), 2);
        acc_dim_subj(iSub, [6,7,8])   = nanmean(acc_trial_iSub([3,4,5], reconsOnly == 1), 2);
        acc_dim_subj(iSub, [9,10,11]) = squeeze(nanmean(acc_trial_subj(iSub, 3:end, (nEpi+1):end), 3));

        acc_marginalDim_inJointRep_sub(iSub, 1:2, 1) = nanmean(acc_trial_iSub([4,5], :), 2);
        acc_marginalDim_inJointRep_sub(iSub, 1:2, 2) = nanmean(acc_trial_iSub([4,5], reconsOnly == 0), 2);
        acc_marginalDim_inJointRep_sub(iSub, 1:2, 3) = nanmean(acc_trial_iSub([4,5], reconsOnly == 1), 2);

        if isequal(suffixWord, 'contentBlocked') || isequal(suffixWord, 'positionBlocked')
            for iBlc = 1 : nBlock
                iTrl_blc = (iBlc - 1) * trlBlc + 1 : iBlc * trlBlc;
                acc_iBlc_iR = acc_trial_subj(iSub, 1:3, iTrl_blc);
                for iR = 1 : 2
                    iBlc_idx = (iBlc - 1) * 2 + iR;
                    if iR == 1
                        iTrl = [1, 3, 5, 7];
                    elseif iR == 2
                        iTrl = [2, 4, 6, 8];
                    end
                    acc_blc_subj(iSub, iBlc_idx, :) = squeeze(nanmean(acc_iBlc_iR(:, :, iTrl), 3));
                end
            end
            for iBlc = [nBlock*2+1, nBlock*2+2]
                iTrl = (iBlc - 1) * uniTrl + 1 : iBlc * uniTrl;
                acc_blc_subj(iSub, iBlc, 3) = squeeze(nanmean(acc_trial_subj(iSub, 3, iTrl), 3));
            end
        elseif isequal(suffixWord, 'interleaved')
            for iBlc = 1 : ((nBlock + 1) * 2)
                iTrl = (iBlc - 1) * uniTrl + 1 : iBlc * uniTrl;
                if iBlc <= (nBlock * 2)
                    acc_blc_subj(iSub, iBlc, :) = squeeze(nanmean(acc_trial_subj(iSub, 1:3, iTrl), 3));
                else
                    acc_blc_subj(iSub, iBlc, 3) = squeeze(nanmean(acc_trial_subj(iSub, 3, iTrl), 3));
                end
            end
        end

        acc_trialReport = (squeeze(acc_trial_subj(iSub, 1:3, 1:nEpi)))';
        trial_marginal  = testOrd(reconsOnly == 0);
        acc_marginal    = acc_trialReport((reconsOnly == 0), :);
        acc_reconsOnly  = acc_trialReport((reconsOnly == 1), :);
        acc_subj_order(iSub, 1, 1) = nanmean(acc_marginal(trial_marginal == 0, 1));
        acc_subj_order(iSub, 2, 1) = nanmean(acc_marginal(trial_marginal == 1, 1));
        acc_subj_order(iSub, 1, 2) = nanmean(acc_marginal(trial_marginal == 1, 2));
        acc_subj_order(iSub, 2, 2) = nanmean(acc_marginal(trial_marginal == 0, 2));
        acc_subj_order(iSub, 1, 3) = nanmean(acc_marginal(trial_marginal == 0, 3));
        acc_subj_order(iSub, 2, 3) = nanmean(acc_marginal(trial_marginal == 1, 3));
        acc_subj_orderUp(iSub, 1, 1) = nanmean(acc_marginal(trial_marginal == 0, 1));
        acc_subj_orderUp(iSub, 1, 2) = nanmean(acc_marginal(trial_marginal == 1, 2));
        acc_subj_orderUp(iSub, 1, 3) = nanmean(acc_reconsOnly(:, 3));
        acc_subj_orderUp(iSub, 2, 1) = nanmean(acc_marginal(trial_marginal == 1, 1));
        acc_subj_orderUp(iSub, 2, 2) = nanmean(acc_marginal(trial_marginal == 0, 2));
        acc_subj_orderUp(iSub, 3, 3) = nanmean(acc_marginal(:, 3));
        acc_subj(iSub, 14) = acc_subj_orderUp(iSub, 1, 1) * acc_subj_orderUp(iSub, 1, 2);

        con_trials = squeeze(acc_trial_subj(iSub, 1, 1:nEpi));
        pos_trials = squeeze(acc_trial_subj(iSub, 2, 1:nEpi));
        rec_trials = squeeze(acc_trial_subj(iSub, 3, :));
        trialPerc_subj(iSub, 1) = length(find(con_trials == 1)) / (length(find(reconsOnly == 0)));
        trialPerc_subj(iSub, 2) = length(find(pos_trials == 1)) / (length(find(reconsOnly == 0)));
        trialPerc_subj(iSub, 3) = length(find(rec_trials(1:nEpi) == 1)) / nEpi;
        trialPerc_subj(iSub, 4) = length(find(rec_trials(nEpi+1:end) == 1)) / postTn;

        %% Transition and binding analysis
        conTrue_threeRep  = conTrue_col(reconsOnly == 0);
        conRep_threeRep   = conRep_col(reconsOnly == 0);
        locTrue_threeRep  = locTrue_col(reconsOnly == 0);
        locRep_threeRep   = locRep_col(reconsOnly == 0);
        bothRep_reconsRep = bothRep_col(1:nEpi);

        conRep_threeRep_sort = cell(size(conTrue_threeRep, 1), 1);
        for iEpi = 1 : size(conTrue_threeRep, 1)
            conTrue_iEpi = conTrue_threeRep{iEpi};
            [~, I] = sort(conTrue_iEpi, 'ascend');
            conRep_iEpi  = conRep_threeRep{iEpi};
            conRep_iEpi_sort = conRep_iEpi(I);
            conRep_threeRep_sort{iEpi} = conRep_iEpi_sort(1:nTrans);
        end
        conRep_threeRep_mat = cell2mat(conRep_threeRep_sort);
        locRep_threeRep_mat = cell2mat(locRep_threeRep);
        locRep_threeRep_mat = locRep_threeRep_mat(:, 1:nTrans);

        if isequal(modelUsed, 'Null')
            conRep_threeRep_mat = nan(sum(~reconsOnly), nTrans, nSim);
            locRep_threeRep_mat = nan(sum(~reconsOnly), nTrans, nSim);
            for iSim = 1 : nSim
                permIdx  = randperm(size(allPerms, 1));
                rnd_iSim = permIdx(1:sum(~reconsOnly));
                conRep_threeRep_mat(:, :, iSim) = allPerms(rnd_iSim, :);
                permIdx  = randperm(size(allPerms, 1));
                rnd_iSim = permIdx(1:sum(~reconsOnly));
                locRep_threeRep_mat(:, :, iSim) = allPerms(rnd_iSim, :);
            end
        elseif isequal(modelUsed, 'Independent')
            conRep_threeRep_mat = slotCorr_con_pred;
            locRep_threeRep_mat = slotCorr_pos_pred;
        end

        slotCorr_marg_con = nan(sum(~reconsOnly), nTrans, nSim);
        slotCorr_marg_pos = nan(sum(~reconsOnly), nTrans, nSim);
        for iSim = 1 : nSim
            for iTrans = 1 : nTrans
                slotCorr_marg_con(:, iTrans, iSim) = (conRep_threeRep_mat(:, iTrans, iSim) == iTrans);
                slotCorr_marg_pos(:, iTrans, iSim) = (locRep_threeRep_mat(:, iTrans, iSim) == iTrans);
            end
        end

        for ij = 1 : nSim
            slotCorr_con = slotCorr_marg_con(:, :, ij);
            slotCorr_pos = slotCorr_marg_pos(:, :, ij);
            transError_con = nan(sum(~reconsOnly), (nTrans - 1));
            transError_pos = nan(sum(~reconsOnly), (nTrans - 1));
            trlLen_temp = sum(~reconsOnly);
            for iTrans = 1 : (nTrans - 1)
                iTrans_from_con = slotCorr_con(:, iTrans);
                iTrans_to_con   = slotCorr_con(:, iTrans + 1);
                transError_con(find(iTrans_from_con == 1 & iTrans_to_con == 1), iTrans) = 1;
                transError_con(find(iTrans_from_con == 1 & iTrans_to_con == 0), iTrans) = 2;
                transError_con(find(iTrans_from_con == 0 & iTrans_to_con == 1), iTrans) = 3;
                transError_con(find(iTrans_from_con == 0 & iTrans_to_con == 0), iTrans) = 4;
                iTrans_from_pos = slotCorr_pos(:, iTrans);
                iTrans_to_pos   = slotCorr_pos(:, iTrans + 1);
                transError_pos(find(iTrans_from_pos == 1 & iTrans_to_pos == 1), iTrans) = 1;
                transError_pos(find(iTrans_from_pos == 1 & iTrans_to_pos == 0), iTrans) = 2;
                transError_pos(find(iTrans_from_pos == 0 & iTrans_to_pos == 1), iTrans) = 3;
                transError_pos(find(iTrans_from_pos == 0 & iTrans_to_pos == 0), iTrans) = 4;
            end
            transError_con_col = reshape(transError_con, [trlLen_temp * (nTrans-1), 1]);
            transError_loc_col = reshape(transError_pos, [trlLen_temp * (nTrans-1), 1]);
            error_con_len = [length(find(transError_con_col == 1)), length(find(transError_con_col == 2)), ...
                             length(find(transError_con_col == 3)), length(find(transError_con_col == 4))];
            error_pos_len = [length(find(transError_loc_col == 1)), length(find(transError_loc_col == 2)), ...
                             length(find(transError_loc_col == 3)), length(find(transError_loc_col == 4))];
            transAcc_count_marg_subj(iSub, :, 1, ij) = error_con_len;
            transAcc_count_marg_subj(iSub, :, 2, ij) = error_pos_len;
        end

        for ij = 1 : nSim
            slotCorr_con = slotCorr_marg_con(:, :, ij);
            slotCorr_pos = slotCorr_marg_pos(:, :, ij);
            binds_conPctr_counts = cell(2, 4);
            for ijT = 1 : size(slotCorr_pos, 1)
                slotCorr_con_ij = slotCorr_con(ijT, :);
                slotCorr_pos_ij = slotCorr_pos(ijT, :);
                for iTr = 2 : nTrans
                    if slotCorr_con_ij(iTr-1) == 1 && slotCorr_pos_ij(iTr) == 1
                        binds_conPctr_counts{1,1} = [binds_conPctr_counts{1,1}; slotCorr_con_ij(iTr)];
                    elseif slotCorr_con_ij(iTr-1) == 1 && slotCorr_pos_ij(iTr) == 0
                        binds_conPctr_counts{1,2} = [binds_conPctr_counts{1,2}; slotCorr_con_ij(iTr)];
                    elseif slotCorr_con_ij(iTr-1) == 0 && slotCorr_pos_ij(iTr) == 1
                        binds_conPctr_counts{1,3} = [binds_conPctr_counts{1,3}; slotCorr_con_ij(iTr)];
                    elseif slotCorr_con_ij(iTr-1) == 0 && slotCorr_pos_ij(iTr) == 0
                        binds_conPctr_counts{1,4} = [binds_conPctr_counts{1,4}; slotCorr_con_ij(iTr)];
                    end
                    if slotCorr_pos_ij(iTr-1) == 1 && slotCorr_con_ij(iTr) == 1
                        binds_conPctr_counts{2,1} = [binds_conPctr_counts{2,1}; slotCorr_pos_ij(iTr)];
                    elseif slotCorr_pos_ij(iTr-1) == 1 && slotCorr_con_ij(iTr) == 0
                        binds_conPctr_counts{2,2} = [binds_conPctr_counts{2,2}; slotCorr_pos_ij(iTr)];
                    elseif slotCorr_pos_ij(iTr-1) == 0 && slotCorr_con_ij(iTr) == 1
                        binds_conPctr_counts{2,3} = [binds_conPctr_counts{2,3}; slotCorr_pos_ij(iTr)];
                    elseif slotCorr_pos_ij(iTr-1) == 0 && slotCorr_con_ij(iTr) == 0
                        binds_conPctr_counts{2,4} = [binds_conPctr_counts{2,4}; slotCorr_pos_ij(iTr)];
                    end
                end
            end
            for iC = 1 : 4
                binds_conPctr_marg_subj(iSub, iC, 1, ij) = length(find(binds_conPctr_counts{1,iC} == 1)) ./ length(binds_conPctr_counts{1,iC});
                binds_conPctr_marg_subj(iSub, iC, 2, ij) = length(find(binds_conPctr_counts{2,iC} == 1)) ./ length(binds_conPctr_counts{2,iC});
                binds_conPctr_marg_subj(iSub, iC, 3, ij) = length(find(binds_conPctr_counts{1,iC} == 1)) ./ length(cell2mat((binds_conPctr_counts(1,:))'));
                binds_conPctr_marg_subj(iSub, iC, 4, ij) = length(find(binds_conPctr_counts{2,iC} == 1)) ./ length(cell2mat((binds_conPctr_counts(2,:))'));
            end
        end

        %% ---- Proximity confusion analysis (null model) ----
        % For each null-model trial the 5 simulated responses cover the 5
        % non-lure steps.  The lure step response is inferred as the one
        % remaining display slot not used by the 5 non-lure responses,
        % giving a complete 6-step response aligned with the actual locTrue /
        % conTrue sequence.  The proximity analysis then follows the same
        % logic as seqMemTask_Curricula_anal_summary.m.

        % Index mapping: iTrl (row of locRep_threeRep_mat, 1-based within
        % non-recons trials) → full trial index into posX_col / conSeqTrl_col
        nonReconsIdx = find(~reconsOnly);   % nNonRecons × 1
        nNonRecons   = length(nonReconsIdx);

        % ---- Location confusion ----
        for iSim = 1 : nSim
            locErrCnt_sim          = zeros(1, 2);
            proxChanCnt_sim        = 0;
            proxChanTotal_sim      = 0;
            proxChanCnt_free_sim   = 0;
            proxChanTotal_free_sim = 0;

            for iTrl = 1 : nNonRecons
                fullTrlIdx = nonReconsIdx(iTrl);
                pX         = posX_col{fullTrlIdx};
                pY         = posY_col{fullTrlIdx};
                locTrue_i  = locTrue_threeRep{iTrl};   % 1×6 actual true slots

                % 5 null-model non-lure responses (display slot values 1-6)
                nullRep5     = locRep_threeRep_mat(iTrl, :, iSim);
                % Infer lure response: the remaining slot not used
                lureRepSlot  = setdiff(1:(nTrans+nDtr), nullRep5);  % scalar

                % Reconstruct full 6-step response aligned with actual steps
                fullRep      = zeros(1, nTrans+nDtr);
                nonLureCnt   = 0;
                for j = 1 : (nTrans + nDtr)
                    if locTrue_i(j) == 6
                        fullRep(j) = lureRepSlot;
                    else
                        nonLureCnt = nonLureCnt + 1;
                        fullRep(j) = nullRep5(nonLureCnt);
                    end
                end

                % Step-by-step proximity analysis (identical to summary script)
                occupiedSlots = [];
                for j = 1 : (nTrans + nDtr)
                    trueSlot = locTrue_i(j);
                    repSlot  = fullRep(j);

                    if trueSlot == 6
                        if repSlot ~= 0
                            occupiedSlots = [occupiedSlots, repSlot];
                        end
                        continue;
                    end
                    theta_true   = atan2(pY(trueSlot), pX(trueSlot));
                    trueSlotFree = ~ismember(trueSlot, occupiedSlots);

                    % Chance: pre-response pool, accumulated for ALL steps and
                    % separately for steps where the true slot is still free.
                    availSlots = setdiff(1:(nTrans+nDtr), [trueSlot, occupiedSlots]);
                    for kk = availSlots
                        arc_kk = mod(atan2(pY(kk), pX(kk)) - theta_true, 2*pi);
                        arc_kk = min(arc_kk, 2*pi - arc_kk);
                        isAdj  = arc_kk < proxThresh;
                        proxChanCnt_sim   = proxChanCnt_sim   + isAdj;
                        proxChanTotal_sim = proxChanTotal_sim + 1;
                        if trueSlotFree
                            proxChanCnt_free_sim   = proxChanCnt_free_sim   + isAdj;
                            proxChanTotal_free_sim = proxChanTotal_free_sim + 1;
                        end
                    end

                    % Update occupancy after chance computation
                    if repSlot ~= 0
                        occupiedSlots = [occupiedSlots, repSlot];
                    end

                    % Skip error classification if true slot was already taken (forced error)
                    if ~trueSlotFree, continue; end

                    % Classify error
                    if repSlot == 0 || repSlot == trueSlot, continue; end
                    arc_rep = mod(atan2(pY(repSlot), pX(repSlot)) - theta_true, 2*pi);
                    arc_rep = min(arc_rep, 2*pi - arc_rep);
                    isProx  = arc_rep < proxThresh;
                    if isProx
                        locErrCnt_sim(1) = locErrCnt_sim(1) + 1;
                    else
                        locErrCnt_sim(2) = locErrCnt_sim(2) + 1;
                    end
                end
            end

            nErrLoc = sum(locErrCnt_sim);
            if nErrLoc > 0
                locErrType_subj(iSub, :, iSim) = locErrCnt_sim / nErrLoc;
            end
            if proxChanTotal_sim > 0
                proxChance_subj(iSub, iSim) = proxChanCnt_sim / proxChanTotal_sim;
            end
            if proxChanTotal_free_sim > 0
                proxChance_free_subj(iSub, iSim) = proxChanCnt_free_sim / proxChanTotal_free_sim;
            end
        end

        % ---- Content confusion ----
        for iSim = 1 : nSim
            conErrCnt_sim           = zeros(1, 2);
            conSimChanCnt_sim       = 0;
            conSimChanTotal_sim     = 0;
            conSimChanCnt_free_sim  = 0;
            conSimChanTotal_free_sim = 0;

            for iTrl = 1 : nNonRecons
                fullTrlIdx = nonReconsIdx(iTrl);
                imgIds     = conSeqTrl_col{fullTrlIdx};  % 1×6 image IDs at display positions
                conTrue_i  = conTrue_threeRep{iTrl};     % 1×6 actual true display positions

                % 5 null-model non-lure responses
                nullRep5    = conRep_threeRep_mat(iTrl, :, iSim);
                lureRepPos  = setdiff(1:(nTrans+nDtr), nullRep5);  % scalar

                % Reconstruct full 6-step response
                fullRep    = zeros(1, nTrans+nDtr);
                nonLureCnt = 0;
                for j = 1 : (nTrans + nDtr)
                    if conTrue_i(j) == 6
                        fullRep(j) = lureRepPos;
                    else
                        nonLureCnt = nonLureCnt + 1;
                        fullRep(j) = nullRep5(nonLureCnt);
                    end
                end

                % Step-by-step proximity analysis
                occupiedPos = [];
                for j = 1 : (nTrans + nDtr)
                    truePos = conTrue_i(j);
                    repPos  = fullRep(j);
                    isLure  = (truePos == 6);

                    if ~isLure
                        trueImgId    = imgIds(truePos);
                        truePosIsFree = ~ismember(truePos, occupiedPos);

                        % Global proximal set: top-conProxK among all 8 images
                        allImgIds    = 1 : size(conSimMat, 1);
                        otherImgIds  = setdiff(allImgIds, trueImgId);
                        [~, sortIdx] = sort(conSimMat(trueImgId, otherImgIds), 'descend');
                        proxImgIds   = otherImgIds(sortIdx(1:conProxK));
                        proxPos      = find(ismember(imgIds, proxImgIds) & (1:(nTrans+nDtr)) ~= truePos);

                        % Chance: pre-response pool, accumulated for ALL steps and
                        % separately for steps where the true position is still free.
                        availPos   = setdiff(1:(nTrans+nDtr), [truePos, occupiedPos]);
                        nAvail     = length(availPos);
                        nProxAvail = length(intersect(availPos, proxPos));
                        conSimChanCnt_sim        = conSimChanCnt_sim       + nProxAvail;
                        conSimChanTotal_sim       = conSimChanTotal_sim      + nAvail;
                        if truePosIsFree
                            conSimChanCnt_free_sim   = conSimChanCnt_free_sim  + nProxAvail;
                            conSimChanTotal_free_sim = conSimChanTotal_free_sim + nAvail;
                        end
                    end

                    % Update occupancy (both lure and non-lure steps)
                    if repPos ~= 0
                        occupiedPos = [occupiedPos, repPos];
                    end

                    if isLure, continue; end

                    % Skip error classification if true position was already taken (forced error)
                    if ~truePosIsFree, continue; end

                    % Classify error
                    if repPos == 0 || repPos == truePos, continue; end
                    isProx = ismember(repPos, proxPos);
                    if isProx
                        conErrCnt_sim(1) = conErrCnt_sim(1) + 1;
                    else
                        conErrCnt_sim(2) = conErrCnt_sim(2) + 1;
                    end
                end
            end

            nErrCon = sum(conErrCnt_sim);
            if nErrCon > 0
                conErrType_subj(iSub, :, iSim) = conErrCnt_sim / nErrCon;
            end
            if conSimChanTotal_sim > 0
                conSimChance_subj(iSub, iSim) = conSimChanCnt_sim / conSimChanTotal_sim;
            end
            if conSimChanTotal_free_sim > 0
                conSimChance_free_subj(iSub, iSim) = conSimChanCnt_free_sim / conSimChanTotal_free_sim;
            end
        end

    end  %% end iSub

    %%
    acc_trial_group{iGrp} = acc_trial_subj;
    acc_group{iGrp}       = acc_subj;
    rt_group{iGrp}        = rt_subj;
    acc_blc_group{iGrp}    = acc_blc_subj;
    acc_marginalDim_inJointRep_group{iGrp} = acc_marginalDim_inJointRep_sub;
    acc_subj_order_group{iGrp}   = acc_subj_order;
    acc_subj_orderUP_group{iGrp} = acc_subj_orderUp;
    trialPerc_group{iGrp}        = trialPerc_subj;
    acc_dim_group{iGrp}          = acc_dim_subj;
    binds_conPctr_group{1, iGrp} = binds_conPctr_marg_subj;
    transAcc_count_group{1, iGrp} = transAcc_count_marg_subj;

    % ------Proximity confusion group storage------
    locErrType_group{iGrp}        = locErrType_subj;
    proxChance_group{iGrp}        = proxChance_subj;
    proxChance_free_group{iGrp}   = proxChance_free_subj;
    conErrType_group{iGrp}        = conErrType_subj;
    conSimChance_group{iGrp}      = conSimChance_subj;
    conSimChance_free_group{iGrp} = conSimChance_free_subj;

end  %% end iGrp

%% ---- Figure: proximity confusion null distribution ----
% For each group, show the null distribution of the proximity confusion rate
% (mean ± CI across subjects, averaged over nSim simulations) alongside the
% empirical chance level.  These can be overlaid with the real data from
% seqMemTask_Curricula_anal_summary.m for comparison.

errTypeNames = {'YA', 'OA'};
barPos_err   = [1; 2.5];
colorSets    = [0.98, 0.72, 0.69; 0.33, 0.73, 0.83];  % YA, OA

% ---- Location confusion null distribution ----
figure('Position', [100 100 180 180]), clf;
for iGrp = 1 : nGroup
    % Average over simulations per subject, then plot across subjects
    locErr_iGrp  = locErrType_group{iGrp}(:, 1, :);  % [subLen × 1 × nSim]
    locErr_iGrp  = squeeze(nanmean(locErr_iGrp, 3));  % [subLen × 1]: mean over sims
    dat_avg = nanmean(locErr_iGrp);
    dat_sem = nanstd(locErr_iGrp) / sqrt(sum(~isnan(locErr_iGrp)));
    bP = barPos_err(iGrp);
    xRand = unifrnd(bP - 0.2, bP + 0.2, length(locErr_iGrp), 1);
    xRand_color = 0.4 * colorSets(iGrp, :) + 0.6 * [1, 1, 1];
    for iSub = 1 : length(locErr_iGrp)
        plot(xRand(iSub), locErr_iGrp(iSub), 'o', 'MarkerSize', 6, ...
             'MarkerFaceColor', xRand_color, 'MarkerEdgeColor', 'k', 'LineWidth', 0.6); hold on;
    end
    errorbar(bP, dat_avg, dat_sem, 'Color', 'k', 'LineStyle', 'none', 'LineWidth', 1.5); hold on;
    plot(bP, dat_avg, 'o', 'MarkerSize', 8, ...
         'MarkerFaceColor', colorSets(iGrp,:), 'MarkerEdgeColor', 'k', 'LineWidth', 0.8); hold on;
end
% Grand-mean chance lines
proxChance_all       = [proxChance_group{1};      proxChance_group{2}];
proxChance_free_all  = [proxChance_free_group{1}; proxChance_free_group{2}];
proxChance_null      = nanmean(proxChance_all(:));
proxChance_free_null = nanmean(proxChance_free_all(:));
plot([0.4, 3.1], [proxChance_null,      proxChance_null],      'k--', 'LineWidth', 0.6); hold on;  % inconsistent
plot([0.4, 3.1], [proxChance_free_null, proxChance_free_null], 'k:',  'LineWidth', 0.6); hold on;  % consistent
xlim([0.4, 3.1]); ylim([0, 1]);
set(gca, 'LineWidth', 0.8, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
set(gca, 'XTick', barPos_err', 'XTickLabel', errTypeNames);
set(gca, 'YTick', 0:0.25:1);
box off;
title('Location confusion (null model)', 'FontSize', 9);

% ---- Content confusion null distribution ----
figure('Position', [100 100 180 180]), clf;
for iGrp = 1 : nGroup
    conErr_iGrp = conErrType_group{iGrp}(:, 1, :);   % [subLen × 1 × nSim]
    conErr_iGrp = squeeze(nanmean(conErr_iGrp, 3));   % [subLen × 1]
    dat_avg = nanmean(conErr_iGrp);
    dat_sem = nanstd(conErr_iGrp) / sqrt(sum(~isnan(conErr_iGrp)));
    bP = barPos_err(iGrp);
    xRand = unifrnd(bP - 0.2, bP + 0.2, length(conErr_iGrp), 1);
    xRand_color = 0.4 * colorSets(iGrp, :) + 0.6 * [1, 1, 1];
    for iSub = 1 : length(conErr_iGrp)
        plot(xRand(iSub), conErr_iGrp(iSub), 'o', 'MarkerSize', 6, ...
             'MarkerFaceColor', xRand_color, 'MarkerEdgeColor', 'k', 'LineWidth', 0.6); hold on;
    end
    errorbar(bP, dat_avg, dat_sem, 'Color', 'k', 'LineStyle', 'none', 'LineWidth', 1.5); hold on;
    plot(bP, dat_avg, 'o', 'MarkerSize', 8, ...
         'MarkerFaceColor', colorSets(iGrp,:), 'MarkerEdgeColor', 'k', 'LineWidth', 0.8); hold on;
end
conSimChance_all       = [conSimChance_group{1};      conSimChance_group{2}];
conSimChance_free_all  = [conSimChance_free_group{1}; conSimChance_free_group{2}];
conSimChance_null      = nanmean(conSimChance_all(:));
conSimChance_free_null = nanmean(conSimChance_free_all(:));
plot([0.4, 3.1], [conSimChance_null,      conSimChance_null],      'k--', 'LineWidth', 0.6); hold on;  % inconsistent
plot([0.4, 3.1], [conSimChance_free_null, conSimChance_free_null], 'k:',  'LineWidth', 0.6); hold on;  % consistent
xlim([0.4, 3.1]); ylim([0, 1]);
set(gca, 'LineWidth', 0.8, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
set(gca, 'XTick', barPos_err', 'XTickLabel', errTypeNames);
set(gca, 'YTick', 0:0.25:1);
box off;
title('Content confusion (null model)', 'FontSize', 9);
