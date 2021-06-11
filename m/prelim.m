% estimates priors and enforced strike zone

clear, addpath('functions/'), s = getParams; H = {struct,struct};

%% data

opts = detectImportOptions('../data/calls.csv');
opts = setvaropts(opts, 'count', 'Type', 'string');
T = readtable('../data/calls.csv',opts);
D = {T(T.batsR == 1,{'count','px','pz_std','strike'}), ...
    T(T.batsR == 0,{'count','px','pz_std','strike'})}; clear T

%% initialize workers

pool = parpool(s.num_workers);

%% loop over batter handedness

for h=1:2
    % calls by count
    [~,~,i] = unique(D{h}.count); H{h}.N = grpstats(i,i,'numel');
    
    % overall call density
    H{h}.RE = runDens([D{h}.px D{h}.pz_std]);
    
    % loop over counts
    H{h}.calls = zeros(s.pts^2,s.N_c); H{h}.strikes = zeros(s.pts^2,s.N_c);
    H{h}.RE_S = nan(s.pts^2,s.N_c); H{h}.enforced = nan(s.pts^2,s.N_c);
    H{h}.labels = zeros(s.pts^2,s.N_c,'logical'); H{h}.C = nan(s.N_c,1);
    for c=1:s.N_c
        ct = s.count{c}; e = strcmp(D{h}.count,ct); fprintf('%s\n',ct);
        X = [D{h}.px(e) D{h}.pz_std(e)]; y = D{h}.strike(e);
        
        % calls by location
        Z = min(max(int8(round(X)),-s.lim),s.lim); ZS = Z(y == 1,:);
        for i=1:s.pts^2
            H{h}.calls(i,c) = sum(sum(abs(Z - s.gridPts(i,:)),2) == 0);
            H{h}.strikes(i,c) = sum(sum(abs(ZS - s.gridPts(i,:)),2) == 0);
        end
        
        % count-specific density
        H{h}.RE_S(:,c) = runDens(X);

        % enforced strike zone
        [H{h}.enforced(:,c),H{h}.labels(:,c),H{h}.C(c)] = runSVM(y,X);
    end
end

delete(pool)

%% organize priors

priors = {{[], []},{H{1}.RE, H{2}.RE},{H{1}.RE_S, H{2}.RE_S}};

%% save

save('../data/prelim','H','priors')