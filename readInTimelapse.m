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
background = imgaussfilt(summedStack,50)./1500;
correctedStack = cast(importedStack, "double") - cast(background, "double");


end