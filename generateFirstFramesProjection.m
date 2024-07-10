function [nImage, NumberImages, OriginalStack] = generateFirstFramesProjection(tifFilePath)
%generateFirstFramesProjection preloads the image and generates a Z-projection for tracking
%   Loads in the image as a 3D uint16 array for future use and then sums
%   the first 3 frames together to create a background "averaged" image for
%   use in tracking. The image for tracking needs to have multiple frames
%   because Trackmate is set up for motion tracking. 

OutputFileName = 'First3frames.tif';
[path,~,~] = fileparts(tifFilePath);
OutputFile = fullfile(path,OutputFileName);
NoProjection = 3;

% Load image
InfoImage=imfinfo(tifFilePath);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
OriginalStack=zeros(nImage,mImage,NumberImages,'uint16');

% copy image stack into a 3D array
for i=1:NumberImages
   OriginalStack(:,:,i)=imread(tifFilePath,'Index',i,'Info',InfoImage);
end

% Create a Z-projection(sum of intensities) of the first three frames to
%average out noise
ZProjection=OriginalStack(:,:,1);
for i=2:NoProjection
    ZProjection=ZProjection+OriginalStack(:,:,i);
end

% Create an image stack with 5 copies of the Zprojection for "motion
% tracking" in Trackmate
for i=1:5
    imwrite(ZProjection,OutputFile,'WriteMode','append','Compression','none');
end
end