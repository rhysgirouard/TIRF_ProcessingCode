function [olimericDistribution, olimericDistributionTable] = oligomer_distribution_calculation_Fxn(stepDistribution, maturationEfficiency)
% =========================================================================
% =========================== Input parameters ============================
% =========================================================================

% Observed fraction of k=[1,2,3] steps as 3x1 matrix.
observedStepDistribution = transpose(stepDistribution);

maturationEfficiency; 

% =========================================================================
% = Calculation of n-mer fractions based on observed k-step distributions =
% =========================================================================

n_max = 4;          % max oligomeric state to consider, 4 = tetramer
s = n_max:n_max;    % s_n,k = theoretical fraction of k-steps in n-mers
p = n_max:n_max;    % p_n,k = normalized theoretical fraction of k-steps

% === Check input ===
if ~isequal(size(observedStepDistribution), [1 3])
    
end
if n_max ~= 4
    error("Calculation valid for upto tetramers, so n_max must be 4")
end

% === Calculate theoretical probability of k-steps in n-mers ===
for n = 1:n_max
    for k = 1:n_max
        % (# combinations of choosing k subunits from total n subunits) x 
        % (probability of mature GFP on k subunits) x 
        % (probability of dark GFP on the rest n-k subunits)
        if k <= n
            nck = nchoosek(n, k);
        else
            nck = 0;
        end
        s(n, k) = nck * (maturationEfficiency^k) * ((1-maturationEfficiency)^(n-k));
    end
end

% === Normalize theoretical fraction of k-steps in n-mers ===
for n = 1:n_max
    for k = 1:n_max
        p(n, k) = s(n, k) / sum(s(n,:));
    end
end

% === Calculate fractions of n-mers based on observated fraction of k-steps ===

% Say the fraction of fraction of n-mers is [ x_1 ; x_2 ; x_3 ; x_4 ]
% Since we are considering x_1 + x_2 + x_3 + x_4 = 1, we have 
% reduced to a system of 3 equations represented as a matrix equation
% of size 3 matrices: AX = O - C where

% X = [ x_1 ; x_2 ; x_3 ] and

A = [  
        p(1,1) - p(4,1),    p(2,1) - p(4,1),    p(3,1) - p(4,1);
        p(1,2) - p(4,2),    p(2,2) - p(4,2),    p(3,2) - p(4,2);
        p(1,3) - p(4,3),    p(2,3) - p(4,3),    p(3,3) - p(4,3)        
    ];

% and 

C = [
        p(4,1);
        p(4,2);
        p(4,3)
    ];

% With these, we calculate X = [
X = inv(A) * (observedStepDistribution - C);

% =========================================================================
% ======================= Create an output Table ==========================
% =========================================================================

row_names = [
    "percentage of monomers:  x_1 ="; 
    "percentage of dimers:    x_2 ="; 
    "percentage of trimers:   x_3 =";
    "percentage of tetramers: x_4 ="];
X_all = round([ X(1); X(2); X(3); (1 - sum(X))] * 100, 4);
olimericDistribution = X_all;
olimericDistributionTable = array2table(X_all, "RowNames", row_names, "VariableNames", "x_n");

end