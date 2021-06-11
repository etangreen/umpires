function [] = drawCoef(T,labels,filename)
% creates contour plot of density
%   T: table of estimates, alternating between betas and variances
%   labels: legend labels
%   filename: name of output file, with directory but without extension

counts = T.text; T.text = []; colors = {'k','w',[0.5 0.5 0.5]};
k = length(labels); space = 0.15 * ((1:k) - (k+1)/2);

clf, hold on, axis([0.5 12.5 -0.2 0.2])
for i=1:k
    index = 1+2*(i-1);
    errorbar((1:12)-space(i),T.(index),1.96*sqrt(T.(index+1)), ...
        'ok','CapSize',0,'MarkerFaceColor',colors{i})
end
plot([0.5 12.5],[0 0],'-k')
set(gca,'XTick',1:12,'XTickLabels',counts,'YTick',-0.2:0.1:0.2, ...
    'FontSize',20,'TickLabelInterpreter','latex'), xtickangle(45)
legend(labels,'box','off','FontSize',20,'Interpreter','latex','Location','NorthWest')
doSave(filename)

end
