function [] = drawDens(p,filename)
% creates contour plot of density
%   p: pts^2-length vector of densities
%   filename: name of output file, with directory but without extension

s = getParams; z = reshape(p,[s.pts,s.pts]);
h = max(max(z)); ivl = ceil(h*1e3)/4e3;

clf, hold on
contour(s.dim,s.dim,z,ivl/10:ivl/10:h);
[cnt,hdl] = contour(s.dim,s.dim,z,ivl:ivl:h,'LineWidth',2);
clabel(cnt,hdl,'FontSize',20,'Interpreter','latex')
caxis([0 h]), colormap(parula)
saveFigure(filename,[],[],'density')

end

