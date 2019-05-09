clc
close all
clear
results_path = [pwd,filesep,'output/'];
% results_path = [pwd, filesep];
names = dir([results_path, 'damage*.mat']);

figure
hold on

yend = [];

for file = names'
    load([file.folder, filesep, file.name]);
    %     plot(x, y, '-o', 'MarkerSize', 1, 'LineWidth', 1);
    plot(x, y, '-', 'LineWidth', 0.5);
    yend(end+1) = y(end);
    
end

save('randomdamage.mat','yend')
ylabel('Damage');
xlabel('Number of cycles');

box on
grid on

filename = 'output/temporal_scheme_3_1.tex';
cleanfigure;
saveas(gcf, filename(1:end-4), 'epsc')
matlab2tikz('figurehandle', gcf, 'filename', filename, 'standalone', true);
close

return
%% convergence graph
clc
clear
close all
load('randomdamage.mat')
rng(0)

cummean = [];
cumvar = [];
cumstd = [];
for i = 2:length(yend)
    sumcummean = 0;
    sumcumvar = 0;
    sumcumstd = 0;
    for j=1:length(yend)
        sumcummean = sumcummean + mean(yend(randperm(length(yend),i)));
        sumcumvar = sumcumvar + var(yend(randperm(length(yend),i)));
        sumcumstd = sumcumstd + std(yend(randperm(length(yend),i)));
    end
    cummean(i-1) = sumcummean / length(yend);
    cumvar(i-1) = sumcumvar / length(yend);
    cumstd(i-1) = sumcumstd / length(yend);
end
save()

%%
close all
load('matlab.mat');

figure
plot(cummean)
figure
plot(cumvar)
figure
plot(cumstd)

figure
number_of_realisations = 2:length(yend);
subplot(2, 1, 1);
plot(number_of_realisations,cummean)
ylabel('Mean(D_f^r)');
xlabel('Number of realisations');
box on
grid on
subplot(2, 1, 2);
plot(number_of_realisations,cumstd)
ylabel('Std(D_f^r)');
xlabel('Number of realisations');
box on
grid on

% filename = 'output/temporal_scheme_3_2.tex';
% cleanfigure;
% saveas(gcf, filename(1:end-4), 'epsc')
% matlab2tikz('figurehandle', gcf, 'filename', filename, 'standalone', true);
% close

mean(yend) + 3*std(yend)
mean(yend) - 3*std(yend)

mean(yend)
std(yend)
input_load=[53e-4,56e-4];
mean(input_load)
std(input_load)

estimated_standard_error = std(yend) / sqrt(length(yend))

%%
load('randomdamage.mat')
figure
histogram(yend')

figure
histfit(yend', 10, 'tlocationscale')

pd = makedist('tLocationScale', 'mu', 0.016278181446749, 'sigma', 0.000170922098608, 'nu', 1.640181896399759)
x = 0.0156:0.00001:max(yend);
y = pdf(pd, x);
plot(x, y)

pd = fitdist(yend', 'Weibull');
x = 0.0156:0.0001:max(yend);
y = pdf(pd, x);
plot(x, y);



[D, PD] = allfitdist(yend', 'PDF');
D(1)
fprintf('%10s\t', D(1).ParamNames{:});
fprintf('\n');
fprintf('%10.8f\t', D(1).Params);
fprintf('\n');

% variance convergence criterion?

% probplot(yend)
% probplot('weibull',yend)
% pdf(yend)

randperm 

