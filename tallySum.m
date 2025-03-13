function tallySum(sampleFolderPath, maturationEfficiency)
%tallySum takes all the generated step IDs and counts the occurences
%   Detailed explanation goes here

% List all contents of the supplied folder
contents = dir(sampleFolderPath);

% Filter out only the subfolders
subfolderNames = {contents([contents.isdir] & ~ismember({contents.name}, {'.', '..'})).name};

%intialize the distribution and total
distributionOfCounts = zeros(1,10);
totalTraces = 0;

% Loop through each subfolder and pass its file path to the external function
for i = 1:numel(subfolderNames)
    subfolderPath = fullfile(sampleFolderPath, subfolderNames(i));
    figFilePath = fullfile(subfolderPath, "interactiveFig.fig");
    figFilePathChar = convertStringsToChars(figFilePath);
    if exist(figFilePathChar, 'file') == 2
        currentFig = openfig(figFilePathChar, 'invisible');
        data = guidata(currentFig);
        distributionOfCounts = distributionOfCounts + histcounts(data.pressedNums, 0:10);
        totalTraces = totalTraces + length(data.pressedNums);
        close(currentFig)
    end
end
columnTitles = [{'Uncounted'}, {'One Step'}, {'Two Steps'},...
    {'Three Steps'}, {'Four Steps'}, {'Five Steps'}, {'Six Steps'},...
    {'Seven Steps'}, {'Eight Steps'}, {'Nine Steps'} ];
totalCounted = sum(distributionOfCounts(2:end));
fractions = distributionOfCounts(2:end)/totalCounted;
totalRow = [{'Total'}, num2cell(totalCounted), '% Counted', ...
    num2cell( totalCounted / sum(distributionOfCounts) * 100 ), num2cell(NaN(1,6))];
sumAsCell = num2cell(distributionOfCounts);
fractionsAsCell = [{'Fraction'}, num2cell(fractions)];
emptyRow = num2cell(NaN(1,10));
distributionTitles = [NaN, {'Monomers'}, {'Dimers'}, {'Trimers'},...
    {'Tetramers'}, {'Pentamers'}, {'Hexamers'}, {'Heptamers'},...
    {'Octamers'}, {'Nonamers'}];
[oligomericDistribtution, ~] = oligomer_distribution_calculation_Fxn(fractions( 1 : ( end - 1 ) ), maturationEfficiency);
oligomericDistribtution = [{'Fractions'}, num2cell(transpose(oligomericDistribtution))];
result = [columnTitles; sumAsCell; totalRow; fractionsAsCell; emptyRow; distributionTitles; oligomericDistribtution];
writecell(result,fullfile(sampleFolderPath, 'sumOfCounts.xlsx'))
disp(['Total Counted: ', num2str(totalCounted)])
disp(['Uncounted: ', num2str(distributionOfCounts(1))])
disp(['Unseen: ', num2str(totalTraces - distributionOfCounts(1) - totalCounted)])
end