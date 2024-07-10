function [] = folderFigurePrepFxn(tifFolderPath)
%folderFigurePrepFxn prepares a folder for figure generation
%   takes a folderpath to a folder that has been prepared with an
%   OriginalStack.mat and TrackStatistics.csv and generates the arrays
%   containing the data for all relevant traces for future figure
%   generation

    nCrop = 400;
    mCrop = 400;
    nImage = 512;
    mImage = 512;
        
    %Check folder has all necessary contents:
    contents = dir(tifFolderPath);
    fileNames = {contents.name};
    
    if ~ismember(fileNames, 'Track statistics.csv')
        error('There is no Track statistics.csv file')
    end
    if ~ismember(fileNames, 'OriginalStack.mat')
        error('ERROR: No existing Stack file!')
    else
        % Specify the path to the saved .mat file
        OriginalStackPath = fullfile(tifFolderPath, 'OriginalStack.mat');
    
        % Load the data structure from the file
        SavedStack = load(OriginalStackPath);
    
        % Access the variable from the loaded data structure
        OriginalStack = SavedStack.OriginalStack;
    
    end
    
    NumberImages = size(OriginalStack,3);

    
    
    tracks_file = fullfile(tifFolderPath,'Track statistics.csv');
    [tracks_data, ~]= readtext(tracks_file, '[,\t]', '=', '[]', 'numeric-empty2zero');
    [tracks_text_data, ~]= readtext(tracks_file, '[,\t]', '=', '[]', 'textual');
    tracks_firstrow = tracks_text_data(1,:);
    track_x_location_index = find(ismember(tracks_firstrow,'TRACK_X_LOCATION'));
    track_y_location_index = find(ismember(tracks_firstrow,'TRACK_Y_LOCATION'));
    xy_coordinates(:,1) = tracks_data(2:end,track_x_location_index);
    xy_coordinates(:,2) = tracks_data(2:end,track_y_location_index);
    xy_coordinates = round(xy_coordinates);
    
    % Define 5x5 roi centered at each particle coordinate
    roi_size = 5; % in pixels 
    n_particle = size(xy_coordinates,1);
    roi_x_edge = zeros(1,n_particle);
    roi_y_edge = zeros(1,n_particle);
    roi = cell(NumberImages,n_particle);
    
    % define edge of roi for each particle
    for i=1:n_particle
        roi_x_edge(i) = xy_coordinates(i,1)-((roi_size-1)/2)+1; % pixel value start at 0 but matlab start at 1.
        roi_y_edge(i) = xy_coordinates(i,2)-((roi_size-1)/2)+1;
    end
    
    % acquire avg and max intensity of each particle in every frame
    nCropLeft=nImage-nCrop+1;
    for j=1:NumberImages
        for i=1:n_particle
            if roi_x_edge(i)>=nCropLeft && roi_x_edge(i)+roi_size-1<=nImage && roi_y_edge(i)>=1 && roi_y_edge(i)+roi_size-1<=mCrop
                roi{j,i} = OriginalStack(roi_y_edge(i):roi_y_edge(i)+roi_size-1,roi_x_edge(i):roi_x_edge(i)+roi_size-1,j);
                max_intensity(j,i) = max(max(roi{j,i})); % mean in colum direction and then row direction
                avr_intensity(j,i) = mean(mean(roi{j,i},1)); % mean in colum direction and then row direction
            else
                roi{j,i} = 0; 
                avr_intensity(j,i) = 0;
                max_intensity(j,i) = 0;
            end
        end
    end
    
    % remove roi that exceeds image dimension
    survival_avg_traces = avr_intensity(1,:) > 0;
    avg_intensity_survival = avr_intensity(:,survival_avg_traces);
    
    % survival_max_traces = max_intensity(1,:) > 0;
    % max_intensity_survival = max_intensity(:,survival_max_traces);
    % 
    % % take avr. intensity with moving wondow
    % w = 3; % moving window size **USER INPUT**
    % for k=1:NumberImages-w-1
    %     moving_avg_intensity(k,:) = mean(avg_intensity_survival(k:k+w-1,:));
    % end
    % 
    % for k=1:NumberImages-w-1
    %     moving_max_intensity(k,:) = mean(max_intensity_survival(k:k+w-1,:));
    % end

    % Save the trace data into a csv
    writematrix(avg_intensity_survival,fullfile(tifFolderPath, 'AvgIntesnitySurvivalData.csv'))
    delete(OriginalStackPath)

end