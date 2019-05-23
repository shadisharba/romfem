add_folder_to_path

clc
clear
save_figure = false;
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = one_cycle('any');

names = dir('*.mat');
for file = names'
    load(file.name);
end

[~, idx] = max(nr_solution(end).results.internal_damage(:, end));
% idx = 148; id6 = 885;
id6 = idx * 6 - 3;

%% load and temporal domain
applied_load = cell2mat({user_load(:).magnitude});
tempoal_domain = [0, diff(cell2mat({user_load(:).temporal_mesh}))];
tempoal_domain(tempoal_domain < 0) = 0;
tempoal_domain = cumsum(tempoal_domain);
% numElements = arrayfun(@(x) numel(x.f), s)
% struct2cell()
% c = cellfun(@(fn) all.(fn).field1, fieldnames(all), 'UniformOutput', false);
% vertfield1 = vertcat(c{:});

%% NR
results = [nr_solution(:).results];
for field = fieldnames(results)'
    nr.(field{:}) = cell2mat({results.(field{:})});
end

%% LATIN
results = [latin_solution(:).results];
for field = fieldnames(results)'
    if ~strcmp(field,'temporal_modes') && ~strcmp(field,'strain_spatial_modes') && ~strcmp(field,'displacement_spatial_modes') && ~strcmp(field,'err_indicator')
        latin.(field{:}) = cell2mat({results.(field{:})});
    end
end
diary('output/speedup.txt')
fprintf('NR : %e,\t latin : %e, \t speedup %e \n', nr_timing, latin_timing, nr_timing/latin_timing);
diary('off')

%% NR_POD
results = [nr_pod_solution(:).results];
for field = fieldnames(results)'
    nr_pod.(field{:}) = cell2mat({results.(field{:})});
end

%% set solutions
solution1 = nr;
% solution2 = nr_pod;
solution2 = latin;

damage1 = solution1.internal_damage(idx, :);
damage2 = solution2.internal_damage(idx, :);
stress1 = solution1.stress(id6, :);
stress2 = solution2.stress(id6, :);
strain1 = solution1.strain(id6, :);
strain2 = solution2.strain(id6, :);

%% plot load
figure
plot(tempoal_domain, applied_load, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', 'black');
ylabel('Prescribed displacement (mm)');
xlabel('Time (sec)');
saveastex('output/temporal_scheme_1_1.tex', save_figure)

%% displacement error and load cycles
figure
error = norm(solution1.displacement-solution2.displacement) / norm(solution1.displacement);
disp(error * 100)
plot(strain1, stress1)

%% plot damage and error
figure
% norm(nr_solution.results.internal_damage-latin_solution.results.internal_damage) % / norm(nr_solution.results.internal_damage)
% volume and time average?? 1/T 1/V integral integral ...

subplot(5, 1, [1, 2]);
plot(tempoal_domain, damage1, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', 'black', 'DisplayName', 'HFM');
hold on
plot(tempoal_domain, damage2, 'Marker', '*', 'LineWidth', 1, 'LineStyle', '--', 'Color', 'red', 'DisplayName', 'ROM');
ylabel('Damage');
xlabel('Time (sec)');
legend
box on; grid on; hold off

subplot(5, 1, 3);
err = abs(damage1-damage2) ./ damage1;
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error (%)');
xlabel('Time (sec)');
box on; grid on; hold off

subplot(5, 1, 4);
err = abs(stress1-stress2) / norm(stress1);
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error (%)');
xlabel('Time (sec)');
title('stress');
box on; grid on; hold off

subplot(5, 1, 5);
err = abs(strain1-strain2) / norm(strain1);
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error (%)');
xlabel('Time (sec)');
title('strain');
box on; grid on; hold off
saveastex('output/temporal_scheme_1_2.tex', save_figure)

%% plot number of modes
figure
bar(n_modes)
ylabel('Number of PGD modes');
xlabel('Number of cycles');
saveastex('output/temporal_scheme_1_3.tex', save_figure)

%% plot error indicator
figure
for i = 1:length(user_load)
    semilogy(latin_solution(i).results.err_indicator./latin_solution(i).results.err_indicator(1), 'DisplayName', sprintf('Cycle %d', i));
    % TODO: indic(1, 1) = 1;
    hold on
end
legend
ylabel('Normalised error indicator');
xlabel('Number of iterations');
saveastex('output/temporal_scheme_1_4.tex', save_figure)

%% plot energy
clc
close all
load('matlab.mat', 'numerical_model_obj');

solution2 = latin;

damage = solution2.internal_damage;
stress = solution2.stress;
strain = solution2.strain;
back_stress = solution2.back_stress;
isotropic_hardening = solution2.isotropic_hardening;
 
material = numerical_model_obj.material;
elastic_strain = compute_elastic_strain(stress, material.inv_elasticity_tensor_diagonal, repelem(damage, 6, 1));
free_energy = 0.5 * double_dot_product(stress, elastic_strain) + ...
    material.user_material.c / 2 * double_dot_product(compute_internal_kinematic(material,back_stress), compute_internal_kinematic(material,back_stress)) + ...
    material.user_material.r_inf * (isotropic_hardening + exp(-material.user_material.r_exp * isotropic_hardening)/material.user_material.r_exp);
% surf(free_energy)
subplot(4,1,1)
plot(free_energy(885,:))

[equivalent_apparent_stress, deviatoric_apparent_stress, equivalent_stress] = compute_equivalent_stress(stress, back_stress, repelem(damage, 6, 1));
dissipation = max(0, equivalent_apparent_stress-isotropic_hardening-material.user_material.sigma_y) + ...
    material.user_material.a / (2*material.user_material.c) * double_dot_product(back_stress, back_stress) + ...
    material.user_material.S / (material.user_material.s+1) * (((compute_energy_release_rate(stress, material.inv_elasticity_tensor_diagonal, damage) ./ material.user_material.S).^(material.user_material.s+1)) ./ (1 - damage));
% surf(dissipation)
subplot(4,1,2)
plot(dissipation(885,:))

subplot(4,1,3)
plot(cumsum(dissipation(885,:)))

subplot(4,1,4)
plot(damage(148,:))
