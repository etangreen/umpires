function [p,h] = runProb(y,X,y2,X2)
% runs the local-linear regression estimator
%   y: N-length vector of outcomes
%   X: Nxk matrix of covariates
%   y2: M-length vector of outcomes (for difference plot)
%   X2: Mxk matrix of covariates (for difference plot)

s = getParams; x = double(s.gridPts);

%% find optimal bandwidth

Z = round(X); sd = std(Z); Z = Z ./ sd;

[U,~,ind] = unique([y Z],'rows'); c = grpstats(ind,ind,'numel');
y = U(:,1); Z = U(:,2:end); X = Z .* sd;
h = fminbnd(@(h) getMSE(h,c,y,Z),0,1,optimset('Display','iter')) * sd;

if nargin == 4
    Z2 = round(X2); sd2 = std(Z2); Z2 = Z2 ./ sd2;
    
    [U2,~,ind2] = unique([y2 Z2],'rows'); c2 = grpstats(ind2,ind2,'numel');
    y2 = U2(:,1); Z2 = U2(:,2:end); X2 = Z2 .* sd2;
    
    h2 = fminbnd(@(h) getMSE(h,c2,y2,Z2),0,1,optimset('Display','iter')) * sd2;
    h = max([h; h2]);
end

%% loop over points

p = zeros(size(x,1),1); 
for i=1:size(x,1)
    p(i) = ll(c,y,X,x(i,:),h);
end

if nargin == 4
    p2 = zeros(size(x,1),1);
    for i=1:size(x,1)
        p2(i) = ll(c2,y2,X2,x(i,:),h);
    end
    p = p - p2;
end

%% helper functions

    % computes MSE using leave-one-out cross validation
    function mse = getMSE(h,c,y,X)
        % h: 1x2 vector of bandwidths

        k = size(X,1); y_hat = zeros(k,1);
        for n=1:k
            e = (1:k ~= n)'; y_hat(n) = ll(c+e-1,y,X,X(n,:),h);
        end
        mse = mean(repelem((y-y_hat).^2,c),'omitnan');
    end

    % local linear regression
    function f = ll(c,y,X,x,bw)
        % c: N-length vector of count of each regressor value
        % x: 1x2 vector of coordinates to be estimated
        % bw: 1x2 vector of bandwidths

        % vector of weights
        W = @(h) (2*pi)^(-size(X,2)/2) * exp(-(sum(((X-x)./h).^2,2))/2) .* c;

        % regression
        Z = [ones(length(y),1) X]; WZ = W(bw).*Z;
        if det(WZ'*Z) < 1e-10
            f = nan;
        else
            f = [1 x] * ((WZ'*Z)\WZ'*y);
        end
    end
    
end