function [] = folderFigureMakerFxn(tifFolderPath, firstPass, originalFigs, interactiveFigs)
%folderFigureMakerFxn creates figures for each of the prepared folders 
%   goes through the subfolders in the given folder and creates figures
%   containing the intensity over time graphs for all spots identified in
%   the respective timelapse. If firstPass is 1 it will preprocess; if
%   originalFigs is 1 it will provide original figures; if interactiveFigs
%   is 1 it will generate interactive figures

% List all contents of the supplied folder
contents = dir(tifFolderPath);

% Filter out only the subfolders
subfolderNames = {contents([contents.isdir] & ~ismember({contents.name}, {'.', '..'})).name};

% Convert to string array
subfolderNames = string(subfolderNames);

% Display the list of subfolder names
disp('Subfolders in the current directory:');
disp(subfolderNames);


figures = gobjects(1,numel(subfolderNames));
% Loop through each subfolder and pass its file path to the external
% functions
for i = 1:numel(subfolderNames)
    subfolderPath = fullfile(tifFolderPath, subfolderNames(i));
    subfolderPathChar = convertStringsToChars(subfolderPath);

    % make the figure invisible so that MATLAB doesn't steal focus when
    % editing the figures
    figures(i) = figure('visible', 'off');
    if exist('firstPass', 'var') && firstPass == 1
        folderFigurePrepFxn(subfolderPathChar)
    end
    if exist('originalFigs', 'var') && originalFigs == 1
        tracePlotterOirginalFig(subfolderPathChar);
    end
    if exist('interactiveFigs', 'var') && interactiveFigs == 1        
        interactiveTraceGenerator(subfolderPathChar, figures(i));
    end
end

% make the figures visbile before saving so that you can see them when
% opening them later
for i = 1:numel(subfolderNames)
    subfolderPath = fullfile(tifFolderPath, subfolderNames(i));
    set(figures(i), 'visible', 'on');
    figFilePath = fullfile(subfolderPath, 'interactiveFig');
    savefig(figures(i), figFilePath)
    close(figures(i))
end