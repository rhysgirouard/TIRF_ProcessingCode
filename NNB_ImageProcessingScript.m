%Converts the input folder of nd2s into figures for manual step counting. 
clear

%Set settings if they haven't previously been set or load them if they have
%NOTE: old settings must be deleted or NNB_Settings must be run separately 
% to change the settings or after updating the code.
if exist('NNBprocessingSettings.mat', 'file')  ~= 2
    NNB_Settings
elseif exist('NNBprocessingSettings.mat', 'file')  == 2 
   load('NNBprocessingSettings.mat')
end

disp('Settings Imported: ')
disp(['Spot radius: ', num2str(spot_radius)])
disp(['Quality threshold: ', num2str(quality_threshold)])
disp(['Code folder: ', codeFolder])
disp(['Fiji path: ', fijiPath])
answer = '';
while ~strcmp(answer,'Yes')
    if ismac
    uiwait(msgbox('Select the input folder in the following popup.'));
    end
    inputFolder = uigetdir('/Documents/', 'Select the input folder');
    if inputFolder == 0
        error('Execution canceled by folder selection dialog box')
    end

    answer = questdlg(['Does input folder contain only the .nd2 files you' ...
        ' wish to process? i.e. no 3 channel images, partial timelapses,' ...
        ' or other files/folders'], 'Folder Check', 'Yes',...
        'No (Select another folder)', 'Cancel', 'Yes');
    if strcmp(answer, 'Cancel') || strcmp(answer, '')
        error('Execution canceled by folder check dialog box')
    end

end
inputFolder = '/Users/rhysg/Documents/YalePGRA/CodeTestFolder/inputImages';

%add the scripts folder to the path so matlab knows where ImageJ script is
scriptsPath = fullfile(fijiPath, 'scripts');
addpath(scriptsPath)

results_folder = fullfile(inputFolder, 'Results');
mkdir(results_folder)

disp('--------------------')
disp('Settings Initialized')
disp('--------------------')
%% 

ext = '*.nd2';
files = dir(fullfile(inputFolder,ext));
filenames = {files.name};
filenames = sort(filenames);
ImageJ;

import ij.*

figures = gobjects(1,numel(filenames));

for index = 1:length(filenames)
    currentfilename = filenames{index};
    imageName = extractBefore(currentfilename, '.nd2');
    subFolderPath = fullfile(results_folder, imageName);
    mkdir(subFolderPath);
    convertToTiff(inputFolder, subFolderPath, currentfilename);

    tifFilePath = fullfile(subFolderPath, [imageName, '.tif']);

    [~, ~, OriginalStack] = generateFirstFramesProjection(tifFilePath);
    firstFramesProjection = fullfile(subFolderPath, 'First3frames.tif');
    saveTrackStatisticsCSV(firstFramesProjection, subFolderPath, spot_radius, quality_threshold)
    

    prepareFolderForFigureCreation(subFolderPath, OriginalStack)

    % create the figure and make it invisible so that MATLAB doesn't steal 
    % focus when editing the figures
    figures(index) = figure('visible', 'off');
    createInteractiveFigure(subFolderPath, figures(index));

end

for i = 1:numel(filenames)
    imageName = extractBefore(currentfilename, '.nd2');
    subFolderPath = fullfile(results_folder, imageName);
    set(figures(i), 'visible', 'on');
    figFilePath = fullfile(subFolderPath, 'interactiveFig');
    savefig(figures(i), figFilePath)
    close(figures(i))
end

ij.IJ.run("Quit","");
