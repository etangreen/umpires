% creates the figures in the structural estimation section

clear, addpath('functions/'), s = getParams; 
load('../data/prelim'), load('../data/structural')

%% optimal bounds and objective function plots

for j=1:3
    z = reshape(M(:,j),[length(s.evaldim),length(s.evaldim)]);
    
    clf, hold on
    contour(s.evaldim,s.evaldim,z,0:1:200)
    [cont,handle] = contour(s.evaldim,s.evaldim,z,0:5:200,'LineWidth',2);
    plot(S_hat(j,1),S_hat(j,2),'pk','MarkerSize',10,'MarkerFaceColor','k')
    caxis([25 85]), colormap(flipud(parula))
    clabel(cont,handle,'FontSize',20,'Interpreter','latex')
    saveFigure(['objfun',num2str(j)],[],[],'objfun')
end

%% distribution of signal

for j=1:3
    for h=1:2
        vcmat = [S_hat(j,1)^2 cov_hat(j,h); cov_hat(j,h) S_hat(j,2)^2];
        draws = mvnrnd([0 0],vcmat,s.N_sim);
        
        clf, hold on, axis([-15 15 -15 15])
        plot(draws(:,1),draws(:,2),'.k','MarkerSize',3)
        saveFigure(['signal_',num2str(j),s.hands{h}],[],[],'zoom')
    end
end

%% by batter handedness

x = zeros(s.N_c,2,3); e = zeros(2,2,3);
for h=1:2
    for c=1:s.N_c
        % enforced and predicted strike zone
        clf, hold on
        contour(s.dim,s.dim,reshape(H{h}.enforced(:,c),[s.pts,s.pts]), ...
            [0 0],'k','LineWidth',2)
        contour(s.dim,s.dim,reshape(predicted(:,c,b_i),[s.pts,s.pts]),[0 0], ...
            '--k','LineWidth',2)
        saveFigure([s.count{c},s.hands{h},num2str(j)],box1,box2,'zoom')

        % call density
        drawDens(H{h}.RE_S(:,c),['CD_',s.count{c},s.hands{h}])
    end
    
    % ball and strike counts for predicted probabilities
    col = [1 3 10];
    N_s = cell(3,1); N_b = cell(3,1); y = cell(3,1); X = cell(3,1);
    for n=1:3
        N_s{n} = round(100 * p(:,col(n)) .* H{h}.calls(:,col(n)));
        N_b{n} = round(100 * (1-p(:,col(n))) .* H{h}.calls(:,col(n)));
        y{n} = [ones(sum(N_s{n}),1); zeros(sum(N_b{n}),1)];
        X{n} = double([repelem(s.gridPts,N_s{n},1); ...
            repelem(s.gridPts,N_b{n},1)]);
    end
    
    % predicted probability in 0-0 count
    drawProb(runProb(y{1},X{1}),0,1,['pstrike_00',s.hands{h},'_hat'])

    % probability difference between 3-0 and 0-2
    drawProb(runProb(y{3},X{3},y{2},X{2}),0,0.4,['pdiff',s.hands{h},'_hat'])
end

%% error rates and pitches inside zone

N_C = (H{1}.calls + H{2}.calls); p0 = (H{1}.strikes + H{2}.strikes) ./ N_C;
error = (e(:,:,1) * sum(H{1}.N) + e(:,:,2) * sum(H{2}.N)) / sum(sum(N_C)); 
for j=1:3
    fprintf('\tError under official zone: %1.3f [%1.3f]\n', ...
        error(1,j),s.error(p0,s.Z_off,N_C))
    fprintf('\tError under implied zone: %1.3f [%1.3f]\n', ...
        error(2,j),s.error(p0,Z,N_C))
end

%% size of enforced and predicted strike zone by count

y = sum([H{1}.labels H{2}.labels])'; x = reshape(x,[2*s.N_c,3]); 
l = cellfun(@(c) [c(1),'-',c(2)],s.count,'UniformOutput',0);
labels = [cellfun(@(c) [c,s.hands{1}],l,'UniformOutput',0) ...
    cellfun(@(c) [c,s.hands{2}],l,'UniformOutput',0)];

for j=1:3
    clf, hold on, axis([300 600 300 600])
    plot([300 600],[300 600],'-k')
    text(x(:,j),y,labels,'FontSize',20,'Interpreter','latex', ...
        'HorizontalAlignment','center')
    set(gca,'XTick',300:100:600,'YTick',300:100:600, ...
        'FontSize',20,'TickLabelInterpreter','latex')
    xlabel('Size of predicted strike zone (in$^2$)', ...
        'FontSize',20,'Interpreter','latex')
    ylabel('Size of enforced strike zone (in$^2$)', ...
        'FontSize',20,'Interpreter','latex')
    doSave(['zonesize',num2str(j)])
    
    fprintf('Model %d R-squared: %1.2f\n',j, ...
        1 - sum((y-x(:,j)).^2) / sum((y-mean(y)).^2))
end

%% standard errors from approximate Hessian

V = int8(round(s.evalPts*10));
X = [-1 0; 1 0; 0 -1; 0 1; -1 -1; -1 1; 1 -1; 1 1]/10;

% objective function values near optimum
S = int8(round(S_hat(3,:)*10));
L_10 = M(min(V == [S(1)-1, S(2)],[],2),3);
L10 = M(min(V == [S(1)+1, S(2)],[],2),3);
L0_1 = M(min(V == [S(1), S(2)-1],[],2),3);
L01 = M(min(V == [S(1), S(2)+1],[],2),3);
L_1_1 = M(min(V == [S(1)-1, S(2)-1],[],2),3);
L_11 = M(min(V == [S(1)-1, S(2)+1],[],2),3);
L1_1 = M(min(V == [S(1)+1, S(2)-1],[],2),3);
L11 = M(min(V == [S(1)+1, S(2)+1],[],2),3);

% fit paraboloid
Lij = [L_10 L10 L0_1 L01 L_1_1 L_11 L1_1 L11]';
f = @(b) sum((b(1) * X(:,1).^2 + b(2) * X(:,2).^2 ...
    + b(3) * X(:,1) .* X(:,2) + minL(3) - Lij).^2);
param = fminunc(@(b) f(b),[0 0 0]);

% Hessian and standard errors
Hess = [2*param(1) param(3); param(3) 2*param(2)];
se = sqrt(diag(inv(Hess)));
fprintf('Standard errors: [%1.2f, %1.2f]\n', se(1), se(2))