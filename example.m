% creates the example graphs in the theory section

clear, addpath('repo/functions/'), s = getParams; load('data/prelim')

%% data

opts = detectImportOptions('data/pitches.csv');
opts = setvaropts(opts, 'count', 'Type', 'string');
T = readtable('data/pitches.csv', opts);

y = T.take; X = [T.px T.pz_std];

inzone = @(e) mean(abs(T.px(e)) <= s.edge1 & abs(T.pz_std(e)) <= s.edge2);

%% overall

p = runDens(X); q = runProb(y,X); 

drawDens(p,'PD_R'), drawProb(q,0,1,'TR_R'), drawDens(H{1}.RE,'CD_R')

fprintf('Overall.\n')
fprintf('\tPitches in zone: %1.4f\n',inzone(true(height(T),1)))
fprintf('\tCalls in zone: %1.4f\n',inzone(T.take == 1))

%% 3-0 count

e30 = strcmp(T.count,'30'); p30 = runDens(X(e30,:)); drawDens(p30,'PD_30R')
q30 = runProb(y(e30),X(e30,:)); drawProb(q30,0,1,'TR_30R')

fprintf('3-0.\n')
fprintf('\tPitches in zone: %1.4f\n',inzone(e30))
fprintf('\tCalls in zone: %1.4f\n',inzone(e30 & T.take == 1))

%% 0-2 count

e02 = strcmp(T.count,'02'); p02 = runDens(X(e02,:)); drawDens(p02,'PD_02R')
q02 = runProb(y(e02),X(e02,:)); drawProb(q02,0,1,'TR_02R')

fprintf('0-2.\n')
fprintf('\tPitches in zone: %1.4f\n',inzone(e02))
fprintf('\tCalls in zone: %1.4f\n',inzone(e02 & T.take == 1))

%% posterior beliefs

S = [3 3]; mvnradius(S,0), signal = simulateObs(S,0);

post = zeros(s.pts^2,s.pts^2,4);
for i=1:s.pts^2
    post(:,i,1) = signal(:,i) / sum(signal(:,i));
    b = signal(:,i) .* H{1}.RE; post(:,i,2) = b / sum(b);
    b = signal(:,i) .* H{1}.RE_S(:,10); post(:,i,3) = b / sum(b);
    b = signal(:,i) .* H{1}.RE_S(:,3); post(:,i,4) = b / sum(b);
end

%% plots of posteriors

x_u = int8([7 9]); j = min(s.gridPts == x_u,[],2); % observed location

% decision boundary
Z = s.getZone([s.edge1 s.edge1 s.edge2 s.edge2]);
z_text = [8.5 8.4 9.75 6.9];

for i=1:4
    inzone = reshape(sum(post(:,:,i) .* Z),[s.pts,s.pts]);
    
    clf, hold on
    plot(x_u(1),x_u(2),'xk','MarkerSize',20)
    contour(s.dim,s.dim,reshape(post(:,j,i),[s.pts,s.pts]),0:0.0025:0.05)
    contour(s.dim,s.dim,inzone,[0.5 0.5],'-k')
    text(z_text(i)+0.05,0.5,'$\rightarrow$ball','Interpreter','latex', ...
        'FontSize',20)
    text(z_text(i)-0.05,0.5,'strike$\leftarrow$','Interpreter','latex', ...
        'FontSize',20,'HorizontalAlignment','right')
    caxis([0 max(post(:,j,i))])
    saveFigure(['post',num2str(i)],[8.5; 8.5; 0],[0; 10.5; 10.5],'example')
end