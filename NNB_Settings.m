% This script is for intializing the settings for TIRF Processing

userApproved = false;
while ~userApproved
    %get fiji path from user
    if ismac
        uiwait(msgbox('Select the Fiji.app in the following popup.'));
        [fijiName, fijiAppPath] = uigetfile('Fiji.app', 'Select the Fiji.app', '/Applications/');
        fijiPath = fullfile(fijiAppPath, fijiName);
    elseif ispc
        fijiPath = uigetdir('C:\Downloads\', 'Select the Fiji.app folder');
        fijiPathPieces = split(fijiPath, filesep);
        indexOfLastPiece = length(fijiPathPieces);
        fijiName = fijiPathPieces(indexOfLastPiece);
    end
    disp(fijiPath)
    if ~strcmp(fijiName, 'Fiji.app')
            error(['Selected name (', fijiName, ') does not match Fiji.app'])
    end
    
    %get code folder path from user
    if ismac
        uiwait(msgbox('Select the code folder in the following popup.'));
    end
    codeFolder = uigetdir('/Documents/', 'Select the code folder');
    disp(codeFolder)
    codePathPieces = split(codeFolder, filesep);
    indexOfLastPiece = length(codePathPieces);
    codeFolderName = codePathPieces(indexOfLastPiece);
    if ~(strcmp(codeFolderName, 'TIRF_ProcessingCode') || strcmp(codeFolderName,'TIRF_ProcessingCode-main'))
            error(['Selected name (', codeFolderName, ') does not match TIRF_ProcessingCode(-main)'])
    end
    
    %request the spot size and quality threshold
    prompt = {'Enter spot radius:','Enter quality threshold:'};
    dlgtitle = 'Input';
    fieldsize = [1 45; 1 45];
    definput = {'3','50'};
    trackmateSettings = inputdlg(prompt,dlgtitle,fieldsize,definput);
    % Loop to validate user input and ensure it's a number
    validInputs = false;
    while ~validInputs
        try
            % Convert input to numbers
            spot_radius = str2double(trackmateSettings{1});
            quality_threshold = str2double(trackmateSettings{2});

            % Check if input is a number
            if isnan(spot_radius) || isnan(quality_threshold)
                % If not a number, display error and prompt again
                error('Input must be numeric');
            else
                % If input is a number, break out of the loop
                validInputs = true;
            end
        catch
            % If an error occurs during conversion, display error and prompt again
            uiwait(errordlg('Invalid input. Please enter numeric values.','Input Error'));
            trackmateSettings = inputdlg(prompt, dlgtitle, fieldsize, definput);
        end
    end

    %should check with user that everything is correct
    question = {'Are these inputs correct?'; append('Fiji path: ', fijiPath);...
        append('Code folder: ', codeFolder); append('Spot Radius: ', num2str(spot_radius));...
        append('Quality threshold: ', num2str(quality_threshold))};
    answer = questdlg(question);
    if strcmp(answer, 'Cancel') || strcmp(answer, '')
        error('Execution canceled')
    elseif strcmp(answer, 'Yes')
        userApproved = true;
    end
end

%Maybe the code should check that these are valid
%save the provided info to a .mat file with the matlab variables
settingspath = fullfile(codeFolder, "NNBprocessingSettings.mat");
save(settingspath,"fijiPath","codeFolder","spot_radius",...
    "quality_threshold")
addpath(codeFolder)
savepath()
