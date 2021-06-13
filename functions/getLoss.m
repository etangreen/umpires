function [loss,b_i,y_hat,predicted,p] = getLoss(S,cov,prior,hand,Z,workers)
% returns loss value
%   S: 2-length vector of standard deviations
%   cov: scalar covariance
%   prior: pts^2 x N_s matrix of prior beliefs
%   hand: struct of estimates from prelim.mat specific to given handedness
%   Z: pts^2 x N_bounds matrix of indicators for inside strike zone
%   workers: number of workers

s = getParams; 

% simulate observations and calls
[signal,sim] = simulateObs(S, cov, workers);
p = simulateCalls(prior, signal, sim, Z, workers);

% predicted strike zone
[y_hat,predicted] = predictZone(p, hand.C, workers);

% find best bounds
[loss,b_i] = min(s.loss(y_hat, hand.labels, hand.N'/sum(hand.N)));

end