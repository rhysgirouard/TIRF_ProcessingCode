function [] = tracePlotterOirginalFig(tifFolderPath)
%tracePlotter plots and saves the traces from a given folderpath
%   tracePlotter checks that the given folder contains both a Track
%   statistics csv and a OriginalSatack.mat files then it plots the
%   intensity over time graphs for each identified spot and saves them to a
%   single figure called Figure1


nCrop = 400;
mCrop = 400;
nImage = 512;
mImage = 512;
NumberImages = 1500;

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
    savedFilePath = fullfile(tifFolderPath, 'OriginalStack.mat');
    
    % Load the variable from the file
    SavedStack = load(savedFilePath);
    
    % Access the variable from the loaded data structure
    OriginalStack = SavedStack.OriginalStack;
    
end



tracks_file = fullfile(tifFolderPath,'Track statistics.csv');
[tracks_data, tracks_result]= readtext(tracks_file, '[,\t]', '=', '[]', 'numeric-empty2zero');
[tracks_text_data, tracks_text_result]= readtext(tracks_file, '[,\t]', '=', '[]', 'textual');
tracks_firstrow = tracks_text_data(1,:);
track_x_location_index = find(ismember(tracks_firstrow,'TRACK_X_LOCATION'));
track_y_location_index = find(ismember(tracks_firstrow,'TRACK_Y_LOCATION'));
xy_coordinates(:,1) = tracks_data(2:end,track_x_location_index);
xy_coordinates(:,2) = tracks_data(2:end,track_y_location_index);
xy_coordinates = round(xy_coordinates);

% Define 5x5 roi centered at each particle coordinate
roi_size = 5 % in pixels *USER INPUT*
n_particle = size(xy_coordinates,1);
%  roi_x_edge = zeros(1,n_particle);
%  roi_y_edge = zeros(1,n_particle);
%  roi = zeros{1,n_particle};

% define edge of roi for each particle
for i=1:n_particle
        roi_x_edge(i) = xy_coordinates(i,1)-((roi_size-1)/2)+1; % pixel value start at 0 but matlab start at 1.
        roi_y_edge(i) = xy_coordinates(i,2)-((roi_size-1)/2)+1;
end

%
% acquire avg and max intensity of each particle in every frame
nCropLeft=nImage-nCrop+1;
for j=1:NumberImages
    for i=1:n_particle
        if roi_x_edge(i)>=nCropLeft && roi_x_edge(i)+roi_size-1<=nImage && roi_y_edge(i)>=1 && roi_y_edge(i)+roi_size-1<=mCrop
            roi{j,i} = OriginalStack(roi_y_edge(i):roi_y_edge(i)+roi_size-1,roi_x_edge(i):roi_x_edge(i)+roi_size-1,j);
            max_intensity(j,i) = max(max(roi{j,i})); % mean in colum direction and then row direction
            avr_intensity(j,i) = mean(mean(roi{j,i},1)); % mean in colum direction and then row direction
        else
            roi{j,i} = 0; %OriginalStack(roi_y_edge(i):roi_y_edge(i)+roi_size-1,roi_x_edge(i):roi_x_edge(i)+roi_size-1,j);
            avr_intensity(j,i) = 0;
            max_intensity(j,i) = 0;
        end 
    end
end

% remove roi that exceeds image dimension
survival_avg_traces = avr_intensity(1,:) > 0;
avg_intensity_survival = avr_intensity(:,survival_avg_traces);

survival_max_traces = max_intensity(1,:) > 0;
max_intensity_survival = max_intensity(:,survival_max_traces);

% take avr. intensity with moving wondow
w = 3; % moving window size **USER INPUT**
for k=1:NumberImages-w-1
    moving_avg_intensity(k,:) = mean(avg_intensity_survival(k:k+w-1,:));
end

for k=1:NumberImages-w-1
    moving_max_intensity(k,:) = mean(max_intensity_survival(k:k+w-1,:));
end

% plot each bleaching traces
% avg intensity
figure
plot(avg_intensity_survival(:,1));
writematrix(avg_intensity_survival,fullfile(tifFolderPath, 'AvgIntesnitySurvivalData.csv'))
slmin = 1;
slmax = size (avg_intensity_survival,2);
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                 'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                 'Position',[20 0 200 20]);
%  set(hsl,'Callback',@(hObject,eventdata) plot(moving_avr_intensity(:,round(get(hObject,'Value')))))
   set(hsl,'Callback',@(hObject,eventdata) plot(avg_intensity_survival(:,round(get(hObject,'Value')))))

savefig(append(tifFolderPath, "/Figure1.fig"))
close
delete(savedFilePath)

%
%avg moving window

figure

plot(moving_avg_intensity(:,1));
slmin = 1;
slmax = size (moving_avg_intensity,2);
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                 'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                 'Position',[20 0 200 20]);
%  set(hsl,'Callback',@(hObject,eventdata) plot(moving_avr_intensity(:,round(get(hObject,'Value')))))
   set(hsl,'Callback',@(hObject,eventdata) plot(moving_avg_intensity(:,round(get(hObject,'Value'))))) 
savefig(append(tifFolderPath, "/Figure2.fig"))
close


% plot intensity histogram
%{
f=figure
MaxInt=15000
Bin=100
MaxPrb=0.1
h = histogram(avg_intensity_survival(1,:), 'Normalization','probability','BinEdges',0:Bin:MaxInt);
axis([0 MaxInt 0 MaxPrb]);
xlabel('Intensity (a.u.)','FontSize',20)
ylabel('Probability','FontSize',20)
h.DisplayStyle='stairs'
h.LineWidth=2;

ax = gca;
ax.FontSize=20;
ax.XTick = -20:5000:MaxInt;
ax.YTick = 0:0.02:MaxPrb;
hold
saveas(f,fullfile(tifFolderPath, 'Intensity'),'jpg')
save(fullfile(tifFolderPath, 'results'))
%}
%%
function updatePlot(hObject, data)
    sliderValue = round(get(hObject, 'Value'));
    plot(data(:, sliderValue));
    title(append("Trace #", num2str(sliderValue)))
    maxIntesityOfThisPlot = max(data(:, sliderValue));
    if maxIntesityOfThisPlot > 1500 
        ylim([550 2000]);
    elseif maxIntesityOfThisPlot > 1000
        ylim([550 1500]);
    else
        ylim([550 1000]);
    end
end
end