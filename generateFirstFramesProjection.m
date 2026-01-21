function [OutputFilePath] = generateFirstFramesProjection(folderPath, firstFrames)
%generateFirstFramesProjection generates a Z-projection for tracking
%   Sums the first 3 frames together to create a background "averaged" 
%   image for use in tracking. The image for tracking needs to have 
%   multiple frames because Trackmate is set up for motion tracking. 

OutputFileName = 'First3frames.tif';
OutputFilePath = fullfile( folderPath, OutputFileName );
projectionSize = size( firstFrames, 3 );

% Check for negative values from subtraction. 
minimumValue = min( firstFrames, [], "all" );
if minimumValue < 0
    firstFrames = firstFrames + -1 * minimumValue;
end
firstFrames = cast(firstFrames, 'uint16');


% Create a Z-projection(sum of intensities) of the first three frames to
%average out noise
ZProjection=firstFrames( :, :, 1 );
for i = 2 : projectionSize
    ZProjection = ZProjection + firstFrames( :, :, i );
end

% Create an image stack with 5 copies of the Zprojection for "motion
% tracking" in Trackmate
for i = 1 : 5
    imwrite( ZProjection, OutputFilePath, 'WriteMode', 'append',...
        'Compression', 'none' );
end
end