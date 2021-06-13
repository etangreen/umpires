% creates the figures in descriptives section and the appendices

clear, addpath('functions/'), load('../data/prelim'), s = getParams;

%% data

opts = detectImportOptions('../data/calls.csv');
opts = setvaropts(opts, 'count', 'Type', 'string');
T = readtable('../data/calls.csv', opts);

%% blank plane

clf, saveFigure('blank',[],[],'zoom')

%% plots on full data

y = T.strike; X = [T.px T.pz_std];

% gambler's fallacy
counts = {'01','02','11'};
for c=1:length(counts)
    e1 = strcmp(T.count,counts{c}) & T.Lstrike; 
    e2 = strcmp(T.count,counts{c}) & ~T.Lstrike;

    p = runProb(y(e1),X(e1,:),y(e2),X(e2,:));
    drawProb(p,-0.4,0.4,['Lstrike_',counts{c}]);
end

% home vs. away
e1 = T.bottomhalf == 1; e2 = T.bottomhalf == 0;
p = runProb(y(e1),X(e1,:),y(e2),X(e2,:)); drawProb(p,-0.4,0.4,'home')

% ahead vs. behind
e1 = T.pahead == 1; e2 = T.bahead == 1;
p = runProb(y(e1),X(e1,:),y(e2),X(e2,:)); drawProb(p,-0.4,0.4,'ahead')

%% plots by batter handedness

D = {T(T.batsR == 1,:), T(T.batsR == 0,:)}; clear T

y = {D{1}.strike, D{2}.strike};
X = {[D{1}.px D{1}.pz_std], [D{2}.px D{2}.pz_std]};

lines = {'-k','--k','-.k'};
for h=1:2
    % probability of strike call in 0-0 count
    e0 = strcmp(D{h}.count,'00'); p = runProb(y{h}(e0),X{h}(e0,:));
    drawProb(p,0,1,['p00',s.hands{h}])
    
    % difference in probability of called strike
    e1 = strcmp(D{h}.count,'30'); e2 = strcmp(D{h}.count,'02');
    p = runProb(y{h}(e1),X{h}(e1,:),y{h}(e2),X{h}(e2,:));
    drawProb(p,0,0.6,['pdiff',s.hands{h}])
    
    % enforced strike zone by count
    clf, hold on
    contour(s.dim,s.dim,reshape(H{h}.enforced(:,10),[s.pts,s.pts]), ...
        [0 0],lines{2},'LineWidth',2)
    contour(s.dim,s.dim,reshape(H{h}.enforced(:,1),[s.pts,s.pts]), ...
        [0 0],lines{1},'LineWidth',2)
    contour(s.dim,s.dim,reshape(H{h}.enforced(:,3),[s.pts,s.pts]), ...
        [0 0],lines{3},'LineWidth',2)
    legend({'3-0','0-0','0-2'},'Interpreter','latex', ...
        'box','off','Location','NorthEast','FontSize',20);
    saveFigure(['enforced_',s.hands{h}],[],[],'zoom')
    
    % priors and enforced strike zone by year
    bw = [0 0];
    for n=1:7
        bw = max(bw,s.h(X{h}(e0 & D{h}.year == 2008 + n,:)));
    end
    
    M = zeros(s.pts^2,7);
    for n=1:7
        year = 2008 + n; e = e0 & D{h}.year == year;
        drawDens(runDens(X{h}(e,:),bw),['CD',num2str(year),s.hands{h}])
        M(:,n) = runSVM(y{h}(e),X{h}(e,:));
    end
    
    clf, hold on
    for n=1:7
        contour(s.dim,s.dim,reshape(M(:,n),[s.pts,s.pts]), ...
            [0 0],'-k','LineWidth',1.5)
    end
    saveFigure(['00',s.hands{h},'_year'],[],[],'zoom')
end

%% coefficient plots

T = readtable('../data/coef/counts.csv');

keys = {'byUmp','experience','breaking','impact'}; M = containers.Map();
for i=1:length(keys)
    key = keys{i}; v = readtable(['../data/coef/',key,'.csv']); v.text = T.text;
    v.ind = T.bstrike; v = sortrows(v,'ind'); v.ind = []; M(key) = v;
end
T = sortrows(T,'bstrike');

% equation 1
drawCoef(join(T,M('breaking')),{'Four-seam fastballs', ...
    'Other pitch types'},'bstrike')

% equation 1 by experience
drawCoef(M('experience'),{'First game before 1999', ...
    'First game in 1999','First game after 1999'},'bstrike_e')

% equation 1 by ump
clf, hold on
for u=1:width(M('byUmp'))-1
    plot(1:12,M('byUmp').(u),'-k')
end
plot([1 12],[0 0],'-k')
axis([1 12 -0.2 0.2])
set(gca,'XTick',1:12,'XTickLabels',M('byUmp').text,'YTick',-0.2:0.1:0.2, ...
    'FontSize',20,'TickLabelInterpreter','latex'), xtickangle(45)
doSave('bstrike_u')

% equation 2
drawCoef(M('impact'),{'$\hat{\beta}_{b,s}$','$\hat{\gamma}_{b,s}$'},'bstrike_ai')