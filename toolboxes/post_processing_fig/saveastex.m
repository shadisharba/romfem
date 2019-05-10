function saveastex(filename, save_figure)

if save_figure
    box on
    grid on
    hold off
    
    cleanfigure;
    saveas(gcf, filename(1:end-4), 'epsc')
    matlab2tikz('figurehandle', gcf, 'filename', filename, 'standalone', true);
    close
end

end
