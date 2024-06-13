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

results_folder = append(inputFolder, '/Results');
mkdir(results_folder)

if ismac
    bashPath = fullfile(codeFolder,'convertToTiffBash.sh');
    callToConvert = append('code_folder=', codeFolder, '; fiji_path=',...
        fijiPath, '; input_folder=', inputFolder,...
        '; /bin/bash ', bashPath, ' ',...
        '$code_folder $fiji_path $input_folder');
    system(callToConvert)
elseif ispc
    pwshPath = fullfile(codeFolder, 'convertToTiffPwsh.ps1');
    callToConvert = append('$code_folder=', codeFolder, '; $fiji_path=',...
        fijiPath, '; $input_folder=', inputFolder,...
        pwshPath, ' ',...
        '-code_folder $code_folder -fiji_path $fiji_path -input_folder_var $input_folder');
end
%% 

folderMakerFxn(results_folder)
%% 

if ismac
    callToTrackmate = append('code_folder=', codeFolder, '; fiji_path=',...
        fijiPath, '; input_folder=', inputFolder,...
        '; /bin/bash /Users/rhysg/Documents/YalePGRA/TIRF_ProcessingCode/trackmateBash.sh ',...
        '$code_folder $fiji_path $input_folder');
    system(callToTrackmate)
else
    error('Unsupported OS')
end
%% 

folderFigureMakerFxn(results_folder, 1, 0, 1)

