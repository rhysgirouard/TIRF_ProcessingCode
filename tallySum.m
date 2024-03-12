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
        if exist(csvFilePathChar, "file") ~= 0
            sum = sum + csvTallyFxn(csvFilePathChar);
        end
    end
    columnTitles = [{'Uncounted'}, {'One Step'}, {'Two Steps'}, {'Three Steps'}, {'Four Steps'}, {'Five Steps'}, {'Six Steps'}, {'Seven Steps'}, {'Eight Steps'}, {'Nine Steps'}];
    totalCounted = sum(2)+sum(3)+sum(4)+sum(5);
    fractions = [sum(2)/totalCounted, sum(3)/totalCounted, sum(4)/totalCounted];
    totalRow = [{'Total'}, num2cell(totalCounted), num2cell([0,0,0,0,0,0,0,0])];
    sumAsCell = num2cell(sum);
    fractionsAsCell = [{'Fraction'}, num2cell(fractions), num2cell(NaN(1,6))];
    emptyRow = num2cell(NaN(1,10));
    distributionTitles = [NaN, {'Monomers'}, {'Dimers'}, {'Trimers'}, {'Tetramers'}, num2cell(NaN(1,5))];
    [oligomericDistribtution, ~] = oligomer_distribution_calculation_Fxn(fractions(1:3), 0.7);
    oligomericDistribtution = [{'Fractions'}, num2cell(transpose(oligomericDistribtution)), num2cell(NaN(1,5))];
    result = [columnTitles; sumAsCell; totalRow; fractionsAsCell; emptyRow; distributionTitles; oligomericDistribtution];
    writecell(result,fullfile(sampleFolderPath, 'sumOfCounts.xlsx'))

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