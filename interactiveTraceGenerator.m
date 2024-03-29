function interactiveTraceGenerator(folderPath)
%interactiveTraceGenerator generates an interactive figure for the folder
%   takes in a folderpath and uses the AvgIntensity data generated
%   by tracePlotterOriginalFig to create a figure containg all the traces
%   from the folder tif that can be covieniently labeled and zoomed

csvFilePath = fullfile(folderPath,  'AvgIntesnitySurvivalData.csv');

avg_intensity_survival = readmatrix(csvFilePath);
fig1 = figure;
plot(avg_intensity_survival(:,1));
slmin = 1;
slmax = size (avg_intensity_survival,2);
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                 'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                 'Position',[20 0 200 20]);
%  set(hsl,'Callback',@(hObject,eventdata) plot(moving_avr_intensity(:,round(get(hObject,'Value')))))
   set(hsl,'Callback',@(hObject,eventdata) plot(avg_intensity_survival(:,round(get(hObject,'Value')))))

%check if the figure has previously been created or not  
if exist(fullfile(folderPath, 'interactiveFig.fig'), 'file') == 0
    data.pressedNums = zeros(slmax,1);
else
    oldFig = openfig(fullfile(folderPath, 'interactiveFig.fig'), 'invisible');
    oldData = guidata(oldFig);
    data.pressedNums = oldData.pressedNums;
    %check if using the old version where stepIds are a wide row instead of a tall column
    if size(data.pressedNums, 1) < size(data.pressedNums, 2)
        data.pressedNums = transpose(data.pressedNums);
    end
    close(oldFig)
end

guidata(fig1,data)

set(fig1, 'KeyPressFcn', @(src, event) updatePlot(src, event, hsl, avg_intensity_survival));

disp('finishing and saving')
figFilePath = fullfile(folderPath, 'interactiveFig');
savefig(figFilePath)

NumberOfSteps = data.pressedNums;
stepIDFilePath = fullfile(folderPath, 'stepIDs.csv');
TraceNumber = (1:length(data.pressedNums)).';
stepIDTable = table(TraceNumber, NumberOfSteps);
writetable(stepIDTable, stepIDFilePath)

close
end


function updatePlot(src, event, sliderHandle, datapoints)

    %Read in the array to track the step IDs
    data = guidata(src);
    [folderPath, ~, ~] = fileparts(src.FileName);

    % Get the key that was pressed
    keyPressed = event.Key;
    %check the current trace index
    sliderValue = round(get(sliderHandle, 'Value'));
               
    max = size(datapoints,2);
    
    quitting = false;
    % Check which key was pressed
    switch keyPressed
        % IF a number is presssed record it and move to the next trace
        case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
            %additionally checks that a modifier key is not being pressed
            %such as command or shift; w/o this MATLAB reads command as 0
            if isempty(event.Modifier)
                data.pressedNums(sliderValue) = str2double(keyPressed);
                guidata(src,data)
                if sliderValue < max
                    sliderHandle.Value = sliderValue+1;
                end
                txt = num2str(data.pressedNums(sliderHandle.Value));
                plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, txt);
            end
        % When you want to zoom in on the start of the graph use a, s, d, f
        % for the range 1:100, 1:200, 1:300, all respectively
        case {'a'}
            txt = num2str(data.pressedNums(sliderHandle.Value));
            plotWithText(datapoints(1:100, sliderHandle.Value), sliderHandle.Value, txt);
        case {'s'}
            txt = num2str(data.pressedNums(sliderHandle.Value));
            plotWithText(datapoints(1:200, sliderHandle.Value), sliderHandle.Value, txt);
        case {'d'}
            txt = num2str(data.pressedNums(sliderHandle.Value));
            plotWithText(datapoints(1:300, sliderHandle.Value), sliderHandle.Value, txt);
        case {'f'}
            txt = num2str(data.pressedNums(sliderHandle.Value));
            plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, txt);
        %Use the arrowkeys to move b/w graphs without updating the steps
        case 'leftarrow'
            if sliderValue > 1
                sliderHandle.Value = sliderValue-1;
                txt = num2str(data.pressedNums(sliderHandle.Value));
                plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, txt)
            end
        case 'rightarrow'
            if sliderValue < max
                sliderHandle.Value = sliderValue+1;
                txt = num2str(data.pressedNums(sliderHandle.Value));
                plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, txt);
            end
        %Press q to save the data and close the figure
        case 'q'
            disp('closing and saving')
            savefig(src.FileName)
            stepIDFilePath = fullfile(folderPath, 'stepIDs.csv');
            TraceNumbers = transpose((1:length(data.pressedNums)));
            NumberOfSteps = data.pressedNums;
            stepIDTable = table(TraceNumbers, NumberOfSteps);
            writetable(stepIDTable, stepIDFilePath)
            [superfolder, ~, ~] = fileparts(folderPath);
            tallySum(superfolder)
            guidata(src,data)
            quitting = true;
            close
        otherwise
            disp('Unrecognized input')
    end
    if ~quitting
        guidata(src,data)
    end
end

function plotWithText(yVals, traceNum, txt)
%plotWithText plots a figure with the txt displayed in the top right and
%the Trace # above the graph.
    plot(yVals)
    hold on;
    xL=xlim;
    yL=ylim;
    title(['Trace #', num2str(traceNum)])
    % Set the position where you want to place the text
    text(0.99*xL(2),0.99*yL(2), ['Steps:', txt], 'HorizontalAlignment','right',...
        'VerticalAlignment','top', 'FontSize', 30, 'Color', [1, 0, 0, 0])
    hold off
end