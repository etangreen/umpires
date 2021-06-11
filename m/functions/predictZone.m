function [y_hat,score] = predictZone(p,C)
% estimates predicted strike zone
%   p: pts^2 x N_s matrix of simulated called strike rates
%   C: scalar slack cost hyperparameter for SVM

s = getParams; N_b = size(p,3); X = double(s.gridPts);
if size(p,2) == 1
    p = repmat(p,[1,s.N_c,1]);
end

% compute SVM for predicted strike zone
y_hat = zeros(s.pts^2,s.N_c,N_b,'logical'); 
score = zeros(s.pts^2,s.N_c,N_b);
for c=1:s.N_c
    for b=1:N_b
        weights = [p(:,c,b); 1-p(:,c,b)];
        [y_hat(:,c,b),M] = predict(s.SVM(weights,C(c)), X);
        score(:,c,b) = M(:,2);
    end
end

end

