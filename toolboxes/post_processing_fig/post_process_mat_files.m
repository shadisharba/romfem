add_folder_to_path

clc
clear
close all

save_figure = true;

[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = one_cycle('any');
% load and temporal domain
applied_load = cell2mat({user_load(:).magnitude});
tempoal_domain = [0, diff(cell2mat({user_load(:).temporal_mesh}))];
tempoal_domain = cumsum(subplus(tempoal_domain)); % tempoal_domain < 0 -> 0

% results_path = uigetdir('output/');
% results_path = [results_path,filesep];
results_path = [pwd, filesep, 'output/'];
names = dir([results_path, '*/qoi.mat']);

%% plot load
figure
plot(tempoal_domain, applied_load, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', 'black');
ylabel('Prescribed displacement (mm)');
xlabel('Time (sec)');
saveastex('output/prescribed_displacement.tex', save_figure)

%% temporal functions [all cycles on one figure]
temporal_functions = cell(1, length(names));
counter = 1;
for file = names'
    load([file.folder, filesep, file.name]);
    temporal_functions{counter} = global_fields.temporal_modes;
    temporal_functions{counter+1} = nan;
    counter = counter + 2;
end
[rows, ~] = cellfun(@size, temporal_functions, 'UniformOutput', false);
max_rows = max(cell2mat(rows));
for counter = 1:size(temporal_functions, 2)
    % zero padding
    temporal_functions{counter} = padarray(temporal_functions{counter}, max_rows-size(temporal_functions{counter}, 1), 'post');
end
temporal_functions_mat = cell2mat(temporal_functions);
plot(temporal_functions_mat(1, :));
ylabel('Amplitude');
xlabel('Time (sec)');
saveastex('output/first_temporal_mode.tex', save_figure)

figure
plot(sum(temporal_functions_mat, 1));
ylabel('Amplitude');
xlabel('Time (sec)');
saveastex('output/sum_temporal_modes.tex', save_figure)

%% plot damage [all cycles on one figure w.r.t number of cycles]
figure
damage_file = dir([results_path, 'damage*.mat']);
load([results_path, damage_file.name])
plot(x, y, '-o', 'MarkerSize', 2, 'LineWidth', 1);
ylabel('Damage');
xlabel('Number of cycles');
saveastex('output/damage_evolution.tex', save_figure)

figure
bar(x(1:end-1), diff(y));
saveastex('output/damage_increment.tex', save_figure)

%% number of modes, iterations and error indicator [all cycles on one figure]
n_iter = zeros(length(names), 1);
n_modes = zeros(length(names), 1);
figure
for saved_cycle = 1:length(names)
    load([names(saved_cycle).folder, filesep, names(saved_cycle).name]);
    % err_indicator(1) = 1;
    semilogy(err_indicator./err_indicator(1), 'DisplayName', sprintf('Cycle %d', saved_cycle))
    hold on
    n_modes(saved_cycle) = global_fields.number_of_modes(end);
    n_iter(saved_cycle) = length(err_indicator);
end
ylabel('Normalised error indicator');
xlabel('Number of iterations');
saveastex('output/error_indicator.tex', save_figure)

figure
bar(n_iter)
ylabel('Number of iterations');
xlabel('Number of cycles');
saveastex('output/number_of_iterations.tex', save_figure)

figure
bar(n_modes)
ylabel('Number of PGD modes');
xlabel('Number of cycles');
saveastex('output/number_of_pgd_modes.tex', save_figure)

%% plot damage [all cycles on one figure w.r.t time]
damage = [];
for saved_cycle = 1:length(names)
    load([names(saved_cycle).folder, filesep, names(saved_cycle).name]);
    idx = 148;
    id6 = idx * 6 - 3;
    element_id_vtk = floor(idx/8); % vtk is numbered from zero
    % [~, id] = max(global_fields.internal_damage(:, end));
    damage = [damage, global_fields.internal_damage(idx, :)];
end
figure
plot(damage)
ylabel('Damage');
xlabel('Time (sec)');
saveastex(sprintf('output/stress_strain_%d.tex', saved_cycle), save_figure)

%% stress-strain curve [each cycle on a new figure]
% use solver_parameters.max_iter = 1; to get continious cycles
for saved_cycle = 1:length(names)
    load([names(saved_cycle).folder, filesep, names(saved_cycle).name]);
    figure
    id6 = idx * 6 - 3;
    for i = 3 % 0:5
        plot(global_fields.strain(id6, :), global_fields.stress(id6, :));
        hold on
    end
    ylabel('stress (MPa)');
    xlabel('strain');
    saveastex(sprintf('output/stress_strain_%d.tex', saved_cycle), save_figure)
end

%% spatial and temporal functions [each cycle on a new figure]
colors = [1, 0, 0; ...
    .6, 0, 0; ...
    .3, 0, 0; ...
    .5, .5, .5; ...
    .3, .3, .3; ...
    1, 1, 1; ...
    0, .6, 0; ...
    0, 1, 0; ...
    0, .3, 0; ...
    0, 0, 1; ...
    0, 0, .6; ...
    0, 0, .3];
for saved_cycle = 1:length(names)
    load([names(saved_cycle).folder, filesep, names(saved_cycle).name]);
    figure
    current_number_of_modes = size(global_fields.strain_spatial_modes, 2);
    for current_pair = 1:current_number_of_modes
        subplot(2, current_number_of_modes, current_pair)
        plot(global_fields.temporal_modes(current_pair, :));
        subplot(2, current_number_of_modes, current_pair+current_number_of_modes)
        siz = size(global_fields.strain_spatial_modes(:, current_pair));
        imagesc(reshape(global_fields.strain_spatial_modes(:, current_pair), 6, siz(1)/6)', [min(global_fields.strain_spatial_modes(:)), max(global_fields.strain_spatial_modes(:))]);
        colormap(colors)
        colorbar
        % colormap(lines(8)) % gray
        %     colormap(linspecer(12,'qualitative'))
    end
    saveastex(sprintf('output/spatial_and_temporal_modes_%d.tex', saved_cycle), save_figure)
end

%% Modal optimisation of the [strain spatial modes] of any cycle
% load any of the "qoi.mat" files
[file, path] = uigetfile('output/*qoi.mat');
load(fullfile(path, file), 'global_fields');
strain = global_fields.strain_spatial_modes * global_fields.temporal_modes;
[spatial_modes_svd, singular_values_svd, ~] = svds(strain, size(global_fields.strain_spatial_modes, 2));
inner_product_spatial_modes = abs(global_fields.strain_spatial_modes'*spatial_modes_svd);
inner_product_spatial_modes = inner_product_spatial_modes / max(inner_product_spatial_modes(:));

figure
im = imagesc(inner_product_spatial_modes);
set(gca, 'Ydir', 'Normal') % 'reverse'
% im.AlphaData = .3;
colormap(flipud(gray))
colorbar
hold on
% Custom grid lines
grid_spacing = 0.5:size(inner_product_spatial_modes, 1) + 0.5;
grid_limits = [0.5; size(inner_product_spatial_modes, 1) + 0.5];
y_grid = repmat(grid_limits, 1, numel(grid_spacing));
x_grid = [grid_spacing; grid_spacing];
plot(x_grid, y_grid, 'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.01);
plot(y_grid, x_grid, 'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.01);
ylabel('PGD spatial mode number');
xlabel('Reference SVD spatial mode number');
hold off
saveastex('output/modes_optimality.tex', save_figure)
% spy(inner_product_spatial_modes)

singular_values_svd = diag(singular_values_svd) / singular_values_svd(1);
figure
semilogy(singular_values_svd);
ylabel('Normalised singular values');
xlabel('Number of singular values');
xlim([1, length(singular_values_svd)]);
saveastex('output/singular_values_decay.tex', save_figure)

% singular values decay of sum_residual
[spatial_modes_svd, singular_values_svd, ~] = svds(global_fields.sum_residual, size(global_fields.sum_residual, 2));
singular_values_svd = diag(singular_values_svd) / singular_values_svd(1);
figure
semilogy(singular_values_svd);
ylabel('Normalised singular values');
xlabel('Number of singular values');
xlim([1, length(singular_values_svd)]);
saveastex('output/singular_values_decay_sum_residual.tex', save_figure)

%% modes activation coeifficients over the whole time interval (of a cycle)
% activation_coeifficients = abs(sum(global_fields.temporal_modes,2));
activation_coeifficients = abs(sum(global_fields.strain_spatial_modes'*strain, 2));
activation_coeifficients = activation_coeifficients / max(activation_coeifficients);
figure
semilogy(activation_coeifficients);
grid on
xlabel('Number of spatial modes');
ylabel('Normalised activation coefficients');
xlim([1, length(singular_values_svd)]);
saveastex('output/activation_coefficients.tex', save_figure)

%% compare spatial modes of two different cycles
[file, path] = uigetfile('output/*qoi.mat');
sol = load(fullfile(path, file));
cycle1 = sol.global_fields;

[file, path] = uigetfile('output/*qoi.mat');
sol = load(fullfile(path, file));
cycle2 = sol.global_fields;

inner_product_spatial_modes = abs(cycle1.strain_spatial_modes'*cycle2.strain_spatial_modes);
figure
im = imagesc(inner_product_spatial_modes);
set(gca, 'Ydir', 'Normal') % 'reverse'
% im.AlphaData = .3;
colormap(flipud(gray))
colorbar

%% plot energy
[file, path] = uigetfile('output/*qoi.mat');
sol = load(fullfile(path, file));
load('/home/alameddin/src/romfem/output/numerical_model.mat')

material = numerical_model_obj.material;
damage = sol.global_fields.internal_damage;
stress = sol.global_fields.stress;
strain = sol.global_fields.strain;
back_stress = sol.global_fields.back_stress;
isotropic_hardening = sol.global_fields.isotropic_hardening;

idx = 148;
id6 = idx * 6 - 3;

elastic_strain = compute_elastic_strain(stress, material.inv_elasticity_tensor_diagonal, repelem(1-damage, 6, 1));
free_energy = 0.5 * double_dot_product(stress, elastic_strain) + ...
    material.user_material.c / 2 * double_dot_product(compute_internal_kinematic(material, back_stress), compute_internal_kinematic(material, back_stress)) + ...
    material.user_material.r_inf * (isotropic_hardening + exp(-material.user_material.r_exp*isotropic_hardening) / material.user_material.r_exp);
% surf(free_energy)
subplot(4, 1, 1)
plot(free_energy(id6, :))

[equivalent_apparent_stress, deviatoric_apparent_stress, equivalent_stress] = compute_equivalent_stress(stress, back_stress, repelem(1-damage, 6, 1));
dissipation = max(0, equivalent_apparent_stress-isotropic_hardening-material.user_material.sigma_y) + ...
    material.user_material.a / (2 * material.user_material.c) * double_dot_product(back_stress, back_stress) + ...
    material.user_material.S / (material.user_material.s + 1) * (((compute_energy_release_rate(stress, material.inv_elasticity_tensor_diagonal, damage) ./ material.user_material.S).^(material.user_material.s + 1)) ./ (1 - damage));
% surf(dissipation)
subplot(4, 1, 2)
plot(dissipation(id6, :))

subplot(4, 1, 3)
plot(cumsum(dissipation(id6, :)))

subplot(4, 1, 4)
plot(damage(idx, :))