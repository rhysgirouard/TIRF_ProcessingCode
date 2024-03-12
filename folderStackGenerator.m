function [] = folderStackGenerator(superfolderPath)
%UNTITLED reprocesses a folder to restore the presence of
%OriginalStacks.mat files
%   Detailed explanation goes here
    % Filter out only the subfolders
    % List all contents of the supplied folder
contents = dir(superfolderPath);
subfolderNames = {contents([contents.isdir] & ~ismember({contents.name}, {'.', '..'})).name};

% Convert to string array
subfolderNames = string(subfolderNames);

% Display the list of subfolder names
disp('Subfolders in the current directory:');
disp(subfolderNames);

% Loop through each subfolder and pass its file path to the external function
for i = 1:numel(subfolderNames)
    subfolderPath = fullfile(superfolderPath, subfolderNames(i));
    imagepath = append(subfolderPath, '/', subfolderNames(i), '.tif');
    subfolderPathChar = convertStringsToChars(subfolderPath);
    stackGenerator(subfolderPathChar,imagepath)
end

end


function [] = stackGenerator(subfolderPath,imagePath)
%stackGenerator creates an OriginalStack.mat file in the given subfolder

InfoImage=imfinfo(imagePath);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
OriginalStack=zeros(nImage,mImage,NumberImages,'uint16');
for i=1:NumberImages
   OriginalStack(:,:,i)=imread(imagePath,'Index',i,'Info',InfoImage);
end

save(fullfile(subfolderPath, 'OriginalStack.mat'), 'OriginalStack')
end
