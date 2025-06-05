function [nImage, NumberImages, correctedStack] = readInTimelapse(tifFilePath)
%readInTimelapse  Loads in the image as a 3D uint16 array for future use 

% Load image
InfoImage = imfinfo(tifFilePath);
mImage = InfoImage(1).Width;
nImage = InfoImage(1).Height;
NumberImages = length(InfoImage);
importedStack = zeros(nImage, mImage, NumberImages, 'uint16');
summedStack = zeros(nImage, mImage);

% copy image stack into a 3D array
for i = 1:NumberImages
   currentFrame = imread(tifFilePath, 'Index', i, 'Info', InfoImage);
   importedStack(:,:,i) = currentFrame;
   summedStack = summedStack + cast(currentFrame, 'double');
end

%TODO: if I can do this without imgaussfilt function then people dont have
%to add the Image processing toolbox to run the app. 
background = imgaussfilt(summedStack,50)./NumberImages;
correctedStack = cast(importedStack, "double") - cast(background, "double");


end