%This script provides a GUI for running the bash script

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

scriptsPath = fullfile(fijiPath, 'scripts');
addpath(scriptsPath)

% % should make search for ij version rather than explicitly this
% ijPath = fullfile(fijiPath, 'jars', 'ij-1.54f.jar');
% bioformatsPath = fullfile(fijiPath, 'jars', 'bio-formats');
% pluginsFolder = fullfile(fijiPath, 'plugins');
% 
% javaaddpath(ijPath)
% javaaddpath(bioformatsPath)
% javaaddpath(pluginsFolder)

disp('--------------------')
disp('Settings Initialized')
disp('--------------------')
%% 
disp(newline)
disp('------------------------')
disp('Converting .nd2s to .tif')
disp('------------------------')
results_folder = fullfile(inputFolder, 'Results');
mkdir(results_folder)



files = dir(inputFolder);
filenames = {files.name};
filenames = sort(filenames);
ext = '.nd2';
ImageJ;

import ij.*

for i = 1:length(filenames)
    filename = filenames{i};
    % Check for file extension
    if endsWith(filename, ext)
        convertToTiff(inputFolder, results_folder, filename);
    end
end
disp('-------------------------')
disp('Image Conversion Complete')
disp('-------------------------')
%% 
disp(newline)
disp('------------------------------------')
disp('Preparing image folders for tracking')
disp('------------------------------------')
folderMakerFxn(results_folder)
disp('----------------------------------')
disp('Image folders successfully created')
disp('----------------------------------')

%% 
disp(newline)
disp('--------------------------')
disp('Identifying spot locations')
disp('--------------------------')

% Get list of subfolders
subfolders = dir(results_folder);

%iterate through the list of files
for i = 1:length(subfolders)
    %Check the current filepath leads to a subfolder 
    if subfolders(i).isdir && ~startsWith(subfolders(i).name, '.')
        subfolderPath = fullfile(results_folder, subfolders(i).name);
        disp(['Processing subfolder: ' subfolders(i).name]);
        filePath = fullfile(subfolderPath, 'First3frames.tif');

        %Check that the First3Frames has already been created
        if exist(filePath, "file") ~= 2
            error([filePath, 'does not exist!'])
        end

        saveTrackStatisticsCSV(filePath, subfolderPath, spot_radius, quality_threshold)

    end
end
ij.IJ.run("Quit","");

disp('----------------------------')
disp('Spot Identification Complete')
disp('----------------------------')
%% 
disp(newline)
disp('----------------')
disp('Creating Figures')
disp('----------------')
folderFigureMakerFxn(results_folder, 1, 0, 1)
clear
disp('------------------------')
disp('Figure Creation Complete')
disp('------------------------')