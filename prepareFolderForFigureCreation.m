function [spot_info] = prepareFolderForFigureCreation(tracks_struct, OriginalStack)
%prepareFolderForFigureCreation prepares a folder for figure generation
%   takes a folderpath to a folder that has been prepared with an
%   OriginalStack.mat and TrackStatistics.csv and generates the arrays
%   containing the data for all relevant traces for future figure
%   generation

    [mImage, nImage, NumberImages] = size(OriginalStack);
    
    numberOfSpots = size( [ tracks_struct.Model.AllTracks.Track.TRACK_X_LOCATIONAttribute ], 2 );
    xy_coordinates = NaN( numberOfSpots, 3 );
    xy_coordinates(:,1) = [tracks_struct.Model.AllTracks.Track.TRACK_X_LOCATIONAttribute];
    xy_coordinates(:,2) = [tracks_struct.Model.AllTracks.Track.TRACK_Y_LOCATIONAttribute];
    xy_coordinates(:,3) = [tracks_struct.Model.AllTracks.Track.TRACK_MEAN_QUALITYAttribute];


    xy_coordinates_integer = round(xy_coordinates);
    
    % Define 5x5 roi centered at each particle coordinate
    roi_size = 5; % in pixels 
    n_particle = size(xy_coordinates_integer,1);
    roi_left_edge = zeros(1,n_particle);
    roi_top_edge = zeros(1,n_particle);    
    % define edge of roi for each particle
    for spotNum=1:n_particle
        roi_left_edge(spotNum) = xy_coordinates_integer(spotNum,1)-((roi_size-1)/2)+1; % pixel value start at 0 but matlab start at 1.
        roi_top_edge(spotNum) = xy_coordinates_integer(spotNum,2)-((roi_size-1)/2)+1;
    end
    
    % acquire avg and max intensity of each particle in every frame
    % nCropLeft=nImage-nCrop+1;
    
    % intialize varaibles for the loop of the maximum possible size 
    rois = cell(n_particle, 1);
    max_intensity = zeros(NumberImages,n_particle);
    traceData = zeros(NumberImages,n_particle);
    tableSize = [n_particle,7];
    variableNames = ["Trace_Number", "Trackmate_Number", "X-coordinate",...
        "Y-coordinate", "Trackmate_quality", "Flag", "Trace_Data"];
    variableTypes = ["double", "double", "double", "double", "double", "double", "cell"];
    spot_info = table('Size', tableSize,'VariableTypes', variableTypes, 'VariableNames', variableNames);
    spot_info.Trackmate_Number = transpose(1:n_particle);
    filteredIndex = 1;

% filter out spots that are too close to the edge to get a full roi
    for spotNum=1:n_particle
            if roi_left_edge(spotNum)>=1 && roi_left_edge(spotNum)+roi_size-1<=nImage && roi_top_edge(spotNum)>=1 && roi_top_edge(spotNum)+roi_size-1<=mImage
                rois{filteredIndex,1} = OriginalStack(roi_top_edge(spotNum):roi_top_edge(spotNum)+roi_size-1,roi_left_edge(spotNum):roi_left_edge(spotNum)+roi_size-1,1:NumberImages);
                max_intensity(1:NumberImages, filteredIndex) = max(rois{filteredIndex},[],[1,2]); % max of each roi in each frame
                spot_info.Trace_Data{filteredIndex} = mean(rois{filteredIndex},[1,2]); % mean of each roi in each frame
                spot_info.Trackmate_quality(filteredIndex) = xy_coordinates(spotNum, 3);
                spot_info.('X-coordinate')(filteredIndex) = xy_coordinates(spotNum, 1);
                spot_info.('Y-coordinate')(filteredIndex) = xy_coordinates(spotNum, 2);
                filteredIndex = filteredIndex + 1;
            end
    end
    
    % remove zeros from overallocation at initialization
    spot_info = spot_info(1:filteredIndex-1,:);
    

    %sort by x-coord so that resulting figure is deterministic unless the
    %figure has previously been created.
    [~, sortedIndicies] = sort(spot_info.("X-coordinate"));

    spot_info = spot_info(sortedIndicies,:);
    spot_info.Trace_Number = transpose(1:filteredIndex-1);
end