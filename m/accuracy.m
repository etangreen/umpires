% estimates and plots changes in accuracy with different priors

clear, addpath('functions/'), s = getParams; load('../data/prelim')

%% grid of points

evaldim = 0.1:0.1:5; [b1,b2] = meshgrid(evaldim);
evalPts = [b1(:) b2(:)]; N_eval = length(evalPts);

%% average error rates, by batter handedness

e = zeros(N_eval,3,2); N_R = sum(H{1}.N); N_L = sum(H{2}.N); Z = s.Z_off;
parfor i=1:N_eval
    tic, [signal,sim] = simulateObs(evalPts(i,:),0);
    for j=1:3
        for h=1:2
            p = simulateCalls(priors{j}{h},signal,sim,Z);
            e(i,j,h) = s.error(p,Z,H{h}.calls);
        end
    end, toc
end
error = (e(:,:,1) * N_R + e(:,:,2) * N_L) / (N_R + N_L);

%% figures

V = {error(:,1), 1 - error(:,2)./error(:,1), 1 - error(:,3)./error(:,2)};
lines = {0:0.01:0.3,-0.002:0.002:0.05,-0.002:0.002:0.05};
marks = {0:0.05:0.3,0:0.01:0.05,0:0.01:0.05};
crange = {[0 0.3],[-0.05 0.05],[-0.05 0.05]};

for j=1:3
    z = reshape(V{j},[length(evaldim),length(evaldim)]);
    
    clf, hold on
    contour(evaldim,evaldim,z,lines{j})
    [cnt,hdl] = contour(evaldim,evaldim,z,marks{j},'LineWidth',2);
    clabel(cnt,hdl,'FontSize',20,'Interpreter','latex'), caxis(crange{j})
    saveFigure(['error',num2str(j)],[],[],'error')
end

%% improvement across counts, with example signal

[signal,sim] = simulateObs([3 3],0);
d21 = abs(simulateCalls(priors{2}{1},signal,sim,Z) - Z);
d22 = abs(simulateCalls(priors{2}{2},signal,sim,Z) - Z);
d31 = abs(simulateCalls(priors{3}{1},signal,sim,Z) - Z);
d32 = abs(simulateCalls(priors{3}{2},signal,sim,Z) - Z);

e2 = sum(H{1}.calls .* d21 + H{2}.calls .* d22) ./ N;
e3 = sum(H{1}.calls .* d31 + H{2}.calls .* d32) ./ N;

fprintf('%% decrease in error rate\n')
for c=1:s.N_c
    fprintf('\t%s: %1.2f\n',s.count{c},1 - e3(c) / e2(c))
end
