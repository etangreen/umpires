function p = simulateCalls(prior,signal,sim,Z)
% returns simulated rate of called strike at each true location on grid
%   prior: pts^2 x N_s matrix of prior beliefs
%   signal: pts^2 x pts^2 matrix of signal distributions for possible
%       observations
%   sim: pts^2 x N_sim matrix of simulated observations
%   Z: pts^2 x N_bounds matrix of indicators for inside strike zone

%% parameters

s = getParams; N_s = max(1,size(prior,2)); N_b = size(Z,2); Z = permute(Z,[1,3,2]);

%% decision for every possible observation

strike = zeros(s.pts^2,N_s,N_b,'logical');
if isempty(prior)
    for i=1:s.pts^2
        strike(i,:,:) = sum(signal(:,i) .* Z) >= 0.5;
    end    
else
    for i=1:s.pts^2
        post = signal(:,i) .* prior;
        normalized = post ./ sum(post) * sum(signal(:,i));
        strike(i,:,:) = sum(normalized .* Z) >= 0.5;
    end
end

%% rate of called strikes among simulated observations

p = nan(s.pts^2,N_s,N_b);
for i=1:s.pts^2
    p(i,:,:) = mean(strike(sim(i,:),:,:));
end