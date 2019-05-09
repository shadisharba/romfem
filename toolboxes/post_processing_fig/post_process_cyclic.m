% clear
% directory = {'rsvd_qr','svd_m5_50step','svds_full'};
% for i=1:length(directory)
%     ddd = directory{i};
%     post_process_cyclic
% end

%% clc
close all
clear
results_path = [pwd, filesep, 'output/'];
names = dir([results_path, '*/qoi.mat']);

%% plot the time functions
time_function = [];
time_function_sum = [];
for file = names'
    load([file.folder, filesep, file.name]);
    time_function = [time_function, nan,(global_fields.temporal_modes(1, :))]; %f.Val(1:end-1)
    time_function_sum = [time_function_sum,nan, sum(global_fields.temporal_modes, 1)]; %f.Val(1:end-1)
    %     time_function=[time_function;obj_to_save.results{1}.primal.u{2}(:,1)]; %f.Val(1:end-1)
end
% time_function=[time_function,f.Val(end)];
plot(time_function);
figure
plot(time_function_sum);
ylabel('Amplitude');
xlabel('Number of cycles');
% title('The first time function over all cycles');
xticks([0:32:384]);
xticklabels(0:12)
xlim([0, length(time_function)])
% title('macro-time discretisation');
box on
grid on
print(gcf, [results_path, filesep, 'time_modes'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'time_modes'])

%%
figure
load([results_path, 'damage.mat'])
plot(x, y, '-o', 'MarkerSize', 2, 'LineWidth', 1);
box on
grid on
ylabel('Damage');
xlabel('Number of cycles');
% title('Damage evolution w.r.t. number of cycles');
print(gcf, [results_path, filesep, 'damage_evolution'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'damage_evolution'])

figure
bar(x(1:end-1), diff(y));
box on
grid on
print(gcf, [results_path, filesep, 'damage_increment'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'damage_increment'])

figure
n_iter = [];
n_modes = [];
% n_modes_hardening = [];
for file = names'
    load([file.folder, filesep, file.name]);
    indic(1, 1) = 1;
    loglog(indic(:, 1))
    hold on
    n_modes = [n_modes, obj_to_save.results{1}.number_of_modes(end)];
    %     n_modes_hardening = [n_modes_hardening, obj_to_save.results{2}.number_of_modes(end)];
    n_iter = [n_iter, size(indic, 1)];
end
ylabel('Error indicator');
xlabel('Number of iterations');
% title('Error indicator w.r.t. number of iterations for all nodal cycles');
box on
grid on
hold off
print(gcf, [results_path, filesep, 'error_indicator'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'error_indicator'])

figure
bar(n_iter)
ylabel('Number of iterations');
xlabel('Number of cycles');
% title('Number of iteration for all computed cycles');
box on
grid on
hold off
print(gcf, [results_path, filesep, 'number_of_iterations'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'number_of_iterations'])

figure
bar(n_modes)
ylabel('Number of PGD modes');
xlabel('Number of cycles');
% title('Number of PGD modes in each cycle');
box on
grid on
hold off
print(gcf, [results_path, filesep, 'number_of_pgd_modes'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'number_of_pgd_modes'])

% modes of the last cycle [after time update so no diagonal appears here]
U = obj_to_save.results{1}.V * obj_to_save.results{1}.time_mode;
[space_mode_svd, singular_values_svd, ~] = svds(U, obj_to_save.results{1}.number_of_modes(end));
inner_product_space = abs(obj_to_save.results{1}.V'*space_mode_svd);
inner_product_space = inner_product_space / max(inner_product_space(:));

figure
im = imagesc(inner_product_space);
set(gca, 'Ydir', 'Normal') % 'reverse'
% im.AlphaData = .3;
colormap(flipud(gray))
colorbar
hold on

%% Custom grid lines
grid_spacing = 0.5:size(inner_product_space, 1) + 0.5;
grid_limits = [0.5; size(inner_product_space, 1) + 0.5];
y_grid = repmat(grid_limits, 1, numel(grid_spacing));
x_grid = [grid_spacing; grid_spacing];
plot(x_grid, y_grid, 'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.01);
plot(y_grid, x_grid, 'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.01);
ylabel('PGD spatial mode number');
xlabel('Reference SVD spatial mode number');
% title('Inner product of spatial modes');
hold off
% spy(modes) % surf(inner_product_time)
print(gcf, [results_path, filesep, 'modes_optimality'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'modes_optimality'])

singular_values_svd = diag(singular_values_svd) / singular_values_svd(1);
figure
semilogy(singular_values_svd);
grid on
ylabel('Normalised singular values');
xlabel('Number of singular values');
% title('Singular values decay');
xlim([1, length(singular_values_svd)]);
print(gcf, [results_path, filesep, 'singular_values_decay'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'singular_values_decay'])

% projection
activation_coeifficients = abs(sum(obj_to_save.results{1}.V'*U, 2));
activation_coeifficients = activation_coeifficients / max(activation_coeifficients);
figure
semilogy(activation_coeifficients);
grid on
xlabel('Number of spatial modes');
ylabel('Normalised activation coefficients');
% title('Spatial modes activation coefficients');
xlim([1, length(singular_values_svd)]);
print(gcf, [results_path, filesep, 'activation_coefficients'], '-dpng'); % ,'-r300'
saveas(gcf, [results_path, filesep, 'activation_coefficients'])

close all

% figure
% bar(n_modes_hardening)
% ylabel('Number of PGD modes');
% xlabel('Number of nodal cycles');
% title('Number of hardening PGD modes in each nodal cycle');
% box on
% grid on
% hold off

% %% check this
% macro = diff(x);
% macro = macro(2:end);
% bar(macro)
% ylabel('The size of the time element');
% xlabel('Number of nodal cycles');
% title('macro-time discretisation');
% box on
% grid on
% hold off
%
% % obj_to_save.results{1}.number_of_modes(1)=[];
% % loglog(obj_to_save.results{1}.number_of_modes,indic(:,1))
% % n_iter = size(indic,1);
%
% % matlab2tikz('figurehandle',gcf,'filename','/home/alameddin/src/tex/templates/tex_figures/newfig/error_12cycles.tex' ,'standalone', true);
%
% %%
% % function [outputArg1, outputArg2] = plot_damage(inputArg1, inputArg2)
% %
% % % TODO: coul be deleted _ ploting the figure at each cycle
% % fileID = fopen('output/D.bin', 'r');
% % D_total = fread(fileID, 'double');
% % fclose all;
% % D_total = reshape(D_total, [mesh.quadrature_local_coordinates_id{end}(end), length(D_total) / mesh.quadrature_local_coordinates_id{end}(end)]);
% % figure('Visible', 'off', 'Renderer', 'painters', 'units', 'normalized', 'outerposition', [0, 0, 1, 1]); %'units','normalized'
% % plot(linspace(0, size(D_total, 2)/steps_per_sec/period, size(D_total, 2)), D_total');
% % print(gcf, sprintf('%s/damage', R.solver.parameters.output_path), '-dpng'); % ,'-r300'
% % close(gcf);
% % end
%
% plot stress-strain curve
%%
% use solver_parameters.max_iter = 1; to get continious cycles

close all
clear
results_path = [pwd, filesep, 'output/'];
names = dir([results_path, '*/qoi.mat']);

figure
id = 148;
% [~, id] = max(global_fields.internal_damage(:, end));
s1=[];
s2=[];
for file = names'
    load([file.folder, filesep, file.name]);
    for i=3 %0:5
        plot(global_fields.strain(id*6-i,:),global_fields.stress(id*6-i,:));
        s1 = [s1,global_fields.strain(id*6-i,:)];
        s2 = [s2,global_fields.stress(id*6-i,:)];
        hold on
    end
end

% % ylabel('Stress');
% % xlabel('Strain');
% % title('Stress-Strain curve');
% % box on
% % grid on
% %     legend(axes1,'show');
% % hold off
%
% for file = names'
%     load([file.folder, filesep, file.name]);
%     for i = 3 %0:5
%         plot(obj_to_save.results{1}.primal(id*6-i, :), obj_to_save.results{1}.dual(id*6-i, :));
%         hold on
%     end
% end
%
%
% %     plot(X1,Y1,'DisplayName','First cycle','LineWidth',1);
% %     plot(obj_to_save.results{1}.eps(id*6-3,:),obj_to_save.results{1}.dual(id*6-3,:));
% % hold on
% %     plot(obj_to_save.results{1}.eps(3,:),obj_to_save.results{1}.dual(3,:));
%
% return
%
% %% plot the applied load
% val = [];
% for f = force
%     val = [val, f.Val(1:end-1)];
% end
% val = [val, f.Val(end)];
% plot(linspace(0, 120, length(val)), val);
% box on
% grid on
% ylabel('Displacement (mm)');
% xlabel('Time (sec)');
% % title('Damage evolution w.r.t. number of cycles');

%%
close all
clear
results_path = [pwd, filesep, 'output/'];
names = dir([results_path, '*/qoi.mat']);

figure
id = 148;
% [~, id] = max(global_fields.internal_damage(:, end));
D=[];
for file = names'
    load([file.folder, filesep, file.name]);
    D=[D,global_fields.internal_damage(id,:)];
end
plot(D)