clc
clear
close all

names = dir([pwd, filesep, '**/*.fig']);

disp('running');

for file = names'
    openfig([file.folder, filesep, file.name]);
    
    InSet = get(gca, 'TightInset');
    set(gca, 'Position', [InSet(1:2), 1 - InSet(1) - InSet(3), 1 - InSet(2) - InSet(4)]);
    
    parts = strsplit(file.folder, '/');
    
    saveas(gcf, [file.folder, filesep, parts{end-1}, '_', file.name(1:end-4)], 'epsc')
    
    system(['rm -rf ', ([file.folder, filesep, parts{end-1}, '_', file.name(1:end-4), '.tex'])])
    
    cleanfigure;
    
    matlab2tikz('figurehandle', gcf, 'filename', [file.folder, filesep, parts{end}, '_', file.name(1:end-4), '.tex'], 'standalone', true);
    
    system(['pdflatex ', ([file.folder, filesep, parts{end}, '_', file.name(1:end-4), '.tex'])])
    
    ! rm -rf *.log *.aux
    
    close
end
