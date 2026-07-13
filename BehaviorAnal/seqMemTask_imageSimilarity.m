% seqMemTask_imageSimilarity
% write by XR @ July 13 2026
% correlations between the image similarity pairs from two different
% methods: CLIP and DINOv2

clear
clc

%%
addpath('tight_subplot/');
addpath(genpath('HierarchicalCluster/'));
addpath(genpath('Aging-SeqMemTask/'));
addpath('fdr_bh');

%% parameters
folder     = '/Users/ren/Projects-NeuroCode/MyExperiment/Aging-SeqMemTask';
bhvDataDir = [folder, '/AgingReplay-OnlineData'];
CLdata_folder   = [bhvDataDir, '/CurriculumPaper-Data/']; % data for the summary of the curriculum learning
CLscript_folder = [folder, '/AgingStudy-Curriculum/BehaviorAnal/'];

%% load the image similarity matrix from the two different methods: CLIP and DINOv2
nImg = 8;
imgMethods = {'clip', 'dinov2'};
confMat_methods = nan(nImg, nImg, length(imgMethods));
for ii = 1 : length(imgMethods)
    confMat_dir = [CLscript_folder, imgMethods{ii}, '_results/'];
    confMat     = load([confMat_dir, imgMethods{ii}, '_visual_similarity.mat']);
    if ii == 1
        confMat_methods(:, :, ii) = confMat.clipSimMat;
    elseif ii == 2
        confMat_methods(:, :, ii) = confMat.visSimMat;
    end
end

%% plotting the image similarity pair from the two methods as a scatter plot
confMat_col = [];
for ii = 1 : length(imgMethods)
    confMat_ii = confMat_methods(:, :, ii);
    upperVals  = confMat_ii(triu(true(size(confMat_ii)),1));
    confMat_col = [confMat_col, upperVals];
end

%%
A_plot = confMat_col(:, 1);
B_plot = confMat_col(:, 2);
[r1, p1] = corr(A_plot, B_plot, 'Type', 'Pearson');
[r2, p2] = corr(A_plot, B_plot, 'Type', 'Spearman');
figure('Position', [100 100 300 300]), clf;
hold on;
plot(A_plot, B_plot, ...
    'Color', [0.5 0.5 0.5], ...
    'Marker', '.', ...
    'MarkerSize', 30, ...
    'LineStyle', 'none'); hold on;
% Fit regression only using valid data
mdl = fitlm(A_plot, B_plot);

xfit = linspace(min(A_plot), max(A_plot), 100)';
[yfit, yCI] = predict(mdl, xfit);

patch([xfit; flipud(xfit)], ...
      [yCI(:, 1); flipud(yCI(:, 2))], ...
      [0.7 0.7 0.7], ...
      'FaceAlpha', 0.2, ...
      'EdgeColor', 'none');

plot(xfit, yfit, ...
    'Color', 'k', ...
    'LineWidth', 2);

% ylim([0, 1]);

set(gca, 'LineWidth', 0.8); % 2
set(gca, 'FontSize', 10, ...
    'FontWeight', 'bold', ...
    'FontName', 'Arial');

% set(gca, 'XTick', [-0.04, 0, 0.04], ...
%     'XTickLabel', '');
% set(gca, 'YTick', 0:0.5:1, ...
%     'YTickLabel', '');

grid off;
box off;


