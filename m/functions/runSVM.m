function [boundary,labels,C] = runSVM(y,X,C)
% fits support vector machine to y and X data
%   y: N-length vector of outcomes
%   X: Nx2 matrix of locations
%   C: scalar slack cost

s = getParams;

% weights
[x1x2,~,j] = unique(round(X), 'rows'); total = grpstats(j,j,'numel');
totals = array2table([x1x2 total], 'VariableNames', {'x1', 'x2', 'total'});

% collapse data
[U,~,j] = unique([y round(X)],'rows'); count = grpstats(j,j,'numel');
counts = array2table([U count], 'VariableNames', {'y', 'x1', 'x2', 'count'});

T = join(counts, totals); T.w = T.count ./ T.total;

% fit support vector machine
if nargin == 2
    m = fitcsvm([T.x1, T.x2], T.y, 'Weights', T.w, 'KernelFunction','rbf', ...
        'ClassNames',[0 1],'Standardize',1,'KernelScale',1, ...
        'OptimizeHyperparameters',{'BoxConstraint'}, ...
        'HyperparameterOptimizationOptions',s.opt);
    C = m.ModelParameters.BoxConstraint;
else
    m = fitcsvm([T.x1, T.x2], T.y, 'Weights', T.w, 'KernelFunction','rbf', ...
        'ClassNames',[0 1],'Standardize',1,'KernelScale',1,'BoxConstraint',C);
end

% output
[labels,S] = predict(m,double(s.gridPts)); boundary = S(:,2);

end
