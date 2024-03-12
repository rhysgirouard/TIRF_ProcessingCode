function newFolderPath = fileChecker(oldFolderPath)
%NOTE: it wouild be good to set a timer and give the user a warning
newFolderPath = oldFolderPath;
%check if the figure's filepath has changed
    if exist(oldFolderPath, 'file') == 0
        %establish how much is still the same and assign to knownPath
        filePathParts = split(oldFolderPath, filesep);
        filePathLength = size(filePathParts, 1);
        sampleName = filePathParts{filePathLength};
        knownPath = ['/', filePathParts{2}];
        for i = 3:filePathLength
            nextFolder = fullfile(knownPath, filePathParts{i});
            if exist(nextFolder, 'file') ~= 0
                knownPath = nextFolder;
            end
        end
        %checks all subdirectories of the knownPath for the file
        newFile = dir(fullfile(knownPath, '**', append('*',sampleName)));
        newFolderPath = fullfile(newFile.folder, newFile.name);
    end
end