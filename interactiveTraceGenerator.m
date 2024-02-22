function interactiveTraceGenerator(folderPath)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

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

data.pressedNums = zeros(1,slmax); 
guidata(fig1,data)

set(fig1, 'KeyPressFcn', @(src, event) updatePlot(src, event, hsl, avg_intensity_survival, folderPath));

disp('finishing and saving')
figFilePath = fullfile(folderPath, 'interactiveFig');
savefig(figFilePath)
stepIDs = data.pressedNums;
stepIDFilePath = fullfile(folderPath, 'stepIDs.csv');
writematrix(stepIDs, stepIDFilePath)
close
end


function updatePlot(src, event, sliderHandle, datapoints, folderPath)

    %check if file path has changed
    folderPath = fileChecker(folderPath);

    % Get the key that was pressed
    keyPressed = event.Key;
    %check the current trace index
    sliderValue = round(get(sliderHandle, 'Value'));
               
    max = size(datapoints,2);
    %Initialize the array to track the step IDs
    data = guidata(src);

    % Check which key was pressed
    switch keyPressed
        case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
            data.pressedNums(1,sliderValue) = str2double(keyPressed);
            guidata(src,data)
            if sliderValue < max
                sliderHandle.Value = sliderValue+1;
                txt = num2str(data.pressedNums(1,sliderHandle.Value));
                plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, txt);
            end
        case {'a'}
            disp('a pressed')
        case 'leftarrow'
            if sliderValue > 1
                sliderHandle.Value = sliderValue-1;
                txt = num2str(data.pressedNums(1,sliderHandle.Value));
                plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, txt)
            end
        case 'rightarrow'
            if sliderValue < max
                sliderHandle.Value = sliderValue+1;
                txt = num2str(data.pressedNums(1,sliderHandle.Value));
                plotWithText(datapoints(:, sliderHandle.Value), sliderHandle.Value, txt);
            end
        case 'q'
            disp('closing and saving')
            figFilePath = fullfile(folderPath, 'interactiveFig');
            savefig(figFilePath)
            stepIDs = data.pressedNums;
            stepIDFilePath = fullfile(folderPath, 'stepIDs.csv');
            writematrix(stepIDs, stepIDFilePath)
            close
        otherwise
            disp('Unrecognized input')
    end
end

function plotWithText(yVals, traceNum, txt)
    plot(yVals)
    hold on;
    xL=xlim;
    yL=ylim;
    title(traceNum)
    % Set the position where you want to place the text
    text(0.99*xL(2),0.99*yL(2), txt, 'HorizontalAlignment','right',...
        'VerticalAlignment','top', 'FontSize', 40, 'Color', [1, 0, 0, 0])
    hold off
end