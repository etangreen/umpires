function [] = drawProb(p,low,high,filename)
% creates contour plot of density
%   p: pts^2-length vector of probabilities
%   low: scalar for lower bound of color axis
%   high: scalar for upper bound of color axis
%   filename: name of output file, with directory but without extension

s = getParams; z = reshape(p,[s.pts,s.pts]);
if max(p) < 0.9
    marks = -0.9:0.1:0.9;
else
    marks = 0.1:0.2:0.9;
end

clf, hold on
contour(s.dim,s.dim,z,-0.975:0.025:0.975)
[cnt,hnd] = contour(s.dim,s.dim,z,marks,'LineWidth',2);
caxis([low high]), colormap(parula)
clabel(cnt,hnd,'FontSize',20,'Interpreter','latex')
if contains(filename,'TR')
    saveFigure(filename,[],[],'density')
else
    saveFigure(filename,[],[],'zoom')
end
    
end