function p = runDens(X,bw)
% computes density of X on grid
%   X: Nx2 matrix of locations
%   bw: optional bandwidth

s = getParams;

%% bandwidth

if nargin == 1
    bw = s.h(X);
end

%% kernel density estimator

f = @(x) (size(X,1)*prod(bw))^-1 * sum(s.kern((X-x)./bw));

%% loop over points

x = double(s.gridPts); p = zeros(s.pts^2,1);
parfor i=1:s.pts^2
    p(i) = f(x(i,:));
end

end