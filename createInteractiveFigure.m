function createInteractiveFigure(folderPath, currentFigure, maturationEfficiency, subtractedTraceData)
%createInteractiveFigure generates an interactive figure for the folder
%   Takes in a folderpath and uses the trace data generated
%   by prepareFolderForFigureCreation to create a figure containg all the traces
%   from the folder tif that can be covieniently labeled and zoomed

spotInfoSaved = false;
[NumFrames, numTraces]  = size(subtractedTraceData);
spot_info = zeros(numTraces,4);
if isfile(fullfile(folderPath, 'SpotInfoData.csv'))
    spotInfoSaved = true;
    spot_info = readmatrix(fullfile(folderPath, 'SpotInfoData.csv'));
end

set(0,'CurrentFigure',currentFigure)
plot(subtractedTraceData(:,1));
slmin = 1;
NumberOfTraces = size (subtractedTraceData,2);
slmax = NumberOfTraces;
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                 'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                 'Position',[20 0 200 20]);
%  set(hsl,'Callback',@(hObject,eventdata) plot(moving_avr_intensity(:,round(get(hObject,'Value')))))
   set(hsl,'Callback',@(hObject,eventdata) plot(subtractedTraceData(:,round(get(hObject,'Value')))))
%check if the figure has previously been created or not  
if 0 == exist(fullfile(folderPath, 'interactiveFig.fig'), 'file')
    data.pressedNums = NaN(NumberOfTraces,1);
else
    oldFig = openfig(fullfile(folderPath, 'interactiveFig.fig'), 'invisible');
    oldData = guidata(oldFig);
    % if the figure already exists check if it has the same number of spots
    if length(oldData.pressedNums) == NumberOfTraces
        data.pressedNums = oldData.pressedNums;
    %check if using the old version where stepIds are a wide row instead of a tall column
    elseif size(oldData.pressedNums, 1) < size(oldData.pressedNums, 2)

        data.pressedNums = transpose(oldData.pressedNums);
    else
        disp('New Data does not match old Data. Creating New File')
        savefig(oldFig, 'oldFig.fig')
        data.pressedNums = NaN(NumberOfTraces,1);
    end
end

guidata(currentFigure,data)

set(currentFigure, 'KeyPressFcn', @(src, event) updatePlot(src, event, ...
    hsl, subtractedTraceData, maturationEfficiency, spot_info));




NumberOfSteps = data.pressedNums;
stepIDFilePath = fullfile(folderPath, 'stepIDs.csv');
TraceNumber = (1:length(data.pressedNums)).';
stepIDTable = table(TraceNumber, NumberOfSteps);
writetable(stepIDTable, stepIDFilePath)
disp([extractAfter(folderPath,'Results/'), ' figure created'])
end


function updatePlot(src, event, sliderHandle, rawData, maturationEfficiency, spot_info)
%updatePlot updates the figure(src) based on the  key pressed  

%Read in the array to track the step IDs
    data = guidata(src);
    [folderPath, ~, ~] = fileparts(src.FileName);
    
    if nargin < 6
        if isfield(data, 'info')
            spot_info = data.info;
        elseif isfile(fullfile(folderPath,'SpotInfoData.csv'))
            spot_info = readmatrix(fullfile(folderPath,'SpotInfoData.csv'));
            data.info = spot_info;
            guidata(src, data)
        elseif isfile(fullfile(folderPath, 'Track statistics.csv'))
            pathParts = split(folderPath,'/');
            subFolderName = pathParts{length(pathParts)};
            imagePath = fullfile(folderPath, [subFolderName, '.tif']);

            InfoImage=imfinfo(imagePath);
            mImage=InfoImage(1).Width;
            nImage=InfoImage(1).Height;
            NumberImages=length(InfoImage);
            OriginalStack=zeros(nImage,mImage,NumberImages,'uint16');

            % copy image stack into a 3D array
            for i=1:NumberImages
                OriginalStack(:,:,i)=imread(imagePath,'Index',i,'Info',InfoImage);
            end
            prepareFolderForFigureCreation(folderPath,OriginalStack)
            spot_info = readmatrix(fullfile(folderPath,'SpotInfoData.csv'));
            data.info = spot_info;
            guidata(src, data)
        else
        [numFrames, numTraces]  = size(rawData);
        spot_info = zeros(numTraces,4);
        end
    end
    
    %spot_info = zeros(numTraces,4);

    % Get the key that was pressed
    keyPressed = event.Key;
    %check the current trace index
    sliderValue = round(get(sliderHandle, 'Value'));
               
    numberOfTraces = size(rawData,2);
    numberOfFrames = size(rawData,1);
    
    newLim = numberOfFrames;

    quitting = false;
    % Check which key was pressed
    switch keyPressed
        % IF a number is presssed record it and move to the next trace
        case {'0', '1', '2', '3', '4',  '5', '6', '7', '8', '9'}
            %additionally checks that a modifier key is not being pressed
            %such as command or shift; w/o this MATLAB reads command as 0
            if isempty(event.Modifier)
                data.pressedNums(sliderValue) = str2double(keyPressed);
                guidata(src,data)
                txt = num2str(data.pressedNums(sliderHandle.Value));
                info = spot_info(sliderHandle.Value,:);
                plotWithText(rawData(:, sliderHandle.Value), sliderHandle.Value, info, txt, true);
                pause(0.20)
                if sliderValue < numberOfTraces
                    sliderHandle.Value = sliderValue+1;
                end
            end
        % When you want to zoom in on the start of the graph use a, s, d, f
        % for the range 1:100, 1:200, 1:300, all respectively
        case {'a'}
            newLim = 100;
        case {'s'}
            newLim = 200;
        case {'d'}
            newLim = 300;
        case {'f'}
            newLim = size(rawData,1);
        %Use the arrowkeys to move b/w graphs without updating the steps
        case 'leftarrow'
            if isnan(data.pressedNums(sliderValue)) 
                data.pressedNums(sliderValue) = 0;
            end
            if sliderValue > 1
                sliderHandle.Value = sliderValue-1;
            end
        case 'rightarrow'
            if isnan(data.pressedNums(sliderValue)) 
                data.pressedNums(sliderValue) = 0;
            end
            if sliderValue < numberOfTraces
                sliderHandle.Value = sliderValue+1;
            end
            % use the up and down arrows to zoom dynamically. Zoom is
            % 'circular' so zoom out at full view goes to minimum zoom
        case {'uparrow', 'downarrow'}
            currentXlimits = xlim;
            xMax = currentXlimits(2);
            if strcmp(keyPressed, 'uparrow')
                newLim = mod((xMax + 99), numberOfFrames)+1;
            elseif strcmp(keyPressed, 'downarrow')
                newLim = mod((xMax - 101), numberOfFrames)+1;
            end
            
        %Press q to save the data and close the figure
        case 'q'
            quitting = true;
        otherwise
            disp('Unrecognized input')
    end

    if isempty(event.Modifier)
        txt = num2str(data.pressedNums(sliderHandle.Value));
        info = spot_info(sliderHandle.Value, :);
        plotWithText(rawData(1:newLim, sliderHandle.Value), sliderHandle.Value, info, txt, false);
        guidata(src,data)
    end

    if quitting
        disp('closing and saving')
        % set the CreateFcn to an 
        
        savefig(src.FileName)
        % saves a csv of the step identification(this csv is vestigial)
        stepIDFilePath = fullfile(folderPath, 'stepIDs.csv');
        TraceNumbers = transpose((1:length(data.pressedNums)));
        NumberOfSteps = data.pressedNums;
        stepIDTable = table(TraceNumbers, NumberOfSteps);
        writetable(stepIDTable, stepIDFilePath)
        [superfolder, ~, ~] = fileparts(folderPath);
        tallySum(superfolder, maturationEfficiency)
        close
    end
end

function plotWithText(yVals, traceNum, info, txt, withOverlay)
%plotWithText plots a figure with the txt displayed in the top right and
%the Trace # above the graph. When withOverlay is true text is displayed on
%top of the figure instead of the top right
    plot(yVals)
    xlim([1 length(yVals)])
    hold on;
    xL=xlim;
    yL=ylim;
    if info(4) == 0
        title(['Trace #', num2str(traceNum)])
    else
        title({['Trace #', num2str(traceNum), ' | Quality: ', num2str(info(4))];...
        ['x: ', num2str(info(2)), ' y: ', num2str(info(3))]})
    end
    if strcmp(txt,'NaN') || strcmp(txt,'0')
        txt = 'Uncounted';
    end
    % Set the position where you want to place the text
    if withOverlay
        text(0.5*(xL(1)+xL(2)),0.5*(yL(1)+yL(2)), ['Steps:', txt], 'HorizontalAlignment','center',...
        'VerticalAlignment','middle', 'FontSize', 100, 'Color', [1, 0, 0, 0])
    else
        text(0.99*xL(2),0.99*yL(2), ['Steps:', txt], 'HorizontalAlignment','right',...
            'VerticalAlignment','top', 'FontSize', 30, 'Color', [1, 0, 0, 0])
    end
    xlabel('Frame')
    ylabel('Spot Intensity')
    hold off
end