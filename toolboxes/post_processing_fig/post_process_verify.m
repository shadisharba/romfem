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
err = abs(stress1-stress2) ./ stress1;
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error (%)');
xlabel('Time (sec)');
title('stress');
box on; grid on; hold off

subplot(5, 1, 5);
err = abs(strain1-strain2) ./ strain1;
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
