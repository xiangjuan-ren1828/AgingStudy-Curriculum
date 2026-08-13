% seqMemTask_Curricula_Autocorrelation.m
% write by XR @ August 6 2026
% Two main purposes for this analysis:
% (1) examine if there is any autocorrelated noise pattern across
% transition within a retrieval;
% (2) examine whether there is correlated erroneous pattern between
% partial and full retrieval

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
expId   = expList{3};
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

%% loop over groups and participants
% ------ Quantify the autocorrelated noise within each retrieval ------
% For example, if participants made an error in the very first response of
% the retrieval, whether they have larger probability to make error again
% in the later responses
% here we convert error into ** accuracy **.
err_ratio_group = cell(2, nGroup); % 2: partial and full retrieval

% error patterns between partial and full retrieval
% Method 1: trial-wise calculation
nSim = 50;
error_consistencyScore_group = cell(2, nGroup); % 1: real data; 2: simulations;

% Method 2: across trials -- confusion matrix
%%% ------ correlation between error patterns which were
%%% accumulated across trials ------
errPattern_cor_group = cell(1, nGroup);

%%
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

    % autocorrelated noise pattern within each dimension -- 4 different conditions:
    % 1) 1st response was wrong;
    % 2) (1st correct) 2nd wrong;
    % 3) (1st and 2nd correct) 3rd wrong;
    % 4) (1-3 correct) 4th wrong;
    err_ratio_marg_subj = nan(subLen, 4, 4, 2); % 1st 4: four conditions; 2nd 4: the maximal autocorrleation quantification length; 1st 2: object and location;
    err_ratio_join_subj = nan(subLen, 4, 4, 2); 

    % error patterns between partial and full retrieval
    % Method 1: trial-wise calculation
    error_consistencyScore_subj = nan(subLen, 2);
    error_consistencyScore_subj_nSim = nan(subLen, 2, nSim);

    % Method 2: across trials -- confusion matrix
    %%% ------ correlation between error patterns which were
    %%% accumulated across trials ------
    errPattern_cor_subj = nan(subLen, 2, 2); % 1st 2: object and locaton dimension; 2nd 2: Pearson and Spearman's r

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
                % ------ Marginal reports in the reconstruction report ------
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

        %% ----------Transition accuracy and binding accuracy----------
        % Corretness (1/0) for each response
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
        slotCorr_marg_con = nan(sum(~reconsOnly), nTrans); % 1: the response is correct; 0: incorrect response;
        slotCorr_marg_pos = nan(sum(~reconsOnly), nTrans);
        slotCorr_join_con = nan(nEpi, nTrans);
        slotCorr_join_pos = nan(nEpi, nTrans);
        for iTrans = 1 : (nTrans)
            % ----Content reports in the marginal reports trials----
            slotCorr_marg_con(:, iTrans) = (conRep_threeRep_mat(:, iTrans) == iTrans);
            % ----Position reports in the marginal reports trials----
            slotCorr_marg_pos(:, iTrans) = (locRep_threeRep_mat(:, iTrans) == iTrans);

            % ----Content reports in the reconstruction reports trials----
            slotCorr_join_con(:, iTrans) = (conRep_reconRep_mat(:, iTrans) == iTrans);
            % ----Position reports in the reconstruction reports
            % trials----
            slotCorr_join_pos(:, iTrans) = (locRep_reconRep_mat(:, iTrans) == iTrans);
        end

        %% Quantify the autocorrelated noise within each retrieval
        % 4 different conditions: 
        % 1) 1st response was wrong; 
        % 2) (1st correct) 2nd wrong; 
        % 3) (1st and 2nd correct) 3rd wrong; 
        % 4) (1-3 correct) 4th wrong;
        % All calculations have an addiitonal contranit that the correct
        % response is still available at the moment of responding
        for ij = 1 : 2 % partial and full retrieval
            if ij == 1
                % ------ Binary ------
                slotCorr_con = slotCorr_marg_con;
                slotCorr_pos = slotCorr_marg_pos;
                % ------ Responses ------
                slotResp_con = conRep_threeRep_mat;
                slotResp_pos = locRep_threeRep_mat;
                trlLen_temp  = sum(~reconsOnly);
            elseif ij == 2
                % ------ Binary ------
                slotCorr_con = slotCorr_join_con;
                slotCorr_pos = slotCorr_join_pos;
                % ------ Responses ------
                slotResp_con = conRep_reconRep_mat;
                slotResp_pos = locRep_reconRep_mat;
                trlLen_temp  = nEpi;
            end

            % ------ For each response, whether the correct option is still available ------
            correctResp_avail_con = nan(trlLen_temp, (nTrans - 1));
            correctResp_avail_pos = nan(trlLen_temp, (nTrans - 1));
            for iEpi = 1 : trlLen_temp
                for iTrans = 1 : (nTrans - 1)
                    % ------ Object retrieval ------
                    iTrans_from_con_iEpi  = slotResp_con(iEpi, 1 : iTrans); % the order here has beeen reorgainzed based on the (sorted) true order
                    % what have been selected and what have been left
                    % in the candidate options
                    remaining_options_con = setdiff(1 : 1 : (nTrans + nDtr), iTrans_from_con_iEpi);
                    if ismember(iTrans + 1, remaining_options_con) % the current correct response was not taken yet
                        correctResp_avail_con(iEpi, iTrans) = 1;
                    else % the current correct response was incorrectly taken
                        correctResp_avail_con(iEpi, iTrans) = 0;
                    end

                    % ------ Location retrieval ------
                    iTrans_from_loc_iEpi  = slotResp_pos(iEpi, 1 : iTrans);
                    remaining_options_loc = setdiff(1 : 1 : (nTrans + nDtr), iTrans_from_loc_iEpi);
                    if ismember(iTrans + 1, remaining_options_loc) % the current correct response was not taken yet
                        correctResp_avail_pos(iEpi, iTrans) = 1;
                    else % the current correct response was incorrectly taken
                        correctResp_avail_pos(iEpi, iTrans) = 0;
                    end
                end
            end

            for iConds = 1 : 4 % 4 conditions
                if iConds == 1
                    err_idx_item = find(slotCorr_con(:, 1) == 0 & correctResp_avail_con(:, 1) == 1); % previous respone is wrong and correct option in the current response is still available
                    err_idx_loc  = find(slotCorr_pos(:, 1) == 0 & correctResp_avail_pos(:, 1) == 1);

                elseif iConds == 2
                    err_idx_item = find(slotCorr_con(:, 1) == 1 & slotCorr_con(:, 2) == 0 ...
                                        & correctResp_avail_con(:, 2) == 1);
                    err_idx_loc  = find(slotCorr_pos(:, 1) == 1 & slotCorr_pos(:, 2) == 0 ...
                                        & correctResp_avail_pos(:, 2) == 1);

                elseif iConds == 3
                    err_idx_item = find(slotCorr_con(:, 1) == 1 & slotCorr_con(:, 2) == 1 & slotCorr_con(:, 3) == 0 ...
                                        & correctResp_avail_con(:, 3) == 1);
                    err_idx_loc  = find(slotCorr_pos(:, 1) == 1 & slotCorr_pos(:, 2) == 1 & slotCorr_pos(:, 3) == 0 ...
                                        & correctResp_avail_pos(:, 3) == 1);

                elseif iConds == 4
                    err_idx_item = find(slotCorr_con(:, 1) == 1 & slotCorr_con(:, 2) == 1 & slotCorr_con(:, 3) == 1 & slotCorr_con(:, 4) == 0 ...
                                        & correctResp_avail_con(:, 4) == 1);
                    err_idx_loc  = find(slotCorr_pos(:, 1) == 1 & slotCorr_pos(:, 2) == 1 & slotCorr_pos(:, 3) == 1 & slotCorr_pos(:, 4) == 0 ...
                                        & correctResp_avail_pos(:, 4) == 1);
                end

                % check the error proportion for the subsequent responses
                if ~isempty(err_idx_item)
                    err_trial_item = slotCorr_con(err_idx_item, (iConds + 1) : end);
                    err_ratio_item = nansum(err_trial_item == 1, 1) ./ size(err_trial_item, 1);
                else
                    err_ratio_item = nan(1, length(iConds : 4));
                end
                if ~isempty(err_idx_loc)
                    err_trial_loc  = slotCorr_pos(err_idx_loc, (iConds + 1) : end);
                    err_ratio_loc  = nansum(err_trial_loc == 1, 1) ./ size(err_trial_loc, 1);
                else
                    err_ratio_loc  = nan(1, length(iConds : 4));
                end

                if ij == 1
                    err_ratio_marg_subj(iSub, iConds, iConds : end, 1) = err_ratio_item;
                    err_ratio_marg_subj(iSub, iConds, iConds : end, 2) = err_ratio_loc;
                elseif ij == 2
                    err_ratio_join_subj(iSub, iConds, iConds : end, 1) = err_ratio_item;
                    err_ratio_join_subj(iSub, iConds, iConds : end, 2) = err_ratio_loc;
                end
            end
        end

        %% Quantify the error patterns between partial and full retrievals
        % Only the three-retrieval trials
        % whether the errors happen during full retrievals imitate the way
        % in their previous partial retrieval
        % ~~~~ only the three-retrieval trials ~~~~
        slotCorr_threeRet_marg_obj = slotCorr_marg_con; % 1: the response is correct; 0: incorrect response;
        slotCorr_threeRet_marg_loc = slotCorr_marg_pos;
        slotCorr_threeRet_full_obj = slotCorr_join_con(reconsOnly == 0, :);
        slotCorr_threeRet_full_loc = slotCorr_join_pos(reconsOnly == 0, :);
        objRep_threeRet_marg = conRep_threeRep_mat;
        locRep_threeRet_marg = locRep_threeRep_mat;
        objRep_threeRet_full = conRep_reconRep_mat(reconsOnly == 0, :);
        locRep_threeRet_full = locRep_reconRep_mat(reconsOnly == 0, :);
        uniCombSeq_threeRet  = uniCombSeq(reconsOnly == 0, :); % (nEpi, 2); Col1: object; Col2: location;

        % ------ Method 1: trial-wise error consistency rate ------
        nThree_trialLen = length(find(reconsOnly == 0));

        error_consistencyScore_trial = nan(nThree_trialLen, 2);
        for iTrl = 1 : nThree_trialLen
            % 1. object retrieval
            % ------ partial retrieval ------
            slotCorr_marg_obj_iTrl = slotCorr_threeRet_marg_obj(iTrl, :);
            objRep_marg_iTrl       = objRep_threeRet_marg(iTrl, :);
            % ------ full retrieval ------
            slotCorr_full_obj_iTrl = slotCorr_threeRet_full_obj(iTrl, :);
            objRep_full_iTrl       = objRep_threeRet_full(iTrl, :);
            % ------ object-dimension error consistency rate ------
            if ~all(slotCorr_marg_obj_iTrl == 1) % error exists
                obj_error_marg = objRep_marg_iTrl(slotCorr_marg_obj_iTrl == 0);
                obj_error_full = objRep_full_iTrl(slotCorr_marg_obj_iTrl == 0);
                cs_score_obj   = sum(obj_error_marg == obj_error_full) / length(obj_error_marg); % if the error was completely inherited, the consistency score should be 1.
                error_consistencyScore_trial(iTrl, 1) = cs_score_obj;
            end

            % 2. location retrieval
            % ------ partial retrieval ------
            slotCorr_marg_loc_iTrl = slotCorr_threeRet_marg_loc(iTrl, :);
            locRep_marg_iTrl       = locRep_threeRet_marg(iTrl, :);
            % ------ full retrieval ------
            slotCorr_full_loc_iTrl = slotCorr_threeRet_full_loc(iTrl, :);
            locRep_full_iTrl       = locRep_threeRet_full(iTrl, :);
            % ------ location-dimension error consistency rate ------
            if ~all(slotCorr_marg_loc_iTrl == 1) % error exists
                loc_error_marg = locRep_marg_iTrl(slotCorr_marg_loc_iTrl == 0);
                loc_error_full = locRep_full_iTrl(slotCorr_marg_loc_iTrl == 0);
                cs_score_loc   = sum(loc_error_marg == loc_error_full) / length(loc_error_marg); % if the error was completely inherited, the consistency score should be 1.
                error_consistencyScore_trial(iTrl, 2) = cs_score_loc;
            end
        end
        error_consistencyScore_subj(iSub, :) = nanmean(error_consistencyScore_trial, 1);

        %%% simulations for the error consistency rate: shuffling the
        %%% correspondence between the partial and full retrieval within
        %%% each participant
        for iSim = 1 : nSim
            % ---- randomize the full retrievals ----
            shuffle_idx = randperm(nThree_trialLen);
            slotCorr_threeRet_full_obj_iSim = slotCorr_threeRet_full_obj(shuffle_idx, :);
            slotCorr_threeRet_full_loc_iSim = slotCorr_threeRet_full_loc(shuffle_idx, :);
            objRep_threeRet_full_iSim       = objRep_threeRet_full(shuffle_idx, :);
            locRep_threeRet_full_iSim       = locRep_threeRet_full(shuffle_idx, :);
            % ------ trial-wise error consistency rate ------
            error_consistencyScore_trial_iSim = nan(nThree_trialLen, 2);
            for iTrl = 1 : nThree_trialLen
                % 1. object retrieval
                % ------ partial retrieval ------
                slotCorr_marg_obj_iTrl = slotCorr_threeRet_marg_obj(iTrl, :);
                objRep_marg_iTrl       = objRep_threeRet_marg(iTrl, :);
                % ------ full retrieval ------
                slotCorr_full_obj_iTrl_iSim = slotCorr_threeRet_full_obj_iSim(iTrl, :);
                objRep_full_iTrl_iSim       = objRep_threeRet_full_iSim(iTrl, :);
                % ------ object-dimension error consistency rate ------
                if ~all(slotCorr_marg_obj_iTrl == 1) % error exists
                    obj_error_marg      = objRep_marg_iTrl(slotCorr_marg_obj_iTrl == 0);
                    obj_error_full_iSim = objRep_full_iTrl_iSim(slotCorr_marg_obj_iTrl == 0);
                    cs_score_obj_iSim   = sum(obj_error_marg == obj_error_full_iSim) / length(obj_error_marg); % if the error was completely inherited, the consistency score should be 1.
                    error_consistencyScore_trial_iSim(iTrl, 1) = cs_score_obj_iSim;
                end

                % 2. location retrieval
                % ------ partial retrieval ------
                slotCorr_marg_loc_iTrl = slotCorr_threeRet_marg_loc(iTrl, :);
                locRep_marg_iTrl       = locRep_threeRet_marg(iTrl, :);
                % ------ full retrieval ------
                slotCorr_full_loc_iTrl_iSim = slotCorr_threeRet_full_loc_iSim(iTrl, :);
                locRep_full_iTrl_iSim       = locRep_threeRet_full_iSim(iTrl, :);
                % ------ location-dimension error consistency rate ------
                if ~all(slotCorr_marg_loc_iTrl == 1) % error exists
                    loc_error_marg      = locRep_marg_iTrl(slotCorr_marg_loc_iTrl == 0);
                    loc_error_full_iSim = locRep_full_iTrl_iSim(slotCorr_marg_loc_iTrl == 0);
                    cs_score_loc_iSim   = sum(loc_error_marg == loc_error_full_iSim) / length(loc_error_marg); % if the error was completely inherited, the consistency score should be 1.
                    error_consistencyScore_trial_iSim(iTrl, 2) = cs_score_loc_iSim;
                end
            end
            error_consistencyScore_subj_nSim(iSub, :, iSim) = nanmean(error_consistencyScore_trial_iSim, 1);
        end

        % ------ Method 2: calculate an error confusion matrix across trials ------ 
        % Participants might choose the lure (6)
        errConfMat_marg_obj = zeros(nTrans, nTrans+nDtr, 2); % x-axis: from (correct); y-axis: to (incorrect); 2: two object/location sequences
        errConfMat_marg_loc = zeros(nTrans, nTrans+nDtr, 2);
        errConfMat_full_obj = zeros(nTrans, nTrans+nDtr, 2);
        errConfMat_full_loc = zeros(nTrans, nTrans+nDtr, 2);
        for iTrl = 1 : nThree_trialLen
            % 1. object retrieval
            uniSeq_lab_obj         = uniCombSeq_threeRet(iTrl, 1); % 0 or 1: two unique object sequences
            % ------ partial retrieval ------
            slotCorr_marg_obj_iTrl = slotCorr_threeRet_marg_obj(iTrl, :);
            objRep_marg_iTrl       = objRep_threeRet_marg(iTrl, :);
            % ------ full retrieval ------
            slotCorr_full_obj_iTrl = slotCorr_threeRet_full_obj(iTrl, :);
            objRep_full_iTrl       = objRep_threeRet_full(iTrl, :);
            % ------ error confusion matrix ------
            if ~all(slotCorr_marg_obj_iTrl == 1) % error exists
                obj_error_marg_idx = find(slotCorr_marg_obj_iTrl == 0); % error index
                obj_error_marg_idt = objRep_marg_iTrl(slotCorr_marg_obj_iTrl == 0); % error identity
                for ik = 1 : length(obj_error_marg_idx)
                    from_ik = obj_error_marg_idx(ik);
                    to_ik   = obj_error_marg_idt(ik);
                    if to_ik ~= 0
                        errConfMat_marg_obj(from_ik, to_ik, uniSeq_lab_obj + 1) = errConfMat_marg_obj(from_ik, to_ik, uniSeq_lab_obj + 1) + 1;
                    end
                end
            end
            if ~all(slotCorr_full_obj_iTrl == 1) 
                obj_error_full_idx = find(slotCorr_full_obj_iTrl == 0);
                obj_error_full_idt = objRep_full_iTrl(slotCorr_full_obj_iTrl == 0);
                for ik = 1 : length(obj_error_full_idx)
                    from_ik = obj_error_full_idx(ik);
                    to_ik   = obj_error_full_idt(ik);
                    if to_ik ~= 0
                        errConfMat_full_obj(from_ik, to_ik, uniSeq_lab_obj + 1) = errConfMat_full_obj(from_ik, to_ik, uniSeq_lab_obj + 1) + 1;
                    end
                end
            end

            % 2. location retrieval
            uniSeq_lab_loc         = uniCombSeq_threeRet(iTrl, 2);
            % ------ partial retrieval ------
            slotCorr_marg_loc_iTrl = slotCorr_threeRet_marg_loc(iTrl, :);
            locRep_marg_iTrl       = locRep_threeRet_marg(iTrl, :);
            % ------ full retrieval ------
            slotCorr_full_loc_iTrl = slotCorr_threeRet_full_loc(iTrl, :);
            locRep_full_iTrl       = locRep_threeRet_full(iTrl, :);
            % ------ location-dimension error consistency rate ------
            if ~all(slotCorr_marg_loc_iTrl == 1) % error exists
                loc_error_marg_idx = find(slotCorr_marg_loc_iTrl == 0); % error index
                loc_error_marg_idt = locRep_marg_iTrl(slotCorr_marg_loc_iTrl == 0); % error identity
                for ik = 1 : length(loc_error_marg_idx)
                    from_ik = loc_error_marg_idx(ik);
                    to_ik   = loc_error_marg_idt(ik);
                    if to_ik ~= 0
                        errConfMat_marg_loc(from_ik, to_ik, uniSeq_lab_loc + 1) = errConfMat_marg_loc(from_ik, to_ik, uniSeq_lab_loc + 1) + 1;
                    end
                end
            end
            if ~all(slotCorr_full_loc_iTrl == 1) 
                loc_error_full_idx = find(slotCorr_full_loc_iTrl == 0);
                loc_error_full_idt = locRep_full_iTrl(slotCorr_full_loc_iTrl == 0);
                for ik = 1 : length(loc_error_full_idx)
                    from_ik = loc_error_full_idx(ik);
                    to_ik   = loc_error_full_idt(ik);
                    if to_ik ~= 0
                        errConfMat_full_loc(from_ik, to_ik, uniSeq_lab_loc + 1) = errConfMat_full_loc(from_ik, to_ik, uniSeq_lab_loc + 1) + 1;
                    end
                end
            end
        end
        % ------ error pattern correlation between partial and full retrieval ------
        corr_seq = nan(2, 2, 2); % 1st 2: object and location dimension; 2nd 2: Pearson and Spearman; 3rd 2: two unique sequences per dimension
        for iSeq = 1 : 2 % calculate the correlations for the two unique sequences separately before averaging
            % -- object --
            errConfMat_marg_obj_col = errConfMat_marg_obj(:, :, iSeq); % sum(errConfMat_marg_obj, 3); % sum across the two unique sequences
            errConfMat_marg_obj_col = errConfMat_marg_obj_col(:);
            errConfMat_full_obj_col = errConfMat_full_obj(:, :, iSeq); % sum(errConfMat_full_obj, 3);
            errConfMat_full_obj_col = errConfMat_full_obj_col(:);
            % deleting zero entries
            idx_valid = (errConfMat_marg_obj_col ~= 0) & (errConfMat_full_obj_col ~= 0);
            if sum(idx_valid) > 2
                A = errConfMat_marg_obj_col(idx_valid);
                B = errConfMat_full_obj_col(idx_valid);
                [r1, p1] = corr(A, B, 'Type', 'Pearson');
                [r2, p2] = corr(A, B, 'Type', 'Spearman');
                corr_seq(1, :, iSeq) = [r1, r2];
            end
            % -- location --
            errConfMat_marg_loc_col = errConfMat_marg_loc(:, :, iSeq); % sum(errConfMat_marg_loc, 3); % sum across the two unique sequences
            errConfMat_marg_loc_col = errConfMat_marg_loc_col(:);
            errConfMat_full_loc_col = errConfMat_full_loc(:, :, iSeq); % sum(errConfMat_full_loc, 3);
            errConfMat_full_loc_col = errConfMat_full_loc_col(:);
            % deleting zero entries
            idx_valid = (errConfMat_marg_loc_col ~= 0) & (errConfMat_full_loc_col ~= 0);
            if sum(idx_valid) > 2
                A = errConfMat_marg_loc_col(idx_valid);
                B = errConfMat_full_loc_col(idx_valid);
                [r1, p1] = corr(A, B, 'Type', 'Pearson');
                [r2, p2] = corr(A, B, 'Type', 'Spearman');
                corr_seq(2, :, iSeq) = [r1, r2];
            end
        end
        corr_seq_avg = nanmean(corr_seq, 3);
        errPattern_cor_subj(iSub, 1, :) = corr_seq_avg(1, :);
        errPattern_cor_subj(iSub, 2, :) = corr_seq_avg(2, :);

    end
    err_ratio_group{1, iGrp} = err_ratio_marg_subj;
    err_ratio_group{2, iGrp} = err_ratio_join_subj;

    % error patterns between partial and full retrieval
    % Method 1: trial-wise calculation
    error_consistencyScore_group{1, iGrp} = error_consistencyScore_subj;
    error_consistencyScore_group{2, iGrp} = error_consistencyScore_subj_nSim;

    % Method 2: across trials -- confusion matrix
    %%% ------ correlation between error patterns which were
    %%% accumulated across trials ------
    errPattern_cor_group{iGrp} = errPattern_cor_subj;

end

%% color settings
colorGrad_obj = [217, 72, 1; ...
                 241, 105, 19; ...
                 253, 141, 60; ...
                 253, 174, 107; ...
                 253, 208, 162] ./ 255;

colorGrad_loc = [33, 113, 181; ...
                 66, 146, 198; ...
                 107, 174, 214; ...
                 158, 202, 225; ...
                 198, 219, 239] ./ 255;

color_Grp = [0.97, 0.85, 0.67; ...
             0.72, 0.80, 0.88];

%% plotting the autocorrelated noise pattern: each condition separately
% err_ratio_group = cell(2, nGroup); % 2: partial and full retrieval
% err_ratio_marg_subj = nan(subLen, 4, 4, 2); % 1st 4: four conditions; 2nd 4: the maximal autocorrleation quantification length; 1st 2: object and location;
% err_ratio_join_subj = nan(subLen, 4, 4, 2); 
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

barPos_cell    = cell(4, 1);
barPos_cell{1} = [0.5, 0.7, 0.9, 1.1];
barPos_cell{2} = [nan, 1.3, 1.5, 1.7];
barPos_cell{3} = [nan, nan, 1.9, 2.1];
barPos_cell{4} = [nan, nan, nan, 2.3];
chanceLevel_cell = cell(4, 1);
chanceLevel_cell{1} = [1/5, 1/4, 1/3, 1/2];
chanceLevel_cell{2} = [nan, 1/4, 1/3, 1/2];
chanceLevel_cell{3} = [nan, nan, 1/3, 1/2];
chanceLevel_cell{4} = [nan, nan, nan, 1/2];

for iGrp = 1 : nGroup
    if iGrp == 1
        disp('------YA------')
    elseif iGrp == 2
        disp('------OA------')
    end
    for ij = 1 : 2 % partial and full retrieval
        if ij == 1
            disp('------Partial retrieval------')
        elseif ij == 2
            disp('------Full retrieval------')
        end
        err_ratio_iGrp = err_ratio_group{ij, iGrp};
        for jk = 1 : 2 % object and location (dimension)
            figure('Position', [100 100 600 140]), clf;
            if jk == 1
                colorGrad = colorGrad_obj;
            elseif jk == 2
                colorGrad = colorGrad_loc;
            end
            err_ratio_jk = err_ratio_iGrp(:, :, :, jk); % (subLen, 4, 4)
            [errAvg, errSem] = Mean_and_Se(err_ratio_jk);
            errAvg = squeeze(errAvg);
            errSem = squeeze(errSem);

            for iConds = 1 : 4  % 4 conditions
                barPos_i = barPos_cell{iConds};
                plot(barPos_i(iConds : end), errAvg(iConds, iConds : end), 'Color', [0, 0, 0], 'LineStyle', '-', 'LineWidth', errLineWid); hold on;

                for jConds = iConds : 4 % 4 transitions
                    errorbar(barPos_i(jConds), errAvg(iConds, jConds), errSem(iConds, jConds), 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid); hold on;
                    plot(barPos_i(jConds), errAvg(iConds, jConds), 'Marker', 'o', 'MarkerSize', 4.5, 'MarkerEdgeColor', colorGrad(jConds, :), 'MarkerFaceColor', colorGrad(jConds, :), 'LineStyle', '-'); hold on;

                end
            end
            xlim([0.3, 2.5]);
            ylim([0, 1]);
            plot([1.2, 1.2], ylim, 'k-.', 'LineWidth', refLineWid); hold on;
            plot([1.8, 1.8], ylim, 'k-.', 'LineWidth', refLineWid); hold on;
            plot([2.2, 2.2], ylim, 'k-.', 'LineWidth', refLineWid); hold on;
            % ------ plot the chance level for each condition ------
            for iConds = 1 : 4
                barPos_i = barPos_cell{iConds};
                chanceLevel_i = chanceLevel_cell{iConds};
                for jConds = iConds : 4
                    plot([barPos_i(jConds) - 0.06, barPos_i(jConds) + 0.06], [chanceLevel_i(jConds), chanceLevel_i(jConds)], ...
                        'k:', 'LineWidth', refLineWid); hold on;
                end
            end
            if figKey == 0
                % ------For presentation------
                set(gca, 'LineWidth', 2);
                set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'FontName', 'Arial');
                set(gca, 'XTick', '', 'XTickLabel', '');
                %set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', 0 : 0.5 : 1);
            elseif figKey == 1
                % ------For Adobe Illustrator------
                %plot(xlim, [1/5, 1/5], 'Color', [0, 0, 0], 'LineStyle', ':', 'LineWidth', refLineWid); hold on;
                set(gca, 'LineWidth', 0.6); % 0.8
                set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
                set(gca, 'XTick', [0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3], 'XTickLabel', '');
                set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', {'', '', ''});
            end
            box off;
        end
    end
end

%% plotting the autocorrelated noise pattern: average across conditions
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
barPos_avg = [0.5, 0.7, 0.9, 1.1; ...
              1.5, 1.7, 1.9, 2.1];
chanceLevel_avg = [1/5, 1/4, 1/3, 1/2];

for iGrp = 1 : nGroup
    if iGrp == 1
        disp('------YA------')
    elseif iGrp == 2
        disp('------OA------')
    end
    for ij = 1 : 2 % partial and full retrieval
        if ij == 1
            disp('------Partial retrieval------')
        elseif ij == 2
            disp('------Full retrieval------')
        end
        err_ratio_iGrp = err_ratio_group{ij, iGrp};
        figure('Position', [100 100 400 140]), clf;
        for jk = 1 : 2 % object and location (dimension)
            barPos_i = barPos_avg(jk, :);
            if jk == 1
                colorGrad = colorGrad_obj(1, :);
            elseif jk == 2
                colorGrad = colorGrad_loc(1, :);
            end
            err_ratio_jk = err_ratio_iGrp(:, :, :, jk); % (subLen, 4, 4)
            err_ratio_jk = squeeze(nanmean(err_ratio_jk, 2)); % (subLen, 4)
            [errAvg, errSem] = Mean_and_Se(err_ratio_jk);

            plot(barPos_i, errAvg, 'Color', [0, 0, 0], 'LineStyle', '-', 'LineWidth', errLineWid); hold on;
            for jConds = 1 : 4 % 4 transitions
                errorbar(barPos_i(jConds), errAvg(jConds), errSem(jConds), 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid); hold on;
                plot(barPos_i(jConds), errAvg(jConds), 'Marker', 'o', 'MarkerSize', 4.5, 'MarkerEdgeColor', colorGrad, 'MarkerFaceColor', colorGrad, 'LineStyle', '-'); hold on;
                plot([barPos_i(jConds) - 0.06, barPos_i(jConds) + 0.06], [chanceLevel_avg(jConds), chanceLevel_avg(jConds)], ...
                'k:', 'LineWidth', refLineWid); hold on;
            end
        end
        xlim([0.3, 2.3]);
        ylim([0, 1]);
        plot([1.3, 1.3], ylim, 'k-.', 'LineWidth', refLineWid); hold on;
        
        if figKey == 0
            % ------For presentation------
            set(gca, 'LineWidth', 2);
            set(gca, 'FontSize', 15, 'FontWeight', 'bold', 'FontName', 'Arial');
            set(gca, 'XTick', '', 'XTickLabel', '');
            %set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', 0 : 0.5 : 1);
        elseif figKey == 1
            % ------For Adobe Illustrator------
            %plot(xlim, [1/5, 1/5], 'Color', [0, 0, 0], 'LineStyle', ':', 'LineWidth', refLineWid); hold on;
            set(gca, 'LineWidth', 0.6); % 0.8
            set(gca, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
            set(gca, 'XTick', [0.5, 0.7, 0.9, 1.1, 1.5, 1.7, 1.9, 2.1], 'XTickLabel', '');
            set(gca, 'YTick', 0 : 0.5 : 1, 'YTickLabel', {'', '', ''});
        end
        box off;

    end
end

%% plotting the autocorrelated noise pattern: average across conditions and transitions



%% plotting the error patterns between partial and full retrieval
%% Method 1: trial-wise error consistency score and the corresponding chance-level (via simualtions)
% error_consistencyScore_group{1, iGrp} = error_consistencyScore_subj;
% error_consistencyScore_group{2, iGrp} = error_consistencyScore_subj_nSim;
% error_consistencyScore_subj      = nan(subLen, 2);
% error_consistencyScore_subj_nSim = nan(subLen, 2, nSim);

figKey = 1;
errLineWid = (figKey == 0) * 3 + (figKey == 1) * 1.5;
barPos_err = [1, 1.5; ... % one bar for object and location: YA
              2.2, 2.7];  % OA
figure('Position', [100 100 200 180]), clf;
for iGrp = 1 : nGroup
    bP_iGrp = barPos_err(iGrp, :);
    error_csScore_iGrp      = error_consistencyScore_group{1, iGrp}; % (subLen * 2)
    error_csScore_iGrp_nSim = error_consistencyScore_group{2, iGrp}; % (subLen * 2 * nSim)

    [errAvg, errSem] = Mean_and_Se(error_csScore_iGrp, 1);
    [simAvg, ~, sim_qL, sim_qU] = Mean_and_Se(squeeze(nanmean(error_csScore_iGrp_nSim, 1)), 2, 0.05);
    % ------ the real data ------
    for ii = 1 : 2 % object and location dimension
        if ii == 1
            colorDim = colorGrad_obj(1, :);
        elseif ii == 2
            colorDim = colorGrad_loc(1, :);
        end
        bP = bP_iGrp(ii);
        xRand_iGrp = unifrnd(bP - 0.12, bP + 0.12, size(error_csScore_iGrp, 1), 1);
        xRand_color = 0.4 * colorDim + 0.6 * [1, 1, 1];
        for iSub = 1 : size(error_csScore_iGrp, 1)
            plot(xRand_iGrp(iSub), error_csScore_iGrp(iSub, ii), 'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', xRand_color, 'MarkerEdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 0.6); hold on;
        end
        errorbar(bP, errAvg(ii), errSem(ii), 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid); hold on;
        plot(bP, errAvg(ii), 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', colorDim, 'MarkerEdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 0.8); hold on;
        % ------ simulated chance level ------
        plot([bP - 0.2, bP + 0.2], [simAvg(ii), simAvg(ii)], 'k-', 'LineWidth', 1.5); hold on;
    end

    xlim([0.4, 3.3]);
    ylim([0, 1]);
    if figKey == 1
        set(gca, 'LineWidth', 0.8, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
        set(gca, 'XTick', [1.3, 2.5], 'XTickLabel', {'', ''});
        set(gca, 'YTick', 0 : 0.25 : 1, 'YTickLabel', {'0', '0.25', '0.5', '0.75', '1'});
    end
    %ylabel('Proximity error proportion');
    box off;

end

%% Method 2: across trial confusion matrix
%%% ------ correlation between error patterns which were
%%% accumulated across trials ------
% errPattern_cor_group = cell(1, nGroup);
% errPattern_cor_subj = nan(subLen, 2, 2); % 1st 2: object and locaton dimension; 2nd 2: Pearson and Spearman's r

figKey = 1;
barPos_err = [1, 1.5; ... % one bar for object and location: YA
              2.2, 2.7];  % OA
statMat = nan(nGroup, 4, 2);
for iCr = 1 : 2 % two correlation methods: Pearson and Spearman
    if iCr == 1
        disp('------ Pearson ------');
    elseif iCr == 2
        disp('------ Spearman ------');
    end
    figure('Position', [100 100 200 180]), clf;
    for iGrp = 1 : nGroup
        bP_iGrp = barPos_err(iGrp, :);
        if iGrp == 1
            disp('------ YA ------');
        elseif iGrp == 2
            disp('------ OA ------');
        end
        errPattern_cor_iGrp = errPattern_cor_group{iGrp};
        [errP_avg, errP_sem] = Mean_and_Se(errPattern_cor_iGrp, 1);
        errP_avg = squeeze(errP_avg);
        errP_sem = squeeze(errP_sem);

        for ii = 1 : 2 % object and location dimension
            if ii == 1
                colorDim = colorGrad_obj(1, :);
                disp('------ object ------');
            elseif ii == 2
                colorDim = colorGrad_loc(1, :);
                disp('------ location ------');
            end
            bP = bP_iGrp(ii);
            xRand_iGrp = unifrnd(bP - 0.12, bP + 0.12, size(errPattern_cor_iGrp, 1), 1);
            xRand_color = 0.4 * colorDim + 0.6 * [1, 1, 1];
            for iSub = 1 : size(errPattern_cor_iGrp, 1)
                plot(xRand_iGrp(iSub), errPattern_cor_iGrp(iSub, ii, iCr), 'Marker', 'o', 'MarkerSize', 6, 'MarkerFaceColor', xRand_color, 'MarkerEdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 0.6); hold on;
            end
            errorbar(bP, errP_avg(ii, iCr), errP_sem(ii, iCr), 'Color', 'k', 'LineStyle', 'none', 'LineWidth', errLineWid); hold on;
            plot(bP, errP_avg(ii, iCr), 'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', colorDim, 'MarkerEdgeColor', 'k', 'LineStyle', '-', 'LineWidth', 0.8); hold on;

            % ------ statistical tests ------
            [h, p, ci, stats] = ttest(errPattern_cor_iGrp(:, ii, iCr));
            idx_stat = ii * 2 - 1 : ii * 2;
            statMat(iGrp, idx_stat, iCr) = [p, stats.tstat];
        end
    end
    xlim([0.4, 3.3]);
    ylim([-1, 1]);
    if figKey == 1
        set(gca, 'LineWidth', 0.8, 'FontSize', 10, 'FontWeight', 'bold', 'FontName', 'Arial');
        set(gca, 'XTick', [1.3, 2.5], 'XTickLabel', {'', ''});
        set(gca, 'YTick', [-1, 0, 1], 'YTickLabel', {'-1', '0', '1'});
    end
    %ylabel('Proximity error proportion');
    box off;
end

