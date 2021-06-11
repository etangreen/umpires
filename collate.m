% 1) compiles the grid search files
% 2) finds the optimal parameter values
% 3) calculates standard errors for the variance terms

clear, addpath('repo/functions/'), s = getParams; load('data/prelim')

%% compile estimates

M = nan(s.N_eval,3); cov = nan(s.N_eval,3,2); 
for j=1:3
    for t=1:s.N_eval
        load(['data/model/',num2str(j),'_',num2str(t)])
        M(t,j) = L; cov(t,j,:) = cov_hat;
    end
end

%% find optimal parameter values

[minL,ind] = min(M); S_hat = s.evalPts(ind,:);
cov_hat = [diag(cov(ind,:,1)) diag(cov(ind,:,2))];

%% find boundaries of strike zone

x = zeros(s.N_c,2,3); e = zeros(2,2,3); box = zeros(5,2,2,'int8');
for h=1:2
    N_S = H{h}.calls;
    for j=1:3
        [~,b_i,y_hat,predicted,p] = ...
            getLoss(S_hat(j,:),cov_hat(j,h),priors{j}{h},H{h},s.Z{h});

        x(:,h,j) = sum(y_hat(:,:,b_i));
        
        b = s.bounds{h}(b_i,:); p = p(:,:,b_i); Z = s.Z{h}(:,b_i);
        e(:,j,h) = [s.error(p,s.Z_off,N_S); s.error(p,Z,N_S)];
        
        fprintf('%sHB model %d: [%d %d %d %d]\n', ...
            s.hands{h},j,b(1),b(2),b(3),b(4))
        mvnradius(S_hat(j,:),cov_hat(j,h))
    end

    % implied strike zone with count-specific prior
    box(:,1,h) = [-b(2); -b(2); b(1); b(1); -b(2)];
    box(:,2,h) = [-b(4); b(3); b(3); -b(4); -b(4)];
end

%% save

save('data/structural', 'S_hat', 'cov_hat', 'x', 'e', 'box')