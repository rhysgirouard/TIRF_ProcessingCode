function newFolderPath = fileChecker(oldFolderPath)
newFolderPath = oldFolderPath;
%check if the figure's filepath has changed
    if exist(oldFolderPath, 'file') == 0
        filePathParts = split(oldFolderPath,'/');
        filePathLength = size(filePathParts,1);
        sampleName = filePathParts{filePathLength};
        knownPath = ['/', filePathParts{2}];
        for i = 3:filePathLength
            nextFolder = fullfile(knownPath, filePathParts{i});
            if exist(nextFolder, 'file') ~= 0
                knownPath = nextFolder;
            end
        end
        newFile = dir([knownPath, '/**/*', sampleName]);
        newFolderPath = fullfile(newFile.folder, newFile.name);
    end
end