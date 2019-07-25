add_folder_to_path

clc
clear
close all

save_figure = true;

[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode] = input_verify('any');
% load and temporal domain
applied_load = cell2mat({user_load(:).magnitude});
tempoal_domain = [0; diff(cell2mat({user_load(:).temporal_mesh}'))];
tempoal_domain = cumsum(subplus(tempoal_domain)); % tempoal_domain < 0 -> 0

% results_path = uigetdir('output/nr');
results_path = 'output/nr';
names1 = dir([results_path, filesep, '*/qoi.mat']);
results_path = 'output/latin';
names2 = dir([results_path, filesep, '*/qoi.mat']);
assert(length(names1) == length(names2))

load('output/numerical_model.mat')

%% plot damage [all cycles on one figure w.r.t time]
damage1 = [];
damage2 = [];
error_damage = zeros(length(names1), 1);
error_stress = zeros(length(names1), 1);
error_strain = zeros(length(names1), 1);

for saved_cycle = 1:length(names1)
    solution1 = load([names1(saved_cycle).folder, filesep, names1(saved_cycle).name]);
    solution2 = load([names2(saved_cycle).folder, filesep, names2(saved_cycle).name]);
    idx = 148;
    id6 = idx * 6 - 3;
    element_id_vtk = floor(idx/8); % vtk is numbered from zero
    % [~, id] = max(global_fields.internal_damage(:, end));
    damage1 = [damage1, solution1.global_fields.internal_damage(idx, :)];
    damage2 = [damage2, solution2.global_fields.internal_damage(idx, :)];

    % Volume = sum(numerical_model_obj.mesh.integration_coefficient(:))/6;
    % T = user_load(saved_cycle).temporal_mesh(end);
    nrm_scalar_field = @(x) sqrt(sum(temporal_integration(numerical_model_obj.mesh.integration_coefficient(1:6:end, 1:6:end)*x.^2, numerical_model_obj.temporal)));

    error_damage(saved_cycle) = nrm_scalar_field(solution1.global_fields.internal_damage-solution2.global_fields.internal_damage) / nrm_scalar_field(solution1.global_fields.internal_damage) * 100;

    nrm = @(x) sqrt(sum(temporal_integration(double_dot_product(x, spatial_integration(x, numerical_model_obj.mesh)), numerical_model_obj.temporal)));

    error_stress(saved_cycle) = nrm(solution1.global_fields.stress-solution2.global_fields.stress) / nrm(solution1.global_fields.stress) * 100;

    error_strain(saved_cycle) = nrm(solution1.global_fields.strain-solution2.global_fields.strain) / nrm(solution1.global_fields.strain) * 100;
end

figure
subplot(3, 1, [1, 2]);
plot(tempoal_domain, damage1, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', 'black', 'DisplayName', 'HFM');
hold on
plot(tempoal_domain, damage2, 'Marker', '*', 'LineWidth', 1, 'LineStyle', '--', 'Color', 'red', 'DisplayName', 'ROM');
ylabel('Damage');
xlabel('t [s]');
legend
box on; grid on; hold off

subplot(3, 1, 3);
err = abs(damage1-damage2) ./ damage1;
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error [%]');
xlabel('t [s]');
box on; grid on; hold off
saveastex('output/damage_comparison.tex', save_figure)

figure
subplot(3, 1, 1);
bar(error_damage)
ylabel('Relative error [%]');
xlabel('Number of cycles');
title('damage');
box on; grid on; hold off

subplot(3, 1, 2);
bar(error_stress)
ylabel('Relative error [%]');
xlabel('Number of cycles');
title('stress');
box on; grid on; hold off

subplot(3, 1, 3);
bar(error_strain)
ylabel('Relative error [%]');
xlabel('Number of cycles');
title('strain');
box on; grid on; hold off
saveastex('output/error_space_time.tex', save_figure)
