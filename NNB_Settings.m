% This script is for intializing the settings for TIRF Processing

%check if the user is on a system other than mac
if ~ismac
    error('Unsupported Operating System!')
else
    %get matlab path 
    matlabPath = append(matlabroot,'/bin/matlab');
    disp(matlabPath)
    userApproved = false;
    while ~userApproved
        %get fiji path from user
        uiwait(msgbox('Select the Fiji.app in the following popup.'));
        [file, pathToFiji] = uigetfile('Fiji.app', 'Select the Fiji.app', '/Applications/');
        fijiPath = append(pathToFiji, file, '/Contents/MacOS/ImageJ-macosx');
        disp(fijiPath)
        %get code folder path from user
        uiwait(msgbox('Select the code folder in the following popup.'));
        codeFolder = uigetdir('/Documents/', 'Select the code folder');
        disp(codeFolder)
        settingspath = append(codeFolder, "/NNBprocessingSettings.mat");
        %request the spot size and quality threshold
        %Note that these are not currently used by the code
        prompt = {'Enter spot radius:','Enter quality th:'};
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
    save(settingspath,"matlabPath","fijiPath","codeFolder","spot_radius","quality_threshold")
    addpath(codeFolder)
    savepath()

end
