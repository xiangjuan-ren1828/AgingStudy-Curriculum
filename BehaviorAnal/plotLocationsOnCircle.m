function plotLocationsOnCircle(pX, pY, radius, boxSize)
% The function was used to plot the 5 targets + 1 distractor during
% location retrieval;
% labeled number 1-5: location order; 6: the distractor
% =========================================================================
% Plot labeled boxes on a dashed circle.
%
%   plotLocationsOnCircle(pX, pY)
%   plotLocationsOnCircle(pX, pY, radius)
%   plotLocationsOnCircle(pX, pY, radius, boxSize)
%
% Inputs:
%   pX      - x coordinates (vector)
%   pY      - y coordinates (vector)
%   radius  - Circle radius (default = 0.35)
%   boxSize - Width/height of each square (default = 0.10)
%
% Example:
%   pX = [-0.1931 0.1931 0.0698 -0.3430 0.3430 -0.0698];
%   pY = [ 0.2919 -0.2919 0.3430 0.0698 -0.0698 -0.3430];
%   plotLocationsOnCircle(pX, pY);

    % Check inputs
    if nargin < 3 || isempty(radius)
        radius = 0.35;
    end

    if nargin < 4 || isempty(boxSize)
        boxSize = 0.10;
    end

    if numel(pX) ~= numel(pY)
        error('pX and pY must have the same length.');
    end

    % Create figure
    figure('Color','w');
    hold on;
    axis equal;

    %% Plot dashed circle
    theta = linspace(0, 2*pi, 500);
    plot(radius*cos(theta), radius*sin(theta), ...
        'k--', 'LineWidth', 1.5);

    %% Plot boxes and labels
    for k = 1:numel(pX)

        rectangle('Position', ...
            [pX(k)-boxSize/2, pY(k)-boxSize/2, boxSize, boxSize], ...
            'FaceColor', [0.85 0.85 0.85], ...
            'EdgeColor', 'k', ...
            'LineWidth', 1.2);

        text(pX(k), pY(k), num2str(k), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 16, ...
            'FontWeight', 'bold');
    end

    %% Formatting
    margin = max(boxSize,0.05);
    xlim([-radius-margin, radius+margin]);
    ylim([-radius-margin, radius+margin]);

    axis off;      % Similar appearance to your example
    hold off;

end