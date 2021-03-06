% For a given pair of variance terms, finds the optimal covariance, and
% computes the loss.

clear, addpath('functions/'), s = getParams; 

%% create output directory, if necessary

grid_dir = '../data/grid/';
if ~exist(grid_dir, 'dir')
    mkdir(grid_dir)
end

%% point to evaluate

t = str2double(getenv('SGE_TASK_ID')); 
i = mod(t-1,s.N_eval)+1; S = s.evalPts(i,:); j = ceil(t/s.N_eval);
file_path = [grid_dir, num2str(j), '_',num2str(i)];

fprintf('Prior %d: [%1.1f, %1.1f]\n',j,S(1),S(2))

if exist([file_path, '.mat'], 'file')
    fprintf('Output file already exists\n')
    exit
end

%% preliminaries

load('../data/prelim'), w = sum(H{1}.N) / sum(H{1}.N + H{2}.N);
opt = optimset('Display','iter','TolX',0.1);

%% calculate loss under each model

cov_hat = zeros(2,1); loss = zeros(2,1);
for h=1:2
    prior = priors{j}{h}; hand = H{h}; Z = s.Z{h};
    [cov_hat(h),loss(h)] = fminbnd(@(b) getLoss(S,b,prior,hand,Z,0), ...
        (h == 1) * -prod(S),(h == 2) * prod(S),opt);
end
L = w * loss(1) + (1-w) * loss(2);

%% save

save(file_path, 'L', 'cov_hat')