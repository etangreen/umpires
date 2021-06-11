function s = getParams
% parameters for estimation and figures

s = struct; s.hands = {'R','L'};

%% grids

s.lim = 24; s.dim = -s.lim:s.lim; s.pts = length(s.dim);
[b1,b2] = meshgrid(s.dim); s.gridPts = int8([b1(:) b2(:)]);

bigdim = double(2*(-s.lim):2*s.lim); s.bigpts = length(bigdim);
[b1,b2] = meshgrid(bigdim); s.bigGrid = int8([b1(:) b2(:)]);

cdfdim = bigdim(1) - 0.5:bigdim(end) + 0.5;
[b1,b2] = meshgrid(cdfdim); s.cdfPts = [b1(:) b2(:)];

s.evaldim = 1:0.1:5; [b1,b2] = meshgrid(s.evaldim);
s.evalPts = [b1(:) b2(:)]; s.N_eval = length(s.evalPts);

%% strike zone boundaries

s.edge1 = 8.5; s.edge2 = 10.98;
s.getZone = @(b) s.gridPts(:,1) <= b(:,1) & s.gridPts(:,1) >= -b(:,2) ...
    & s.gridPts(:,2) <= b(:,3) & s.gridPts(:,2) >= -b(:,4);
s.Z_off = s.getZone(round([s.edge1 s.edge1 s.edge2 s.edge2]));

%% counts

s.count = {'00','01','02','10','11','12','20','21','22','30','31','32'};
s.N_c = length(s.count);

%% hyperparameter optimization options

s.opt = struct; s.opt.Kfold = 10; s.opt.Repartition = 1;
s.opt.UseParallel = 1; s.opt.ShowPlots = false;

%% simulation parameters

s.seed = 123; s.N_sim = 1e4;

%% for grid-search optimization

s.side = {[10:13; 11:14],[8:11; 12:15]}; s.top = 10;
[R1,R2,R3,R4] = ndgrid(s.side{1}(1,:),s.side{1}(2,:),s.top,s.top);
[L1,L2,L3,L4] = ndgrid(s.side{2}(1,:),s.side{2}(2,:),s.top,s.top);
s.bounds = {int8([R1(:) R2(:) R3(:) R4(:)]), int8([L1(:) L2(:) L3(:) L4(:)])};
s.N_b = length(s.bounds{1}); s.Z = cell(1,2);
for b=1:s.N_b
    for h=1:2
        s.Z{h}(:,b) = s.getZone(s.bounds{h}(b,:));
    end
end

%% Silverman's rule-of-thumb bandwidth

s.h = @(A) 1.06 .* std(A) .* size(A,1) .^ -0.2;

%% Gaussian kernel

s.kern = @(M) (2*pi)^(-1) * exp(-(sum(M.^2,2))/2);

%% wrapper for SVM

X = double(s.gridPts); labels = [ones(s.pts^2,1); zeros(s.pts^2,1)];
s.SVM = @(w,C) fitcsvm([X; X],labels,'Weights',w,'KernelFunction','rbf', ...
    'ClassNames',[0 1],'Standardize',1,'KernelScale',1,'BoxConstraint',C);

%% loss function

s.loss = @(z1,z2,omega) permute(sum(sum(z1 ~= z2) .* omega,2),[3,2,1]);

%% error rate

s.error = @(p,Z,N) sum(sum(N .* abs(p - Z),'omitnan')) / sum(sum(N));

%% number of workers

s.num_workers = 32;

end

