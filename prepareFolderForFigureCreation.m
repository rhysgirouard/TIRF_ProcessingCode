function [traceData] = prepareFolderForFigureCreation(tifFolderPath, OriginalStack)
%prepareFolderForFigureCreation prepares a folder for figure generation
%   takes a folderpath to a folder that has been prepared with an
%   OriginalStack.mat and TrackStatistics.csv and generates the arrays
%   containing the data for all relevant traces for future figure
%   generation

    [mImage, nImage, NumberImages] = size(OriginalStack);


    tracks_file = fullfile(tifFolderPath,'Track statistics.csv');
    [tracks_data, ~]= readtext(tracks_file, '[,\t]', '=', '[]', 'numeric-empty2zero');
    [tracks_text_data, ~]= readtext(tracks_file, '[,\t]', '=', '[]', 'textual');
    tracks_firstrow = tracks_text_data(1,:);
    track_x_location_index = find(ismember(tracks_firstrow,'TRACK_X_LOCATION'));
    track_y_location_index = find(ismember(tracks_firstrow,'TRACK_Y_LOCATION'));
    xy_coordinates(:,1) = tracks_data(2:end,track_x_location_index);
    xy_coordinates(:,2) = tracks_data(2:end,track_y_location_index);
    xy_coordinates = round(xy_coordinates);
    
    quality_indices = ismember(tracks_firstrow, 'TRACK_MEAN_QUALITY');
    xy_coordinates(:,3) = tracks_data(2:end, quality_indices);
    
    % Define 5x5 roi centered at each particle coordinate
    roi_size = 5; % in pixels 
    n_particle = size(xy_coordinates,1);
    roi_left_edge = zeros(1,n_particle);
    roi_top_edge = zeros(1,n_particle);    
    % define edge of roi for each particle
    for spotNum=1:n_particle
        roi_left_edge(spotNum) = xy_coordinates(spotNum,1)-((roi_size-1)/2)+1; % pixel value start at 0 but matlab start at 1.
        roi_top_edge(spotNum) = xy_coordinates(spotNum,2)-((roi_size-1)/2)+1;
    end
    
    % acquire avg and max intensity of each particle in every frame
    % nCropLeft=nImage-nCrop+1;
    
    % intialize varaibles for the loop of the maximum possible size 
    rois = cell(n_particle, 1);
    max_intensity = zeros(NumberImages,n_particle);
    avg_intensity_survival = zeros(NumberImages,n_particle);
    spot_info = zeros(n_particle,4);
    spot_info(:,1) = 1:n_particle;
    filteredIndex = 1;

% filter out spots that are too close to the edge to get a full roi
    for spotNum=1:n_particle
            if roi_left_edge(spotNum)>=1 && roi_left_edge(spotNum)+roi_size-1<=nImage && roi_top_edge(spotNum)>=1 && roi_top_edge(spotNum)+roi_size-1<=mImage
                rois{filteredIndex,1} = OriginalStack(roi_top_edge(spotNum):roi_top_edge(spotNum)+roi_size-1,roi_left_edge(spotNum):roi_left_edge(spotNum)+roi_size-1,1:NumberImages);
                max_intensity(1:NumberImages, filteredIndex) = max(rois{filteredIndex},[],[1,2]); % max of each roi in each frame
                avg_intensity_survival(1:NumberImages, filteredIndex) = mean(rois{filteredIndex},[1,2]); % mean of each roi in each frame
                spot_info(filteredIndex,2:4) = xy_coordinates(spotNum,1:3);
                filteredIndex = filteredIndex + 1;
            end
    end
    
    % remove zeros from overallocation at initialization
    avg_intensity_survival = avg_intensity_survival(:,1:filteredIndex-1);
    spot_info = spot_info(1:filteredIndex-1,:);
    

    %sort by x-coord so that resulting figure is deterministic unless the
    %figure has previously been created.
    if ~isfile(fullfile(tifFolderPath,'interactiveFig.fig'))
        [~, sortedIndicies] = sort(spot_info(:,2));
        spot_info = spot_info(sortedIndicies,:);
        avg_intensity_survival = avg_intensity_survival(:,sortedIndicies);
    end

    % Save the trace data into a csv
    writematrix(avg_intensity_survival,fullfile(tifFolderPath, 'AvgIntesnitySurvivalData.csv'))
    writematrix(spot_info,fullfile(tifFolderPath, 'SpotInfoData.csv'))
    traceData = avg_intensity_survival;

end