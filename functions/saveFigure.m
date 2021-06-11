function [] = saveFigure(filename,box1,box2,type)
% completes and saves figure
%   filename: string name of file
%   box1: edges of strike zone to plot, horizontal axis
%   box2: edges of strike zone to plot, vertical axis
%   type: one of 'density','example','zoom','error', or 'objfun'

%% strike zone rectangle

if ~isempty(box1)
    h1 = plot(box1,box2,'--k');
elseif ~ismember(type,{'error','objfun'})
    h1 = plot([-8.5; -8.5; 8.5; 8.5; -8.5],[-11; 11; 11; -11; -11],'--k');
end
if exist('h1','var')
    set(get(get(h1,'Annotation'),'LegendInformation'), ...
        'IconDisplayStyle','off');
end

%% ticks and axis labels

xlab = 'Inches from midline of home plate';
ylab = 'Inches from vertical midline';
switch type
    case 'density'
        ticks = -20:5:20; axis([-20 20 -20 20])
    case 'example'
        ticks = 0:5:15; axis([0 15 0 15])
    case 'zoom'
        ticks = -15:5:15; axis([-15 15 -15 15])
    case 'error'
        axis([0.1 5 0.1 5]), ticks = 1:5;
        xlab = '$\sigma_1$'; ylab = '$\sigma_2$';
    case 'objfun'
        axis([1 5 1 5]), ticks = 1:5;
        xlab = '$\hat{\sigma}_1$'; ylab = '$\hat{\sigma}_2$';
end
xlabel(xlab,'FontSize',20,'Interpreter','latex')
ylabel(ylab,'FontSize',20,'Interpreter','latex')
set(gca,'FontSize',20,'XTick',ticks,'YTick',ticks, ...
    'TickLabelInterpreter','latex')

%% save

doSave(filename)

end