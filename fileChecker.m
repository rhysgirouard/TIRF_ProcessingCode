function newFolderPath = fileChecker(oldFolderPath)
%NOTE: it wouild be good to set a timer and give the user a warning
%check if the folder does not exist in the same location
    if exist(oldFolderPath, 'file') == 7
        newFolderPath = oldFolderPath;
    elseif exist(oldFolderPath, 'file') == 0
        disp('updating file path')
        %establish how much is still the same and assign to knownPath
        filePathParts = split(oldFolderPath, filesep);
        filePathLength = size(filePathParts, 1);
        sampleName = filePathParts{filePathLength};
        knownPath = [filesep, filePathParts{2}];
        for i = 3:filePathLength
            nextFolder = fullfile(knownPath, filePathParts{i});
            if exist(nextFolder, 'file') ~= 0
                knownPath = nextFolder;
            end
        end
        disp(['Conserved Filepath: ', knownPath])
        
        % Set the maximum allowable time in seconds
        maxTime = 3;

        % Asynchronously execute your long-running function
        f = parfeval(backgroundPool, @fileSearch, 1, knownPath, sampleName);

        % Wait for the function to finish or exceed the maximum time
        timer = tic;
        searchFinished = true;
        while ~strcmp(f.State, 'finished')
            elapsedTime = toc(timer);
            if elapsedTime > maxTime
                cancel(f); % Cancel the execution
                disp('File search timed out. File not found')
                searchFinished = false;
            end
        end
        
        %if the search completed and found the file assign the output
        if searchFinished == true && ~isempty(fetchOutputs(f))
            newFile = fetchOutputs(f);
            newFolderPath = fullfile(newFile.folder, newFile.name);
        %if the search failed ask the user to select the correct folder
        else
            path = uigetdir(knownPath, 'Select New File Location');
            if isequal(path,0) 
                disp('File selection canceled')
                error('no file selected')
            else
                newFolderPath = path;
            end
        end
    else
        error('Provided path exists but is not a folder')
    end
end

function newFile = fileSearch(knownPath, sampleName)
    newFile = dir(fullfile(knownPath, '**', append('*',sampleName)));
end