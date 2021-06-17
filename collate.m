% 1) compiles the grid search files
% 2) finds the optimal parameter values
% 3) calculates standard errors for the variance terms

clear, addpath('functions/'), s = getParams; load('../data/prelim')

%% compile estimates

M = nan(s.N_eval,3); cov = nan(s.N_eval,3,2); 
for j=1:3
    for i=1:s.N_eval
        try
            load(['../data/grid/',num2str(j), '_', num2str(i)])
            M(i,j) = L; cov(i,j,:) = cov_hat;
        catch
            fprintf('Could not find %d: [%.2f, %.2f].\n', ...
                j, s.evalPts(i, 1), s.evalPts(i, 2))
        end
    end
end

%% find optimal parameter values

[minL, ind] = min(M); S_hat = s.evalPts(ind,:);
cov_hat = [diag(cov(ind,:,1)) diag(cov(ind,:,2))];

%% find boundaries of strike zone

pool = parpool(s.num_workers);

x = zeros(s.N_c,2,3); error = zeros(2,2,3); 
b = zeros(4,2,3); predicted = zeros(s.pts^2,s.N_c,2,3);
for h=1:2
    N_S = H{h}.calls;
    for j=1:3
        [~,b_i,y_hat,pred_i,p] = ...
            getLoss(S_hat(j,:), cov_hat(j,h), ...
                priors{j}{h}, H{h}, s.Z{h}, s.num_workers);
    
        x(:,h,j) = sum(y_hat(:,:,b_i));
        
        b(:,h,j) = s.bounds{h}(b_i,:); p = p(:,:,b_i); Z = s.Z{h}(:,b_i);
        
        error(:,h,j) = [s.error(p,s.Z_off,N_S); s.error(p,Z,N_S)];
        predicted(:,:,h,j) = pred_i(:,:,b_i);
        
        fprintf('%sHB model %d: [%d %d %d %d]\n', ...
            s.hands{h},j,b(1,h,j),b(2,h,j),b(3,h,j),b(4,h,j))
        mvnradius(S_hat(j,:),cov_hat(j,h))
    end
end

delete(pool)

%% save

save('../data/structural', ...
    'minL', 'S_hat', 'cov_hat', 'x', 'error', 'b', 'M', 'predicted')