% seqMemTask_Curricula_anal_control.m
% write by XR @ July 14 2026 based on seqMemTask_Curricula_anal_summary.m
% Using the Null model or the Independent model to generate synthetic
% responses and then quantify the chance level performance of transition
% and bindings
% Read the model-predicted results, saved in SeqMemTask_modelPred_main.m
% ===========================================
% re-edited by XR @ April 3 2026
% based on seqMemTask_v2_anal_summary.m and
% seqMemTak_BehvPaper_Figure2Exp2.m
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
folder          = '/Users/ren/Projects-NeuroCode/MyExperiment/Aging-SeqMemTask';
bhvDataDir      = [folder, '/AgingReplay-OnlineData'];
CLdata_folder   = [bhvDataDir, '/CurriculumPaper-Data/']; % data for the summary of the curriculum learning
CLscript_folder = [folder, '/AgingStudy-Curriculum/BehaviorAnal/'];

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

%% ------ Check participants' gender and age ------



%% data analysis
% overall accuracy & RTs across all blocks
acc_group     = cell(1, nGroup);
rt_group      = cell(1, nGroup);
acc_dim_group = cell(1, nGroup);
% overall accuracy for content and position in marginal report and
% reconstruction report (the latter in the third and first order)
acc_marginalDim_inJointRep_group = cell(1, nGroup);
% accuracy for each sub-block
acc_blc_group          = cell(1, nGroup);
% accuracy for content, position and reconstruction for two displaying orders
acc_subj_order_group   = cell(1, nGroup);
acc_subj_orderUP_group = cell(1, nGroup);
% percentage of fully correct trials
trialPerc_group = cell(1, nGroup);
% accuracy & RTs in each trial
acc_trial_group = cell(1, nGroup);

% simulation times
nSim = 50; % randomly generating 50 times of responses per participant

% ------Binding related calculation: the simulations (no full retrieval)------
binds_conPctr_group  = cell(1, nGroup); 

% ------Transition evidence: the simulations (no full retrieval)------
transAcc_count_group = cell(1, nGroup); 

% ------Image confusion matrix------
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
                    %   car     castle  cat     cream   female  hat     key     sunflower
                    1.0000  0.5000  0.3200  0.6316  0.4211  0.5000  0.6316  0.3478;  % car
                    0.5000  1.0000  0.3478  0.5882  0.4706  0.5556  0.5882  0.3810;  % castle
                    0.3200  0.3478  1.0000  0.3636  0.5455  0.3478  0.3636  0.4615;  % cat
                    0.6316  0.5882  0.3636  1.0000  0.5000  0.5882  0.7500  0.4000;  % cream
                    0.4211  0.4706  0.5455  0.5000  1.0000  0.4706  0.5000  0.6000;  % female
                    0.5000  0.5556  0.3478  0.5882  0.4706  1.0000  0.5882  0.3810;  % hat
                    0.6316  0.5882  0.3636  0.7500  0.5000  0.5882  1.0000  0.4000;  % key
                    0.3478  0.3810  0.4615  0.4000  0.6000  0.3810  0.4000  1.0000;  % sunflower
                    ];
end
conProxK = 2; % number of most-similar alternatives that count as "proximal"

%% Generating the responses either using the Null model or using the Independent transition learning model without any hypothesis about the binding
% added by XR @ July 14 2026
modelsList = {'Null', 'Independent'};
modelId    = 1;
modelUsed  = modelsList{modelId};
if isequal(modelUsed, 'Null')
    % ------ For each participant, randomly selected nTrial
    % permutations from *allPerms* and repeat this process for
    % multiplt time ------
    nDisp    = nTrans + nDtr;
    seq      = 1 : nDisp;
    allPerms = perms(seq);
    allPerms = allPerms(:, 1 : nTrans);
end

%% Quantify the pattern
suffixWord = expId;
for iGrp = 1 : nGroup %% younger and older adults
    if iGrp == 1
        groupName = 'younger';
        subj_list = subjList_young;
    elseif iGrp == 2
        groupName = 'older';
        subj_list = subjList_old;
    end
    subLen   = length(subj_list);
    subjPath = [bhvDataDir, '/AgingReplay-v2-', suffixWord, '/', suffixWord, '-', groupName, '/'];

    % ------accuracy & RTs in each trial------
    acc_trial_subj = nan(subLen, 5, (nEpi + postTn)); % 5: (1) content report; (2) position report; (3) both report; (4) content in both report; (5) position in both report;
    rt_trial_subj  = nan(subLen, 5, (nEpi + postTn)); 

    % ------overall accuracy & RTs across all blocks------
    acc_subj       = nan(subLen, 14); % post-test: (6) both; (7) content in both report; (8) position in both report;
    rt_subj        = nan(subLen, 8);

    % ------accuracy in each sub-block------
    acc_blc_subj   = nan(subLen, (nBlock+1)*2, 3); % 3: (1) content report; (2) position report; (3) both report;

    % ------accuracy in reconstruction report------
    acc_marginalDim_inJointRep_sub = nan(subLen, 2, 3); % 2: content and position reports; 3: all trials, recons report in the 3rd order, only-recons trials

    % ------accuracy for content, position and reconstruction separately for two dispalying order------
    acc_subj_order   = nan(subLen, 2, 3); % 2nd dimension: first and second report condition; 3rd dimension: content, position and reconstruction
    acc_subj_orderUp = nan(subLen, 3, 3); % 2nd dimension: first, second, and third report order; 3rd dimension: content, position and reconstruction

    % ------percentage of the fully correct trials------
    trialPerc_subj   = nan(subLen, 4); % 4: content, position, reconstruction, post-test

    % ------overall accuracy in 11 measurements------
    acc_dim_subj          = nan(subLen, 11); % post-test: (6) both; (7) content in both report; (8) position in both report; (9) both in recons-only; (10) content in recons-only; (11) position in recons-only

    % ------Binidng related measures------
    binds_conPctr_marg_subj = nan(subLen, 4, 4, nSim); % the 2nd 2: (1-2) proportion: item on position and position on item; (3-4) detected response numbers

    % ------Transition evidence------
    transAcc_count_marg_subj = nan(subLen, 4, 2, nSim); % 4: 4 different counts; 2: item and location

    %%
    for iSub = 1 : subLen
        subjBv = subj_list{iSub, 1};
        subjTm = subj_list{iSub, 2};
        seqMem_subj = readtable([subjPath, subjBv, '_EpisodicMemoryTask-', suffixWord, '_', subjTm, '.csv']);
        %%
        %%% trial test order: 0-content firstly; 1-position firstly
        testOrd = seqMem_subj.trlTestOrd;
        testOrd = testOrd(~isnan(testOrd));
        %%% unique combination between two content and two position sequence
        uniCombSeq_tmp = seqMem_subj.trlComb;
        uniCombSeq_tmp = uniCombSeq_tmp(~cellfun('isempty', uniCombSeq_tmp));
        uniCombSeq = nan(nEpi, 2);
        for i =  1 : nEpi
            uniCombSeq(i, :) = str2num(uniCombSeq_tmp{i});
        end
        %%% shortWTI index
        shortWTI = seqMem_subj.sWTImark;
        shortWTI = shortWTI(~isnan(shortWTI));
        %%% reconstruction index
        reconsOnly = seqMem_subj.reconsMark;
        reconsOnly = reconsOnly(~isnan(reconsOnly));
        %%% shortWTI+recons
        shortWTI_recons = seqMem_subj.sWTIrecons;
        shortWTI_recons = shortWTI_recons(~isnan(shortWTI_recons));

        %%% longWTI+recons
        longWTI_recons = seqMem_subj.lWTIrecons;
        longWTI_recons = longWTI_recons(~isnan(longWTI_recons));

        %% positions of each slot
        posX_tmp = seqMem_subj.locSeqXTrl;
        posX_tmp = posX_tmp(~cellfun('isempty', posX_tmp));
        posY_tmp = seqMem_subj.locSeqYTrl;
        posY_tmp = posY_tmp(~cellfun('isempty', posY_tmp));
        posX_col = cell(nEpi, 1);
        posY_col = cell(nEpi, 1);
        for i =  1 : nEpi
            posX_col{i} = str2num(posX_tmp{i});
            posY_col{i} = str2num(posY_tmp{i});
        end

        %% display-position → image-ID mapping per trial (from conSeqTrl)
        % conSeqTrl stores image filenames in display-position order (1-6), present for all 64 trials.
        % Filenames may include a path prefix (e.g. "ImageSet/car.png"); fileparts strips it.
        conSeqTrl_tmp = seqMem_subj.conSeqTrl;
        conSeqTrl_tmp = conSeqTrl_tmp(~cellfun('isempty', conSeqTrl_tmp));
        conSeqTrl_col = cell(nEpi, 1);
        for i = 1 : nEpi
            raw    = conSeqTrl_tmp{i};  % e.g. '["ImageSet/car.png","ImageSet/key.png",...]'
            tokens = regexp(raw, '"([^"]+)"', 'tokens');
            imgIds = zeros(1, nTrans + nDtr);
            for k = 1 : length(tokens)
                [~, nm] = fileparts(tokens{k}{1}); % strip path prefix and extension → bare name
                imgIds(k) = imgIdxMap(lower(nm));
            end
            conSeqTrl_col{i} = imgIds;
        end

        %% ---------- content report ----------
        conTrue_tmp_raw = seqMem_subj.conReportTrue;
        conTrue_tmp_raw = conTrue_tmp_raw(~cellfun('isempty', conTrue_tmp_raw));
        conTrue_tmp = cell(nEpi, 1);
        conTrue_tmp(reconsOnly == 0) = conTrue_tmp_raw;
        conRep_tmp_raw  = seqMem_subj.conReportOrd;
        conRep_tmp_raw  = conRep_tmp_raw(~cellfun('isempty', conRep_tmp_raw));
        conRep_tmp = cell(nEpi, 1);
        conRep_tmp(reconsOnly == 0) = conRep_tmp_raw ;
        conRT_tmp_raw   = seqMem_subj.conRTs;
        conRT_tmp_raw   = conRT_tmp_raw(~cellfun('isempty', conRT_tmp_raw));
        conRT_tmp = cell(nEpi, 1);
        conRT_tmp(reconsOnly == 0) = conRT_tmp_raw;
        conTrue_col = cell(nEpi, 1);
        conRep_col  = cell(nEpi, 1);
        conRT_col   = cell(nEpi, 1);
        for i =  1 : nEpi
            if reconsOnly(i) == 0 %% non reconstruction only trial
                conTrue_col{i} = str2num(conTrue_tmp{i});
                conRep_noRef   = str2num(conRep_tmp{i});
                conRep_col{i}  = conRep_noRef;
                %%% get RT for each item by subtracting the RT of its
                %%% predecessor
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

        %% ---------- position report ----------
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
        for i =  1 : nEpi
            if reconsOnly(i) == 0 %% non reconstruction only trial
                locTrue_col{i} = str2num(locTrue_tmp{i});
                locRep_noRef   = str2num(locRep_tmp{i});
                locRep_col{i}  = locRep_noRef;
                %%% get RT for each item
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

        %% ---------- reconstruction report ----------
        bothTrue_tmp = seqMem_subj.bothReportTrue;
        bothTrue_tmp = bothTrue_tmp(~cellfun('isempty', bothTrue_tmp));
        bothRep_tmp  = seqMem_subj.bothReportOrd;
        bothRep_tmp  = bothRep_tmp(~cellfun('isempty', bothRep_tmp));
        bothRT_tmp   = seqMem_subj.bothRTs;
        bothRT_tmp   = bothRT_tmp(~cellfun('isempty', bothRT_tmp));
        %%% accuracy and RT calculation based on integration of content and
        %%% position
        bothTrue_col = cell(nEpi + postTn, 1);
        bothRep_col  = cell(nEpi + postTn, 1);
        bothRT_col   = cell(nEpi + postTn, 1);
        for i =  1 : (nEpi + postTn)
            bothTrue_col{i} = str2num(bothTrue_tmp{i});
            bothCol = str2num(bothRep_tmp{i});
            if i <= nEpi
                bothCol = reshape(bothCol, 2, (nTrans+nDtr));
            else
                bothCol = reshape(bothCol, 2, nTrans);
            end
            bothRep_col{i} = bothCol;
            bothRep_con = bothCol(1, :); %% report order of content
            bothRep_loc = bothCol(2, :); %% report order of position

            %%% In the raw data, the RTs is aligned based on the position
            %%% report (the 2nd row of bothCol)
            bothRT_noRef = str2num(bothRT_tmp{i});
            if i <= nEpi
                bothRT_Ref = nan(2, (nTrans + nDtr)); % 1st row: content; 2nd row: position;
            else
                bothRT_Ref = nan(2, nTrans); % 1st row: content; 2nd row: position;
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

        %% !!!!!!!!!! Accuracy & RT calculation!!!!!!!!!!
        %% trial-by-trial accuracy & RT
        % single content and location report
        % content and report
        choice_con_iSub = nan(nEpi, 5); % 48 marginal report trials * 5 transitions
        choice_pos_iSub = nan(nEpi, 5);
        for i =  1 : nEpi
            if reconsOnly(i) == 0 %% non reconstruction only trial
                % content report
                conTrue_i = conTrue_col{i};
                conRep_i  = conRep_col{i};
                conRT_i   = conRT_col{i};
                conRep_i  = conRep_i(conTrue_i ~= 6);
                conRT_i   = conRT_i(conTrue_i ~= 6);
                conTrue_i = conTrue_i(conTrue_i ~= 6);
                acc_trial_subj(iSub, 1, i) = (sum(conRep_i == conTrue_i)) / nTrans;
                choice_con_iSub(i, :) = (conRep_i == conTrue_i); % 1-correct; 0-incorrect;
                %%% RT calculation based on single correct item
                if sum(conRep_i == conTrue_i) ~= 0
                    rt_trial_subj(iSub, 1, i) = nanmean(conRT_i(conRep_i == conTrue_i));
                end

                % position report
                locTrue_i = locTrue_col{i};
                locRep_i  = locRep_col{i};
                locRT_i   = locRT_col{i};
                locRep_i  = locRep_i(locTrue_i ~= 6);
                locRT_i   = locRT_i(locTrue_i ~= 6);
                locTrue_i = locTrue_i(locTrue_i ~= 6);
                acc_trial_subj(iSub, 2, i) = (sum(locRep_i == locTrue_i)) / nTrans;
                choice_pos_iSub(i, :) = (locRep_i == locTrue_i); % 1-correct; 0-incorrect;
                %%% RT calculation based on single correct item
                if sum(locRep_i == locTrue_i) ~= 0
                    rt_trial_subj(iSub, 2, i) = nanmean(locRT_i(locRep_i == locTrue_i));
                end
            end
        end
        choice_con_iSub(reconsOnly == 1, :) = [];
        choice_pos_iSub(reconsOnly == 1, :) = [];

        %% trial-by-trial full retrieval
        choice_both_iSub      = nan(nEpi, 5);
        choice_both_item_iSub = nan(nEpi, 5);
        choice_both_loc_iSub  = nan(nEpi, 5);
        for i =  1 : (nEpi + postTn)
            bothTrue_i = bothTrue_col{i};
            bothRep_i  = bothRep_col{i}; % 2 row: content and position
            bothRT_i   = bothRT_col{i};  % 2 row: content and position
            %%% accuracy integrate both content and position
            acc_j = zeros(nTrans, 1);
            for j = 1 : nTrans
                if bothRep_i(1, j) == j && bothRep_i(2, j) == j
                    acc_j(j) = 1;
                end
            end
            acc_trial_subj(iSub, 3, i) = sum(acc_j) / nTrans;
            if i <= nEpi
                choice_both_iSub(i, :) = acc_j;
                % ------ Marginal reports in the reconstruction report
                % ------
                choice_both_item_iSub(i, :) = (bothRep_i(1, 1 : nTrans) == (1 : 1 : nTrans));
                choice_both_loc_iSub(i, :)  = (bothRep_i(2, 1 : nTrans) == (1 : 1 : nTrans));

            end
            %%% RT calculation based on single correct item
            if sum(acc_j) ~= 0
                bothRT_ij = bothRT_i(1, 1 : nTrans); % only the items consistent between content and position are valid
                rt_trial_subj(iSub, 3, i) = nanmean(bothRT_ij(acc_j == 1));
            end

            %%% accuracy for content and position separately
            true_Tmp = 1 : 1 : nTrans;
            bothRT_ij = bothRT_i(:, 1 : nTrans);
            acc_trial_subj(iSub, 4, i) = (sum(bothRep_i(1, 1 : nTrans) == true_Tmp)) / nTrans;
            acc_trial_subj(iSub, 5, i) = (sum(bothRep_i(2, 1 : nTrans) == true_Tmp)) / nTrans;
            %%% RT calculation based on single correct item
            rt_trial_subj(iSub, 4, i) = nanmean(bothRT_ij(1, (bothRep_i(1, 1 : nTrans) == true_Tmp)));
            rt_trial_subj(iSub, 5, i) = nanmean(bothRT_ij(2, (bothRep_i(2, 1 : nTrans) == true_Tmp)));
        end

        %% overall accuracy & RT
        % 64 episodes before numJdgTask
        % acc_trial_iSub = squeeze(acc_trial_subj(iSub, :, 1 : nEpi));
        % acc_trial_iSub = acc_trial_iSub(:, reconsOnly == 0);
        % acc_subj(iSub, 1 : 5) = nanmean(acc_trial_iSub, 2);
        acc_subj(iSub, 1 : 5) = squeeze(nanmean(acc_trial_subj(iSub, :, 1 : nEpi), 3));
        rt_subj(iSub, 1 : 5)  = squeeze(nanmean(rt_trial_subj(iSub, :, 1 : nEpi), 3));
        % 8 episodes after numJdgTask
        acc_subj(iSub, 6 : 8) = squeeze(nanmean(acc_trial_subj(iSub, 3 : end, (nEpi + 1) : end), 3));
        rt_subj(iSub, 6 : 8)  = squeeze(nanmean(rt_trial_subj(iSub, 3 : end, (nEpi + 1) : end), 3));

        %% calculate the predicted joint accuracy from either marginal reports or the marginal dimension in the reconstruction reports
        % added by rxj @ Sep 14 2024
        % only non-reconstruction only trials
        acc_trial_con_iSub = squeeze(acc_trial_subj(iSub, 1, 1 : nEpi));
        acc_trial_pos_iSub = squeeze(acc_trial_subj(iSub, 2, 1 : nEpi));
        acc_trial_rec_iSub = squeeze(acc_trial_subj(iSub, 3, 1 : nEpi));
        acc_trial_con_iSub = acc_trial_con_iSub(reconsOnly == 0);
        acc_trial_pos_iSub = acc_trial_pos_iSub(reconsOnly == 0);
        acc_trial_rec_iSub = acc_trial_rec_iSub(reconsOnly == 0);
        %%% ------The non-reconsOnly trials: 3 consecutive reports (same as Experiment 1)------
        % ----content----
        acc_subj(iSub, 9)  = nanmean(acc_trial_con_iSub);
        % ----position----
        acc_subj(iSub, 10) = nanmean(acc_trial_pos_iSub);
        % ----reconstruction----
        acc_subj(iSub, 11) = nanmean(acc_trial_rec_iSub);
        % ----independent prediction----
        acc_subj(iSub, 12) = nanmean(acc_trial_con_iSub .* acc_trial_pos_iSub);
        acc_subj(iSub, 13) = nanmean(squeeze(acc_trial_subj(iSub, 4, 1 : nEpi)) .* squeeze(acc_trial_subj(iSub, 5, 1 : nEpi)));

        %% overall accuracy: but separate the single dimension report in reconstruction only trials
        % added by rxj @ 06/06/2023
        %acc_dim_subj = nan(subLen, 11); % post-test: (6) both; (7) content in both report; (8) position in both report; (9) both in recons-only; (10) content in recons-only; (11) position in recons-only
        acc_trial_iSub  = squeeze(acc_trial_subj(iSub, :, 1 : nEpi)); %% 5measures * 64nEpi
        acc_dim_subj(iSub, 1 : 2) = nanmean(acc_trial_iSub(1 : 2, :), 2);
        acc_dim_subj(iSub, [3, 4, 5])   = nanmean(acc_trial_iSub([3, 4, 5], reconsOnly == 0), 2);
        acc_dim_subj(iSub, [6, 7, 8])   = nanmean(acc_trial_iSub([3, 4, 5], reconsOnly == 1), 2); %% reconstruction only trials
        acc_dim_subj(iSub, [9, 10, 11]) = squeeze(nanmean(acc_trial_subj(iSub, 3 : end, (nEpi + 1) : end), 3));

        %% accuracy for marginal dimension in the joint reports
        % 3 cases: (1) all trials; (2) recons in the "3-reports" trials; (3) reconstruction only trial;
        % added by rxj @ 02/04/2024
        % acc_marginalDim_inJointRep_sub = nan(subLen, 2, 3);
        % --------marginal dimension in joint report across all trials--------
        acc_marginalDim_inJointRep_sub(iSub, 1 : 2, 1) = nanmean(acc_trial_iSub([4, 5], :), 2);
        % --------marginal dimension in joint report across the "3-reports trials"--------
        acc_marginalDim_inJointRep_sub(iSub, 1 : 2, 2) = nanmean(acc_trial_iSub([4, 5], reconsOnly == 0), 2);
        % --------marginal dimension in joint report across the "reconstruction only trials"--------
        acc_marginalDim_inJointRep_sub(iSub, 1 : 2, 3) = nanmean(acc_trial_iSub([4, 5], reconsOnly == 1), 2);

        %% block-wise pattern
        % acc_blc_subj = nan(subLen, (nBlock+1)*2, 3); % 3: (1) content report; (2) position report; (3) both report;
        if isequal(suffixWord, 'contentBlocked') || isequal(suffixWord, 'positionBlocked')
            for iBlc = 1 : nBlock
                %%% averaging the first and second repeats across 4 sequences
                iTrl_blc = (iBlc - 1) * trlBlc + 1 : iBlc * trlBlc;
                acc_iBlc_iR = acc_trial_subj(iSub, 1 : 3, iTrl_blc);
                for iR = 1 : 2 %% 2 repeats
                    iBlc_idx = (iBlc - 1) * 2 + iR;
                    if iR == 1
                        iTrl = [1, 3, 5, 7]; %% first repeat of the 4 sequences
                    elseif iR == 2
                        iTrl = [2, 4, 6, 8]; %% second repeat
                    end
                    acc_blc_subj(iSub, iBlc_idx, :) = squeeze(nanmean(acc_iBlc_iR(:, :, iTrl), 3));
                end
            end
            %%% post-test
            for iBlc = [nBlock*2+1, nBlock*2+2]
                iTrl = (iBlc - 1) * uniTrl + 1 : iBlc * uniTrl;
                acc_blc_subj(iSub, iBlc, 3) = squeeze(nanmean(acc_trial_subj(iSub, 3, iTrl), 3));
            end
        elseif isequal(suffixWord, 'interleaved')
            for iBlc = 1 : ((nBlock + 1) * 2) % 1: post-test block
                iTrl = (iBlc - 1) * uniTrl + 1 : iBlc * uniTrl;
                if iBlc <= (nBlock * 2)
                    acc_blc_subj(iSub, iBlc, :) = squeeze(nanmean(acc_trial_subj(iSub, 1 : 3, iTrl), 3));
                else
                    acc_blc_subj(iSub, iBlc, 3) = squeeze(nanmean(acc_trial_subj(iSub, 3, iTrl), 3));
                end
            end
        end

        %% order effect: compare the accuacy within a dimension (content or position) between the 1st and 2nd report after the encoding stage
        % added by rxj @ 01/22/2024
        % acc_trial_subj = nan(subLen, 5, (nEpi + postTn)); % 5: (1) content report; (2) position report; (3) both report; (4) content in both report; (5) position in both report;
        acc_trialReport = (squeeze(acc_trial_subj(iSub, 1 : 3, 1 : nEpi)))'; % 64 trials * 3 columns
        trial_marginal  = testOrd(reconsOnly == 0); % delete the reconstruction only trials
        acc_marginal    = acc_trialReport((reconsOnly == 0), :); % 48 trials * 3 columns
        acc_reconsOnly  = acc_trialReport((reconsOnly == 1), :); % 16 trials * 3 columns (the first 2 columns are NAN)

        % acc_subj_order = nan(subLen, 2, 3); % 2nd dimension: first and second report order; 3rd dimension: content, position and reconstruction
        % content report
        acc_subj_order(iSub, 1, 1) = nanmean(acc_marginal(trial_marginal == 0, 1));
        acc_subj_order(iSub, 2, 1) = nanmean(acc_marginal(trial_marginal == 1, 1));
        % position report
        acc_subj_order(iSub, 1, 2) = nanmean(acc_marginal(trial_marginal == 1, 2));
        acc_subj_order(iSub, 2, 2) = nanmean(acc_marginal(trial_marginal == 0, 2));
        % reconstruction report
        acc_subj_order(iSub, 1, 3) = nanmean(acc_marginal(trial_marginal == 0, 3)); % content-position-reconstruction
        acc_subj_order(iSub, 2, 3) = nanmean(acc_marginal(trial_marginal == 1, 3)); % position-content-reconstruction

        %% accuracy for content, position and reconstruction for two displaying orders: 2nd version
        % added by rxj @ 01/24/2024
        % plotting according to the reporting order after the encoding stage
        % 3 kinds of reporting order:
        % (1) first order: content in content-first trials, posiiton in position-first trials,
        % recon report in reconstruction only trials;
        % (2) second order: pos in content-first trials, con in position-first trials;
        % (3) third order: recon report in non recon-only trials
        %acc_subj_orderUp = nan(subLen, 3, 3); % 2nd dimension: first, second, and third report order; 3rd dimension: content, position and reconstruction
        % ------first order------
        % content-first, position-first, and recons-only trials
        acc_subj_orderUp(iSub, 1, 1) = nanmean(acc_marginal(trial_marginal == 0, 1));
        acc_subj_orderUp(iSub, 1, 2) = nanmean(acc_marginal(trial_marginal == 1, 2));
        acc_subj_orderUp(iSub, 1, 3) = nanmean(acc_reconsOnly(:, 3));
        % ------second order------
        acc_subj_orderUp(iSub, 2, 1) = nanmean(acc_marginal(trial_marginal == 1, 1));
        acc_subj_orderUp(iSub, 2, 2) = nanmean(acc_marginal(trial_marginal == 0, 2));
        % ------third order------
        acc_subj_orderUp(iSub, 3, 3) = nanmean(acc_marginal(:, 3));
        
        % ------Independent hypothesis prediction in the first reporting
        % window from the marginal reports------
        acc_subj(iSub, 14) = acc_subj_orderUp(iSub, 1, 1) * acc_subj_orderUp(iSub, 1, 2);

        %% percentage of fully correct trials
        con_trials = squeeze(acc_trial_subj(iSub, 1, 1 : nEpi));
        pos_trials = squeeze(acc_trial_subj(iSub, 2, 1 : nEpi));
        rec_trials = squeeze(acc_trial_subj(iSub, 3, :));
        trialPerc_subj(iSub, 1) = length(find(con_trials == 1)) / (length(find(reconsOnly == 0)));
        trialPerc_subj(iSub, 2) = length(find(pos_trials == 1)) / (length(find(reconsOnly == 0)));
        trialPerc_subj(iSub, 3) = length(find(rec_trials(1 : nEpi) == 1)) / nEpi; % length(find(rec_trials == 1)) / (nEpi + postTn);
        trialPerc_subj(iSub, 4) = length(find(rec_trials(nEpi + 1 : end) == 1)) / postTn;

        %% ----------Transition accuracy and binding accuracy----------
        conTrue_threeRep  = conTrue_col(reconsOnly == 0);
        conRep_threeRep   = conRep_col(reconsOnly == 0);
        locTrue_threeRep  = locTrue_col(reconsOnly == 0);
        locRep_threeRep   = locRep_col(reconsOnly == 0);
        bothRep_reconsRep = bothRep_col(1 : nEpi); % 2 row: content and position; only the learning-reports trials
        % organize the content report according to the ground truth
        conRep_threeRep_sort = cell(size(conTrue_threeRep, 1), 1);
        for iEpi = 1 : size(conTrue_threeRep, 1)
            conTrue_iEpi = conTrue_threeRep{iEpi};
            [~, I] = sort(conTrue_iEpi, 'ascend');
            conRep_iEpi  = conRep_threeRep{iEpi};
            conRep_iEpi_sort = conRep_iEpi(I);
            conRep_threeRep_sort{iEpi} = conRep_iEpi_sort(1 : nTrans);
        end
        % convert the cell to matrix
        conRep_threeRep_mat = cell2mat(conRep_threeRep_sort); % 5 columns
        locRep_threeRep_mat = cell2mat(locRep_threeRep);
        locRep_threeRep_mat = locRep_threeRep_mat(:, 1 : nTrans); % 5 columns
        conRep_reconRep_mat = nan(nEpi, nTrans); % 5 columns
        locRep_reconRep_mat = nan(nEpi, nTrans);
        for iEpi = 1 : nEpi
            conRep_reconRep_mat(iEpi, :) = bothRep_reconsRep{iEpi}(1, 1 : nTrans);
            locRep_reconRep_mat(iEpi, :) = bothRep_reconsRep{iEpi}(2, 1 : nTrans);
        end

        %%% ------ quantify the chance level of transition accuracy ------
        % added by XR @ July 16 2026
        % Let's say for both partial (object and location) retrievals, the correct responses are
        % always [1,2,3,4,5], which means the two types of retrievals share
        % the same chance level under NULL model

        % ---- remove the responses with 6 (as in the real experiment, this
        % is the distractor) ----
        % no simulation for the full retrieval tests
        if isequal(modelUsed, 'Null')
            % ------ For each participant, randomly selected nTrial
            % permutations from *allPerms* and repeat this process for
            % multiplt time ------
            % For each participant, randomly selected 50 times
            conRep_threeRep_mat = nan(sum(~reconsOnly), nTrans, nSim); % 1: the response is correct; 0: incorrect response;
            locRep_threeRep_mat = nan(sum(~reconsOnly), nTrans, nSim); 
            for iSim = 1 : nSim
                % ------ object sequence ------
                permIdx  = randperm(size(allPerms, 1));
                rnd_iSim = permIdx(1 : sum(~reconsOnly));
                conRep_threeRep_mat(:, :, iSim) = allPerms(rnd_iSim, :);
                % ------ location sequence ------
                permIdx  = randperm(size(allPerms, 1));
                rnd_iSim = permIdx(1 : sum(~reconsOnly));
                locRep_threeRep_mat(:, :, iSim) = allPerms(rnd_iSim, :);
            end

        elseif isequal(modelUsed, 'Independent')
            % using indepedent model to simulate participants' responses to
            % quantify the chance-level of binding score
            conRep_threeRep_mat = slotCorr_con_pred;
            locRep_threeRep_mat = slotCorr_pos_pred;

        end

        % ------ Binarize the responses (same as the original script) ------
        slotCorr_marg_con = nan(sum(~reconsOnly), nTrans, nSim);% 1: the response is correct; 0: incorrect response;
        slotCorr_marg_pos = nan(sum(~reconsOnly), nTrans, nSim); 
        for iSim = 1 : nSim
            for iTrans = 1 : (nTrans)
                % ----Content reports in the marginal reports trials----
                slotCorr_marg_con(:, iTrans, iSim) = (conRep_threeRep_mat(:, iTrans, iSim) == iTrans);
                % ----Position reports in the marginal reports trials----
                slotCorr_marg_pos(:, iTrans, iSim) = (locRep_threeRep_mat(:, iTrans, iSim) == iTrans);
            end
        end

        %% ----------Transition evidence----------
        % ------Transitions in the marginal reports of the 3-reports trials------
        % ------as well as in the reconstruction reports------
        % categorize the four responses, given the transition is from X to
        % Y: (1) correct-X to Y; (2)incorrect-X to nonY; (3) incorrect-nonX
        % to Y; (4) incorrect-nonX to nonY
        for ij = 1 : nSim % only partial retrieval; under NULL model condition, no distinction between object and location retrieval
            slotCorr_con = slotCorr_marg_con(:, :, ij);
            slotCorr_pos = slotCorr_marg_pos(:, :, ij);

            transError_con = nan(sum(~reconsOnly), (nTrans - 1));
            transError_pos = nan(sum(~reconsOnly), (nTrans - 1));
            trlLen_temp = sum(~reconsOnly);
            for iTrans = 1 : (nTrans - 1)
                % ----Content----
                iTrans_from_con = slotCorr_con(:, iTrans);
                iTrans_to_con   = slotCorr_con(:, iTrans + 1);
                transError_con(find(iTrans_from_con == 1 & iTrans_to_con == 1), iTrans) = 1; % Pr(toY=1 | fromX=1); fully correct
                transError_con(find(iTrans_from_con == 1 & iTrans_to_con == 0), iTrans) = 2; % Pr(toY=0 | fromX=1)
                transError_con(find(iTrans_from_con == 0 & iTrans_to_con == 1), iTrans) = 3; % Pr(toY=1 | fromX=0)
                transError_con(find(iTrans_from_con == 0 & iTrans_to_con == 0), iTrans) = 4; % Pr(toY=0 | fromX=0); fully incorrect

                % ----Position----
                iTrans_from_pos = slotCorr_pos(:, iTrans);
                iTrans_to_pos   = slotCorr_pos(:, iTrans + 1);
                transError_pos(find(iTrans_from_pos == 1 & iTrans_to_pos == 1), iTrans) = 1;
                transError_pos(find(iTrans_from_pos == 1 & iTrans_to_pos == 0), iTrans) = 2;
                transError_pos(find(iTrans_from_pos == 0 & iTrans_to_pos == 1), iTrans) = 3;
                transError_pos(find(iTrans_from_pos == 0 & iTrans_to_pos == 0), iTrans) = 4;

            end
            %%% ------ Quantify the transition accuracy 1) previous report was correct, 2) previous repprt was incorrect------
            transError_con_col = reshape(transError_con, [trlLen_temp * (nTrans - 1), 1]);
            transError_loc_col = reshape(transError_pos, [trlLen_temp * (nTrans - 1), 1]);
            error_con_len = [length(find(transError_con_col == 1)), length(find(transError_con_col == 2)), ...
                             length(find(transError_con_col == 3)), length(find(transError_con_col == 4))];

            error_pos_len = [length(find(transError_loc_col == 1)), length(find(transError_loc_col == 2)), ...
                             length(find(transError_loc_col == 3)), length(find(transError_loc_col == 4))];

            % ---- proportion of correct responses if previous item
            % is 1) correctly or 2) incorrectly reported ----
            % transAcc_count_marg_subj = nan(subLen, 4, 2); % 4: 4 different counts; 2: item and location
            % transAcc_count_join_subj = nan(subLen, 4, 2);
            % No simulations for the full retrieval
            % ---- Item ----
            transAcc_count_marg_subj(iSub, :, 1, ij) = error_con_len; % 4: 4 different counts; 2: item and location

            % ---- Location ----
            transAcc_count_marg_subj(iSub, :, 2, ij) = error_pos_len;
        end

        %% ----------Binding evidence----------
        % Comparison between 1) the previous transition is correct, and
        % current other dimension is correct vs. 2) the previous transition
        % is correct, and current other dimension is incorrect
        % Hypothesis: if participants real use the binding information,
        % then there should be significant difference between the two kinds
        % of trials
        for ij = 1 : nSim
            slotCorr_con = slotCorr_marg_con(:, :, ij);
            slotCorr_pos = slotCorr_marg_pos(:, :, ij);

            binds_conPctr_counts = cell(2, 4); % 2: (Item|Pos) and (Pos|Item)
            for ijT = 1 : size(slotCorr_pos, 1)
                slotCorr_con_ij = slotCorr_con(ijT, :);
                slotCorr_pos_ij = slotCorr_pos(ijT, :);
                % +++++++++++++++++ (Item|Pos) +++++++++++++++++
                for iTr = 2 : nTrans
                    if slotCorr_con_ij(iTr - 1) == 1 && slotCorr_pos_ij(iTr) == 1
                        binds_conPctr_counts{1, 1} = [binds_conPctr_counts{1, 1}; slotCorr_con_ij(iTr)];

                    elseif slotCorr_con_ij(iTr - 1) == 1 && slotCorr_pos_ij(iTr) == 0
                        binds_conPctr_counts{1, 2} = [binds_conPctr_counts{1, 2}; slotCorr_con_ij(iTr)];

                    elseif slotCorr_con_ij(iTr - 1) == 0 && slotCorr_pos_ij(iTr) == 1
                        binds_conPctr_counts{1, 3} = [binds_conPctr_counts{1, 3}; slotCorr_con_ij(iTr)];

                    elseif slotCorr_con_ij(iTr - 1) == 0 && slotCorr_pos_ij(iTr) == 0
                        binds_conPctr_counts{1, 4} = [binds_conPctr_counts{1, 4}; slotCorr_con_ij(iTr)];

                    end
                end
                % +++++++++++++++++ (Pos|Item) +++++++++++++++++
                for iTr = 2 : nTrans
                    if slotCorr_pos_ij(iTr - 1) == 1 && slotCorr_con_ij(iTr) == 1
                        binds_conPctr_counts{2, 1} = [binds_conPctr_counts{2, 1}; slotCorr_pos_ij(iTr)];

                    elseif slotCorr_pos_ij(iTr - 1) == 1 && slotCorr_con_ij(iTr) == 0
                        binds_conPctr_counts{2, 2} = [binds_conPctr_counts{2, 2}; slotCorr_pos_ij(iTr)];

                    elseif slotCorr_pos_ij(iTr - 1) == 0 && slotCorr_con_ij(iTr) == 1
                        binds_conPctr_counts{2, 3} = [binds_conPctr_counts{2, 3}; slotCorr_pos_ij(iTr)];

                    elseif slotCorr_pos_ij(iTr - 1) == 0 && slotCorr_con_ij(iTr) == 0
                        binds_conPctr_counts{2, 4} = [binds_conPctr_counts{2, 4}; slotCorr_pos_ij(iTr)];
                    end
                end
            end
            % ------Calculate the proportion of correctness------
            for iC = 1 : 4
                % ------Proportion------
                % ****** the denominator is the total data points in each catetory ******
                binds_conPctr_marg_subj(iSub, iC, 1, ij) = length(find(binds_conPctr_counts{1, iC} == 1)) ./ length(binds_conPctr_counts{1, iC});
                binds_conPctr_marg_subj(iSub, iC, 2, ij) = length(find(binds_conPctr_counts{2, iC} == 1)) ./ length(binds_conPctr_counts{2, iC});
                % ------Trial numbers------
                binds_conPctr_marg_subj(iSub, iC, 3, ij) = length(find(binds_conPctr_counts{1, iC} == 1)) ./ length(cell2mat((binds_conPctr_counts(1, :))'));
                binds_conPctr_marg_subj(iSub, iC, 4, ij) = length(find(binds_conPctr_counts{2, iC} == 1)) ./ length(cell2mat((binds_conPctr_counts(2, :))'));
            end
        end

    end
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

    % ----binding evidence----
    binds_conPctr_group{1, iGrp} = binds_conPctr_marg_subj;
    
    % ----transition evidence----
    transAcc_count_group{1, iGrp} = transAcc_count_marg_subj;

end

%% save the data for YA+OA in each condition
%% save the descriptive data
% save([CLdata_folder, 'acc_group_YAOA_', suffixWord, '.mat'], 'acc_group');
% save([CLdata_folder, 'acc_subj_orderUP_YAOA_', suffixWord, '.mat'], 'acc_subj_orderUP_group');
% save([CLdata_folder, 'FA_lure_YAOA_', suffixWord, '.mat'], 'FA_lure_group');
% save([CLdata_folder, 'binds_conPctr_YAOA_', suffixWord, '.mat'], 'binds_conPctr_group');
% save([CLdata_folder, 'acc_group_post_YAOA_', suffixWord, '.mat'], 'acc_group_post');


% !!! Determine what should be saved for the subsequent analysis !!!




%% Data for Figure 2E: plotting the evidence for transition learning –– proportion of correct responses when the previous item/loc correct versus incorrect
% added by XR @ Sep 14 2025
% ------Transition evidence------
% transAcc_count_group = cell(2, nGroup); % 2: marginal and joint
% transAcc_count_firstHalf_group  = cell(2, nGroup);
% transAcc_count_secondHalf_group = cell(2, nGroup);
% transAcc_count_marg_subj = nan(subLen, 4, 2); % 4: 4 different counts; 2: item and location
% transAcc_count_join_subj = nan(subLen, 4, 2);
transAcc_flg = 0;
if transAcc_flg == 0    % all responses per retrieval test
    transAcc_count_plot = transAcc_count_group;
end
transAcc_plot_group = cell(1, nGroup); % only partial retrieval
for iGrp = 1 : nGroup % YA and OA
    transAcc_count_ij = transAcc_count_plot{1, iGrp};
    % transAcc_count_marg_subj = nan(subLen, 4, 2, nSim); % 4: 4 different counts; 2: item and location

    %% For the simulation, only the partial retrievals were simulated 
    transAcc_plot = nan(size(transAcc_count_ij, 1), 4, nSim); % 4: 1-2, accuracy for item transition; 3-4, accuracy for location transition
    for ij = 1 : nSim
        for iSubj = 1 : size(transAcc_count_ij, 1)
            countLen_item_ii = squeeze(transAcc_count_ij(iSubj, :, 1, ij));
            countLen_loc_ii  = squeeze(transAcc_count_ij(iSubj, :, 2, ij));
            % ------ Item ------
            if (countLen_item_ii(1) + countLen_item_ii(2)) ~= 0
                transAcc_plot(iSubj, 1, ij) = countLen_item_ii(1) / (countLen_item_ii(1) + countLen_item_ii(2));
            end
            if (countLen_item_ii(3) + countLen_item_ii(4)) ~= 0
                transAcc_plot(iSubj, 2, ij) = countLen_item_ii(3) / (countLen_item_ii(3) + countLen_item_ii(4));
            end

            % ------ Location ------
            if (countLen_loc_ii(1) + countLen_loc_ii(2)) ~= 0
                transAcc_plot(iSubj, 3, ij) = countLen_loc_ii(1) / (countLen_loc_ii(1) + countLen_loc_ii(2));
            end
            if (countLen_loc_ii(3) + countLen_loc_ii(4)) ~= 0
                transAcc_plot(iSubj, 4, ij) = countLen_loc_ii(3) / (countLen_loc_ii(3) + countLen_loc_ii(4));
            end
        end
    end
    transAcc_plot_group{1, iGrp} = transAcc_plot;
end

%% color settings
colorSets = [0.98, 0.72, 0.69; ...
             0.97, 0.85, 0.67; ...
             0.33, 0.73, 0.83; ...
             0.72, 0.80, 0.88; ...
             0.54, 0.67, 0.20; ...
             0.82, 0.92, 0.78; ...
             0.78, 0.50, 0.75; ...
             0.86, 0.80, 0.89; ...
             0.75, 0.56, 0; ...
             0.40, 0.40, 0.40];

iGrp = 1;
color_Grp = colorSets([iGrp+1, iGrp+3, iGrp+5], :);

colorGrp = [230, 85, 13; ...
            253, 141, 60; ...
            253, 190, 133; ...%% content report: 3 groups
            49, 130, 189; ...
            107, 174, 214; ...
            189, 215, 231; ...%% position report: 3 groups
            117, 107, 177; ...
            158, 154, 200; ...
            203, 201, 226; ...%% reconstruction report: 3 gruops
            49, 163, 84; ...
            116, 196, 118; ...
            186, 228, 179] ./ 255; %% recons post-test: 3 groups

%% ******* Part 1: YA vs. OA for each curriclum ******
%% ---------- Figure 2E in Experiment 2 (replication in Experiment 1); transition accurcy ----------
figKey = 1;  % 0: figure for presentation; 1: figure for AI.
if figKey == 0
    barLineWid = 2;
    errLineWid = 3;
    refLineWid = 1;
elseif figKey == 1
    barLineWid = 1;
    errLineWid = 1.5; %2;
    refLineWid = 0.5;
end
barPos = [1, 1.7, 2.0, 2.7];
condsWord = 'partial (simulations)';
for iGrp = 1 : nGroup % YA and OA
    transAcc_iGrp_sims = transAcc_plot_group{1, iGrp}; % transAcc_plot = nan(size(transAcc_count_ij, 1), 4, nSim); 
    if iGrp == 1
        disp('------YA------')
    elseif iGrp == 2
        disp('------OA------')
    end
    figure('Position', [100 100 150 120]), clf;
    for iDm = 1 : 2 % item or location dimension
        if iDm == 1
            color_iCp = [color_Grp(1, :); 1, 1, 1]; % facecolor
            color_iEd = [0, 0, 0; 0, 0, 0]; % edgecolor
            dimWords  = 'item';
        elseif iDm == 2
            color_iCp = [color_Grp(2, :); 1, 1, 1];
            color_iEd = [0, 0, 0; 0, 0, 0];
            dimWords  = 'location';
        end
        iDm_idx = (iDm - 1) * 2 + 1 : iDm * 2;

        % ------ average across participants for each simulation ------
        transAcc_iGrp_sims_iDm = transAcc_iGrp_sims(:, iDm_idx, :); 
        [simAvg, ~, sim_qL, sim_qU] = Mean_and_Se(squeeze(nanmean(transAcc_iGrp_sims_iDm, 1)), 2, 0.05);

        barPos_i = barPos(iDm_idx);
        plot(barPos_i, simAvg, 'Color', [0, 0, 0], 'LineStyle', '-', 'LineWidth', errLineWid); hold on;
        for jDm = 1 : 2 % 2: previous report is correct or incorrect
            if jDm == 1
                preWords = 'preCorrect';
            elseif jDm == 2
                preWords = 'preIncorrect';
            end
            errorbar(barPos_i(jDm), simAvg(jDm), simAvg(jDm)-sim_qL(jDm), sim_qU(jDm)-simAvg(jDm), 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid); hold on;
            plot(barPos_i(jDm), simAvg(jDm), 'Marker', 'o', 'MarkerSize', 4.5, 'MarkerEdgeColor', color_iEd(jDm, :), 'MarkerFaceColor', color_iCp(jDm, :), 'LineStyle', '-'); hold on;
            % ------ Statistical tests ------
            disp(['======== ', condsWord, '-', dimWords, '-', preWords, '========']);
        end
        for jDm = 1 : 2 % 2: previous report is correct or incorrect
            errorbar(barPos_i(jDm), simAvg(jDm), simAvg(jDm)-sim_qL(jDm), sim_qU(jDm)-simAvg(jDm), 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid); hold on;
            plot(barPos_i(jDm), simAvg(jDm), 'Marker', 'o', 'MarkerSize', 4.5, 'MarkerEdgeColor', color_iEd(jDm, :), 'MarkerFaceColor', color_iCp(jDm, :), 'LineStyle', '-'); hold on;
        end
    end
    xlim([0.6, 3.1]);
    ylim([0, 1]);
    if figKey == 0
        % ------For presentation------
        plot(xlim, [1/5, 1/5], 'Color', [0, 0, 0], 'LineStyle', ':', 'LineWidth', 1); hold on;
        set(gca, 'LineWidth', 2);
        set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'FontName', 'Arial');
        set(gca, 'XTick', '', 'XTickLabel', '');
        set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', 0 : 0.5 : 1);
    elseif figKey == 1
        % ------For Adobe Illustrator------
        %plot(xlim, [1/5, 1/5], 'Color', [0, 0, 0], 'LineStyle', ':', 'LineWidth', refLineWid); hold on;
        set(gca, 'LineWidth', 0.6); % 0.8
        set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
        set(gca, 'XTick', '', 'XTickLabel', '');
        set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', {'', '', ''});
    end
    box off;
end

%% ---------- Figure 2G in Experiment 2 (replication in Experiment 1): grand average of the binding score for the other dimension correct vs. incorrect in YA and OA ----------
figKey = 1;  % 0: figure for presentation; 1: figure for AI.
if figKey == 0
    barLineWid = 2;
    errLineWid = 3;
    refLineWid = 1;
elseif figKey == 1
    barLineWid = 1;
    errLineWid = 1.5; %2;
    refLineWid = 0.5;
end
barPos = [1, 1.7];
binds_dataAnal = binds_conPctr_group; % binds_conPctr_marg_subj = nan(subLen, 4, 4, nSim); % the 2nd 2: (1-2) proportion: item on position and position on item; (3-4) detected response numbers
binds_dataAnal_grandAvg = cell(1, nGroup);
bindScore_grandAvg = cell(1, nGroup);
for iGrp = 1 : nGroup
    if iGrp == 1
        disp('------YA------')
    elseif iGrp == 2
        disp('------OA------')
    end
    %%% ------ Average across different dimension ------
    %%% ----Partial retrieval----
    binds_dataAnal_Tmp = nan(size(binds_dataAnal{1, iGrp}, 1), 2, nSim);
    for iSim = 1 : nSim
        binds_dataAnal_partial = nanmean(binds_dataAnal{1, iGrp}(:, :, 1 : 2, iSim), 3); % subj * 4 * 2
        binds_dataAnal_partial = [nanmean(binds_dataAnal_partial(:, [1, 3]), 2), nanmean(binds_dataAnal_partial(:, [2, 4]), 2)];
        binds_dataAnal_Tmp(:, :, iSim) = binds_dataAnal_partial;
    end
    binds_dataAnal_grandAvg{1, iGrp} = binds_dataAnal_Tmp;

    figure('Position', [100 100 80 120]), clf;
    binds_grandAvg_iGrp = binds_dataAnal_Tmp;
    [simAvg, ~, sim_qL, sim_qU] = Mean_and_Se(squeeze(nanmean(binds_grandAvg_iGrp, 1)), 2, 0.05);
    barPos_i = barPos;
    plot(barPos_i, simAvg, 'Color', [0, 0, 0], 'LineStyle', '-', 'LineWidth', errLineWid); hold on;
    for jDm = 1 : 2 % 2: previous report is correct or incorrect
        if jDm == 1
            colorFace_jDm = [0, 0, 0];
        elseif jDm == 2
            colorFace_jDm = [1, 1, 1];
        end
        errorbar(barPos_i(jDm), simAvg(jDm), simAvg(jDm)-sim_qL(jDm), sim_qU(jDm)-simAvg(jDm), 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid); hold on;
        plot(barPos_i(jDm), simAvg(jDm), 'Marker', 'o', 'MarkerSize', 4.5, 'MarkerEdgeColor', [0, 0, 0], 'MarkerFaceColor', colorFace_jDm, 'LineStyle', '-'); hold on;
    end
    xlim([0.6, 2.1]);
    ylim([0, 1]);
    if figKey == 0
        % ------For presentation------
        set(gca, 'LineWidth', 2);
        set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'FontName', 'Arial');
        set(gca, 'XTick', '', 'XTickLabel', '');
        set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', 0 : 0.5 : 1);
    elseif figKey == 1
        % ------For Adobe Illustrator------
        set(gca, 'LineWidth', 0.6); % 0.8
        set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
        set(gca, 'XTick', '', 'XTickLabel', '');
        set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', {'', '', ''});
    end
    box off;

end