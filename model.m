% For a given pair of variance terms, finds the optimal covariance, and
% computes the loss.

clear, addpath('repo/functions/'), s = getParams; 

%% point to evaluate

t = str2double(getenv('SGE_TASK_ID')); 
i = mod(t-1,s.N_eval)+1; S = s.evalPts(i,:); j = ceil(t/s.N_eval);

fprintf('Prior %d: [%1.1f, %1.1f]\n',j,S(1),S(2))

%% preliminaries

load('../data/prelim'), w = sum(H{1}.N) / sum(H{1}.N + H{2}.N);
opt = optimset('Display','iter','TolX',0.1);

%% calculate loss under each model

cov_hat = zeros(2,1); loss = zeros(2,1);
for h=1:2
    prior = priors{j}{h}; hand = H{h}; Z = s.Z{h};
    [cov_hat(h),loss(h)] = fminbnd(@(b) getLoss(S,b,prior,hand,Z), ...
        (h == 1) * -prod(S),(h == 2) * prod(S),opt);
end
L = w * loss(1) + (1-w) * loss(2);

%% save

save(['data/model/',num2str(j),'_',num2str(i)],'L','cov_hat')