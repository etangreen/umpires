function [] = mvnradius(S,cov)
% calculates the share of draws within some distance of true location
%   S: 2-length vector of standard deviations
%   cov: scalar covariance

R = mvnrnd([0 0],[S(1)^2 cov; cov S(2)^2],1e6); dist = sqrt(sum(R.^2,2));
fprintf('%2.0f%% within 2 inches.\n',100*mean(dist <= 2))
fprintf('%2.0f%% within 4 inches.\n',100*mean(dist <= 4))
fprintf('%2.0f%% within 6 inches.\n',100*mean(dist <= 6))

end

