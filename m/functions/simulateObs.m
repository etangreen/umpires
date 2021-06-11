function [signal,sim] = simulateObs(S,cov)
% creates a signal distribution at every location on the grid and simulates
% the umpire's observations
%   S: 2-length vector of standard deviations
%   cov: scalar covariance

s = getParams; vcmat = [S(1)^2 cov; cov S(2)^2];

%% building blocks

F = reshape(mvncdf(s.cdfPts,[0 0],vcmat),[s.bigpts+1,s.bigpts+1]);
fx = F(2:end,:) - F(1:end-1,:); fxz = fx(:,2:end) - fx(:,1:end-1);
commonGrid = reshape(fxz,[s.bigpts^2,1]);

rng(s.seed); draws = int8(round(mvnrnd([0 0],vcmat,s.N_sim)));

%% loop over true locations

signal = zeros(s.pts^2); sim = zeros(s.pts^2,s.N_sim,'uint16'); 
for i=1:s.pts^2
    % signal distribution
    onGrid = min(abs(s.bigGrid + repmat(s.gridPts(i,:),[s.bigpts^2,1])) ...
        <= (s.pts-1)/2,[],2); 
    signal(:,i) = commonGrid(onGrid);
    
    % indices for simulated observations
    [~,ind] = ismember(min(max(draws + s.gridPts(i,:),-s.lim),s.lim), ...
        s.gridPts,'rows'); 
    sim(i,:) = ind;
end

end