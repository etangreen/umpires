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

%% priors and strike zones

for h=1:2
    % implied strike zone
    box1 = [-b(2,h,3); -b(2,h,3); b(1,h,3); b(1,h,3); -b(2,h,3)];
    box2 = [-b(4,h,3); b(3,h,3); b(3,h,3); -b(4,h,3); -b(4,h,3)];
    
    for c=1:s.N_c
        z = reshape(H{h}.RE_S(:,c), [s.pts, s.pts]);
        high = max(max(z)); ivl = ceil(high*1e3)/4e3;
        
        clf, hold on
        contour(s.dim,s.dim,z,ivl/10:ivl/10:high);
        [cnt,hdl] = contour(s.dim,s.dim,z,ivl:ivl:high,'LineWidth',2);
        clabel(cnt,hdl,'FontSize',20,'Interpreter','latex')
        caxis([0 high]), colormap(parula)
        contour(s.dim,s.dim,reshape(H{h}.enforced(:,c),[s.pts,s.pts]), ...
            [0 0],'k','LineWidth',2)
        contour(s.dim,s.dim,reshape(predicted(:,c,h,3),[s.pts,s.pts]),[0 0], ...
            '--k','LineWidth',2)
        saveFigure([s.count{c},s.hands{h}], box1, box2, 'zoom')

        % call density
        %drawDens(H{h}.RE_S(:,c),['CD_',s.count{c},s.hands{h}])
    end
end

%% size of enforced and predicted strike zone by count

y = sum([H{1}.labels H{2}.labels])'; x = reshape(x,[2*s.N_c,3]); 
l = cellfun(@(c) [c(1),'-',c(2)],s.count,'UniformOutput',0);
labels = [cellfun(@(c) [c,s.hands{1}],l,'UniformOutput',0) ...
    cellfun(@(c) [c,s.hands{2}],l,'UniformOutput',0)];

for j=1:3
    clf, hold on, axis([350 550 350 550])
    plot([350 550],[350 550],'-k')
    text(x(:,j),y,labels,'FontSize',20,'Interpreter','latex', ...
        'HorizontalAlignment','center')
    set(gca,'XTick',350:50:550,'YTick',350:50:550, ...
        'FontSize',20,'TickLabelInterpreter','latex')
    xlabel('Size of predicted strike zone (in$^2$)', ...
        'FontSize',20,'Interpreter','latex')
    ylabel('Size of enforced strike zone (in$^2$)', ...
        'FontSize',20,'Interpreter','latex')
    doSave(['zonesize',num2str(j)])
    
    fprintf('Model %d R-squared: %1.2f\n',j, ...
        1 - sum((y-x(:,j)).^2) / sum((y-mean(y)).^2))
end

%% area of disagreement

for j=1:3
   fprintf('Prior %d area of disagreement is %2.0f square inches\n', ...
       j, minL(j))
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