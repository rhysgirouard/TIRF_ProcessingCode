function createInteractiveFigure(folderPath, currentFigure, maturationEfficiency)
%createInteractiveFigure generates an interactive figure for the folder
%   Takes in a folderpath and uses the AvgIntensity data generated
%   by tracePlotterOriginalFig to create a figure containg all the traces
%   from the folder tif that can be covieniently labeled and zoomed

csvFilePath = fullfile(folderPath,  'AvgIntesnitySurvivalData.csv');
avg_intensity_survival = readmatrix(csvFilePath);

spotInfoSaved = false;
[NumFrames, numTraces]  = size(avg_intensity_survival);
spot_info = zeros(numTraces,4);
if isfile(fullfile(folderPath, 'SpotInfoData.csv'))
    spotInfoSaved = true;
    spot_info = readmatrix(fullfile(folderPath, 'SpotInfoData.csv'));
end

set(0,'CurrentFigure',currentFigure)
plot(avg_intensity_survival(:,1));
slmin = 1;
NumberOfTraces = size (avg_intensity_survival,2);
slmax = NumberOfTraces;
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                 'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                 'Position',[20 0 200 20]);
%  set(hsl,'Callback',@(hObject,eventdata) plot(moving_avr_intensity(:,round(get(hObject,'Value')))))
   set(hsl,'Callback',@(hObject,eventdata) plot(avg_intensity_survival(:,round(get(hObject,'Value')))))

%check if the figure has previously been created or not  
if 0 == exist(fullfile(folderPath, 'interactiveFig.fig'), 'file')
    data.pressedNums = NaN(slmax,1);
else
    oldFig = openfig(fullfile(folderPath, 'interactiveFig.fig'), 'invisible');
    oldData = guidata(oldFig);
    % if the figure already exists check if it has the same number of spots
    if length(oldData.pressedNums) == NumberOfTraces
        data.pressedNums = oldData.pressedNums;
    else
        disp('New Data does not match old Data. Creating New File')
        savefig(oldFig, 'oldFig.fig')
    end
    %check if using the old version where stepIds are a wide row instead of a tall column
    if size(data.pressedNums, 1) < size(data.pressedNums, 2)
        data.pressedNums = transpose(data.pressedNums);
    end
    close(oldFig)
end

guidata(currentFigure,data)

set(currentFigure, 'KeyPressFcn', @(src, event) updatePlot(src, event, ...
    hsl, avg_intensity_survival, maturationEfficiency, spot_info));




NumberOfSteps = data.pressedNums;
stepIDFilePath = fullfile(folderPath, 'stepIDs.csv');
TraceNumber = (1:length(data.pressedNums)).';
stepIDTable = table(TraceNumber, NumberOfSteps);
writetable(stepIDTable, stepIDFilePath)
disp([extractAfter(folderPath,'Results/'), ' figure created'])
end


function updatePlot(src, event, sliderHandle, datapoints, maturationEfficiency, spot_info)
%updatePlot updates the figure(src) based on the  key pressed  

    %Read in the array to track the step IDs
    data = guidata(src);
    [folderPath, ~, ~] = fileparts(src.FileName);
    
    if nargin < 6
        [numFrames, numTraces]  = size(datapoints);
        spot_info = zeros(numTraces,4);
    end
    
    %spot_info = zeros(numTraces,4);

    % Get the key that was pressed
    keyPressed = event.Key;
    %check the current trace index
    sliderValue = round(get(sliderHandle, 'Value'));
               
    numberOfTraces = size(datapoints,2);
    numberOfFrames = size(datapoints,1);
    
    newLim = numberOfFrames;

    quitting = false;
    % Check which key was pressed
    switch keyPressed
        % IF a number is presssed record it and move to the next trace
        case {'0', '1', '2', '3', '4'}
            %additionally checks that a modifier key is not being pressed
            %such as command or shift; w/o this MATLAB reads command as 0
            if isempty(event.Modifier)
                data.pressedNums(sliderValue) = str2double(keyPressed);
                guidata(src,data)
                txt = num2str(data.pressedNums(sliderHandle.Value));
                info = spot_info(sliderHandle.Value,:);
                plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, info, txt, true);
                pause(0.20)
                if sliderValue < numberOfTraces
                    sliderHandle.Value = sliderValue+1;
                end
            end
        case { '5', '6', '7', '8', '9'}
            disp('Identification of Traces with more than 4 steps is not supported')
        % When you want to zoom in on the start of the graph use a, s, d, f
        % for the range 1:100, 1:200, 1:300, all respectively
        case {'a'}
            newLim = 100;
        case {'s'}
            newLim = 200;
        case {'d'}
            newLim = 300;
        case {'f'}
            newLim = size(datapoints,1);
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
        plotWithText(datapoints(1:newLim, sliderHandle.Value), sliderHandle.Value, info, txt, false);
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
    hold off
end