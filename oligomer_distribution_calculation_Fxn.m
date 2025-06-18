function [olimericDistribution, olimericDistributionTable] = oligomer_distribution_calculation_Fxn(stepDistribution, maturationEfficiency)
% =========================================================================
% =========================== Input parameters ============================
% =========================================================================

% Observed fraction of k=[1,2,3...n] steps must be nx1 matrix.
if size(stepDistribution,2) ~= 1
    if size(stepDistribution,1) == 1
        observedStepDistribution = transpose(stepDistribution);
    else
        error('Input Matrix size is invalid! Input Distribution must be 1xn or nx1')
    end
else
    observedStepDistribution = stepDistribution;
end

% =========================================================================
% = Calculation of n-mer fractions based on observed k-step distributions =
% =========================================================================

n_max = length(observedStepDistribution)+1;          % max oligomeric state to consider, 4 = tetramer
s = n_max:n_max;    % s_n,k = theoretical fraction of k-steps in n-mers
p = n_max:n_max;    % p_n,k = normalized theoretical fraction of k-steps


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

A = zeros(n_max-1, n_max-1);
for n = 1 : (n_max-1)
    for k = 1 : (n_max-1)
        A(n,k) = p(k,n) - p(n_max, n);
    end
end

% and 
C = p(n_max, 1 : (n_max-1))';

% With these, we calculate X = [
X = A \ (observedStepDistribution - C);
%Alternatively we can implement the sum to 1 as an addtional row and then
%solve the PX = O imposing PX - O > 0
P = [p';ones(1,n_max)];
fullStepDist = [observedStepDistribution; 1-sum(observedStepDistribution)];
nonNegX = lsqnonneg(P, [fullStepDist;1]);

% =========================================================================
% ======================= Create an output Table ==========================
% =========================================================================
row_names = cell(n_max,1);
for n = 1 : n_max
    row_names{n} = ['percentage of monomers:  x_', num2str(n), ' ='];
end
X_all = round( [ [ X; (1 - sum(X))], nonNegX ]*100, 4);
olimericDistribution = X_all;
olimericDistributionTable = array2table(X_all, "RowNames", row_names, "VariableNames", ["x_n", "nonNegX_n"]);

end