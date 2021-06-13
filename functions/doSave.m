function [] = doSave(filename)
% uses the export_fig function to save the file
%   filename: string name of file

addpath('functions/export_fig/'), s = getParams;

axis square, box on
set(gcf,'Position',[1551 575 713 563])
set(gca,'LooseInset',get(gca,'TightInset'))
set(gcf, 'Color', 'w')
export_fig([s.figdir,filename,'.png'],'-png','-native')

end

