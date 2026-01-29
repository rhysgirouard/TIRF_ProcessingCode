function [spot_info] = identifyOverlapSpots(spot_info, ZProjection, innerWindowSize, outerWindowSize, brightnessThreshold, distanceThreshold)
%identifyOverlapSpots identifies doubled or overlapping spots
%   Looks at the image to see if TrackMate has chosen spots that are either
%   too close to each other or large enough that they are likely two
%   nearby spots. Spots are determined to be too large if the 
%   brightness of pixels outside the innerWindow exceed a given threshold. 
%   brightnessThreshold and distanceThreshold work best with our images at 
%   0.328 and 4.5 respectively. window sizes are chosen to fit average spot
%   size

xy_coordinates = spot_info(:,2:3);
xy_coordinates_integer = round(xy_coordinates);
numPoints = length(xy_coordinates);

% Compute pairwise distances 
distances = inf(numPoints);
distancefun = @(a, b) sqrt( ( a(1) - b(1) )^2 + ( a(2) - b(2) )^2 );

for index1 = 1:numPoints
    for index2 = index1:numPoints
        distances(index1,index2) = distancefun(xy_coordinates(index1,:), xy_coordinates(index2,:));
        distances(index2,index1) = distances(index1,index2);
    end
end

% Set diagonal to Inf to ignore zero distance to self
distances(1:size(distances,1)+1:end) = Inf;

% Find the minimum distance for each point
nearest_distances = min(distances, [], 2);

% Import image and adjust contrast (must be 0 to 1 for other code to function
% properly also helps if you want to visualize with imshow()
ZProjection = cast(ZProjection, 'double');
minVal = min(ZProjection, [], "all");
maxVal = max(ZProjection, [], "all");
adjustedImage = (ZProjection-minVal)./(maxVal-minVal);

% in order to remove dependence on Image Processing toolbox while
% maintining consistent parameters imadjust must be manually replicated
nbins = 2^16;
[imageHistN, ~] = histcounts(adjustedImage, nbins);
cdf = cumsum(imageHistN)/sum(imageHistN);
ilow = (find(cdf > 0.01, 1, 'first') - 1)/(nbins - 1);
ihigh = (find(cdf >= 0.99, 1, 'first') - 1)/(nbins - 1);
adjustedImage(:) =  max(ilow, min(ihigh,adjustedImage));
autoImage = (adjustedImage - ilow) ./ (ihigh - ilow);

% Mask all spots so that they don't contribute to measurements of nearby
% brightness
maskedImage = autoImage;
halfInnerWindow = (innerWindowSize - 1) / 2;
[rows, cols] = size(ZProjection);

 for i = 1:numPoints
    x = xy_coordinates_integer(i,1); % column
    y = xy_coordinates_integer(i,2); % row

    % Define inner window bounds
    xStart = max(x - halfInnerWindow + 1, 1);
    xEnd   = min(x + halfInnerWindow, cols);
    yStart = max(y - halfInnerWindow + 1, 1);
    yEnd   = min(y + halfInnerWindow, rows);
    % Set intensities to 0 to mask spot
    maskedImage(yStart:yEnd, xStart:xEnd) = 0;

 end

 % Measure the average brightness of pixels surrounding each spot. this
 % must be done in a separate loop so that all spots can be masked so that
 % they will not contribute to nearby brightness
 regionSize = (outerWindowSize)^2 - (innerWindowSize)^2;
 nearbyBrightness = zeros(numPoints, 1);
 halfOuterWindow = (outerWindowSize - 1) / 2;
 for i = 1:numPoints
    x = xy_coordinates_integer(i,1); % column
    y = xy_coordinates_integer(i,2); % row

    % Define outer window bounds
    xStart = max(x - halfOuterWindow + 1, 1);
    xEnd   = min(x + halfOuterWindow, cols);
    yStart = max(y - halfOuterWindow + 1, 1);
    yEnd   = min(y + halfOuterWindow, rows);

    % Extract the outer region
    region = maskedImage(yStart:yEnd, xStart:xEnd);

    % Calculate average intensity
    nearbyBrightness(i) = sum(region(:))/(regionSize);
end

exclusionTags = zeros(numPoints,1);
% 0 indicates a spot has not been flagged
% 1 indicates a spot is too close to another nearby spot
% 2 indicates a spot is too large
% 3 indicates both
exclusionTags(nearest_distances < distanceThreshold) = exclusionTags(nearest_distances < distanceThreshold) + 1;
exclusionTags(nearbyBrightness > brightnessThreshold) = exclusionTags(nearbyBrightness > brightnessThreshold) + 2;

spot_info(:,5) = exclusionTags;

end