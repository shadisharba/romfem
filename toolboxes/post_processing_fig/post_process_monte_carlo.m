clc
clear
close all
results_path = [pwd,filesep,'output/'];
names = dir([results_path, 'damage*.mat']);

figure
hold on

yend = zeros(length(names),1);
counter = 1;

for file = names'
    load([file.folder, filesep, file.name]);
    % plot(x, y, '-o', 'MarkerSize', 1, 'LineWidth', 1);
    plot(x, y, '-', 'LineWidth', 0.5);
    yend(counter) = y(end);
    counter = counter + 1;    
end

save([results_path,'randomdamage.mat'],'yend')

ylabel('Damage');
xlabel('Number of cycles');
saveastex('output/temporal_scheme_3_1.tex', true)

return
%% convergence graph
clc
load([results_path,'randomdamage.mat'])
rng(0)

number_of_items = length(yend);
cummean = zeros(number_of_items-1,1);
cumvar = zeros(number_of_items-1,1);
cumstd = zeros(number_of_items-1,1);
estimated_standard_error = zeros(number_of_items-1,1);
for item = 2:number_of_items
    combinations = factorial(number_of_items)/(factorial(item)*factorial(number_of_items-item)); % number_of_items % 1
    sumcummean = 0;
    sumcumvar = 0;
    sumcumstd = 0;
    for combination = 1:combinations
        sumcummean = sumcummean + mean(yend(randperm(number_of_items,item)));
        sumcumvar = sumcumvar + var(yend(randperm(number_of_items,item)));
        sumcumstd = sumcumstd + std(yend(randperm(number_of_items,item)));
    end
    cummean(item-1) = sumcummean / combinations;
    cumvar(item-1) = sumcumvar / combinations;
    cumstd(item-1) = sumcumstd / combinations;
    estimated_standard_error(item-1) = cumstd(item-1) / sqrt(item);
end
save([results_path,'randomdamage_convergence.mat'])

%%
clc
close all
load([results_path,'randomdamage_convergence.mat'])

figure
plot(cummean)
figure
plot(cumvar)
figure
plot(cumstd)
figure
plot(estimated_standard_error)

figure
number_of_realisations = 2:number_of_items;
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

saveastex('output/temporal_scheme_3_2.tex', true)

fprintf('mean + 3 std = %e \n',mean(yend) + 3*std(yend));
fprintf('mean - 3 std = %e \n',mean(yend) - 3*std(yend));
fprintf('mean = %e \n',mean(yend));
fprintf('std = %e \n',std(yend));

input_load=[53e-4,56e-4];
% can't be related to the output because it might be zeor
fprintf('mean input = %e \n',mean(input_load));
fprintf('std input = %e \n',std(yend));
fprintf('estimated standard error = %e \n',std(yend) / sqrt(number_of_items));

%% fit a distribution
load([results_path,'randomdamage.mat'])

figure
histogram(yend)

fileID = fopen([results_path,'damage_values.txt'],'w');
fprintf(fileID,'%8.8f\n',yend);
fclose(fileID);    

% Main_FitDistribution_GUI

[D, PD] = allfitdist(yend, 'PDF');
D(1)
fprintf('%10s\t', D(1).ParamNames{:});
fprintf('\n');
fprintf('%10.8f\t', D(1).Params);
fprintf('\n');

figure
histfit(yend, 10, 'tlocationscale')

% pd = makedist('tLocationScale', 'mu', 0.016278181446749, 'sigma', 0.000170922098608, 'nu', 1.640181896399759)
% x = 0.0156:0.00001:max(yend);
% y = pdf(pd, x);
% plot(x, y)
% 
% pd = fitdist(yend, 'Weibull');
% x = 0.0156:0.0001:max(yend);
% y = pdf(pd, x);
% plot(x, y);

% % probability plot
% probplot(yend)
% probplot('weibull',yend)