%This script provides a GUI for running the bash script

if exist('NNBprocessingSettings.mat', 'file')  ~= 2
    NNB_Settings
elseif exist('NNBprocessingSettings.mat', 'file')  == 2 
   load('NNBprocessingSettings.mat')
end
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
%% 

results_folder = fullfile(inputFolder, 'Results');
mkdir(results_folder)


mijPath = fullfile(codeFolder, 'mij.jar');
ijPath = fullfile(codeFolder, 'ij-1.54f.jar');
javaaddpath(mijPath)
javaaddpath(ijPath)

files = dir(inputFolder);
filenames = {files.name};
filenames = sort(filenames);
ext = '.nd2';
Miji(false)

for i = 1:length(filenames)
    filename = filenames{i};
    % Check for file extension
    if endsWith(filename, ext)
        convertToTiff(inputFolder, results_folder, filename);
    end
end
MIJ.exit;

%% 
folderMakerFxn(results_folder)

%% 
clear -regexp ^(?!results_folder$).*
load('NNBprocessingSettings.mat')
javaaddpath(pluginsFolder)
mijPath = fullfile(codeFolder, 'mij.jar');
ijPath = fullfile(codeFolder, 'ij-1.54f.jar');
javaaddpath(mijPath)
javaaddpath(ijPath)
% Initialize ImageJ-MATLAB
ImageJ;

% Get list of subfolders

subfolders = dir(results_folder);

for i = 1:length(subfolders)
    if subfolders(i).isdir && ~startsWith(subfolders(i).name, '.')
        subfolderPath = fullfile(results_folder, subfolders(i).name);
        disp(['Processing subfolder: ' subfolders(i).name]);

        % Get list of files in subfolder
        files = dir(subfolderPath);

        for j = 1:length(files)
            if contains(files(j).name, '3frames.tif', 'IgnoreCase', true)
                filePath = fullfile(subfolderPath, files(j).name);
                disp(['Processing file: ' files(j).name]);
                saveTrackStatisticsCSV(filePath, subfolderPath)
            end
        end
    end
end
disp('Processing complete.');
MIJ.exit
%% 

folderFigureMakerFxn(results_folder, 1, 0, 1)
clear

