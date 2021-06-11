function [loss,b_i,y_hat,predicted,p] = getLoss(S,cov,prior,hand,Z)
% returns loss value
%   S: 2-length vector of standard deviations
%   cov: scalar covariance
%   prior: pts^2 x N_s matrix of prior beliefs
%   hand: struct of estimates from prelim.mat specific to given handedness
%   Z: pts^2 x N_bounds matrix of indicators for inside strike zone

s = getParams; 

% simulate observations and calls
[signal,sim] = simulateObs(S, cov);
p = simulateCalls(prior, signal, sim, Z);

% predicted strike zone
[y_hat,predicted] = predictZone(p, hand.C);

% find best bounds
[loss,b_i] = min(s.loss(y_hat, hand.labels, hand.N'/sum(hand.N)));

end