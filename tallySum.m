function tallySum(sampleFolderPath)
%tallySum takes all the generated step IDs and counts the occurences
%   Detailed explanation goes here

% List all contents of the supplied folder
    contents = dir(sampleFolderPath);

    % Filter out only the subfolders
    subfolderNames = {contents([contents.isdir] & ~ismember({contents.name}, {'.', '..'})).name};
    
    %intialize final sum
    sum = zeros(1,10);

    % Loop through each subfolder and pass its file path to the external function
    for i = 1:numel(subfolderNames)
        subfolderPath = fullfile(sampleFolderPath, subfolderNames(i));
        csvFilePath = fullfile(subfolderPath, "stepIDs.csv");
        csvFilePathChar = convertStringsToChars(csvFilePath);
        sum = sum + csvTallyFxn(csvFilePathChar);
    end
    columnTitles = [{'Uncounted'}, {'One Step'}, {'Two Steps'}, {'Three Steps'}, {'Four Steps'}, {'Five Steps'}, {'Six Steps'}, {'Seven Steps'}, {'Eight Steps'}, {'Nine Steps'}];
    sumAsCell = num2cell(sum);
    result = [columnTitles;sumAsCell];
    writecell(result,fullfile(sampleFolderPath, 'sumOfCounts.csv'))

end

function digitCounts = csvTallyFxn(csvFilePath)
    %csvMatrix = readmatrix(csvFilePath);
    % Specify the path to your CSV file

% Read the CSV file

fullData = readtable(csvFilePath);
data = fullData.NumberOfSteps;

% Extract all the digits from the data
digitCounts = histcounts(data, 0:10);
 %{
% Display the results
disp('Digit Counts:');
disp('Digit | Occurrences');
disp('------+------------');
for digit = 0:9
    fprintf('%5d | %d\n', digit, digitCounts(digit + 1));
end
 %}
end