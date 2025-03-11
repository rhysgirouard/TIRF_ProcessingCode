function [OutputFilePath] = generateFirstFramesProjection(folderPath, OriginalStack)
%generateFirstFramesProjection preloads the image and generates a Z-projection for tracking
%   Loads in the image as a 3D uint16 array for future use and then sums
%   the first 3 frames together to create a background "averaged" image for
%   use in tracking. The image for tracking needs to have multiple frames
%   because Trackmate is set up for motion tracking. 

OutputFileName = 'First3frames.tif';
OutputFilePath = fullfile(folderPath,OutputFileName);
NoProjection = 3;
minimumValue = min(OriginalStack,[],"all");
if minimumValue < 0
    OriginalStack = OriginalStack + -1*minimumValue;
end
OriginalStack = cast(OriginalStack, 'uint16');


% Create a Z-projection(sum of intensities) of the first three frames to
%average out noise
ZProjection=OriginalStack(:,:,1);
for i=2:NoProjection
    ZProjection=ZProjection+OriginalStack(:,:,i);
end

% Create an image stack with 5 copies of the Zprojection for "motion
% tracking" in Trackmate
for i=1:5
    imwrite(ZProjection,OutputFilePath,'WriteMode','append','Compression','none');
end
end