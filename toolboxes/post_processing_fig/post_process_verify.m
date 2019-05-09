clc
clear

[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = one_cycle('any');

load('nr_solution.mat');
load('latin_solution.mat');

diary('output/speedup.txt')
fprintf('NR : %e,\t latin : %e, \t speedup %e \n', nr_timing, latin_timing, nr_timing/latin_timing);
diary('off')

[~, idx] = max(nr_solution(end).results.internal_damage(:, end));
id6 = idx * 6 - 3;

nr_damage = [];
nr_stress = [];
nr_strain = [];
latin_damage = [];
latin_stress = [];
latin_strain = [];
tempoal_domain = [];
applied_load = [];
n_modes = [];
t0 = 0;
for i = 1:length(user_load)
    applied_load = [applied_load, user_load(i).magnitude];
    tempoal_domain = [tempoal_domain, t0 + user_load(i).temporal_mesh];
    t0 = tempoal_domain(end);
    nr_damage = [nr_damage, nr_solution(i).results.internal_damage(idx, :)];
    nr_stress = [nr_stress, nr_solution(i).results.stress(id6, :)];
    nr_strain = [nr_strain, nr_solution(i).results.strain(id6, :)];
    latin_damage = [latin_damage, latin_solution(i).results.internal_damage(idx, :)];
    latin_stress = [latin_stress, latin_solution(i).results.stress(id6, :)];
    latin_strain = [latin_strain, latin_solution(i).results.strain(id6, :)];
    n_modes = [n_modes, latin_solution(i).results.number_of_modes(end)];
end

%% plot damage and error
figure
% norm(nr_solution.results.internal_damage-latin_solution.results.internal_damage) % / norm(nr_solution.results.internal_damage)
% volume and time average?? 1/T 1/V integral integral ...
subplot(5, 1, [1, 2]);
plot(tempoal_domain, nr_damage, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', 'black', 'DisplayName', 'HFM');
hold on
plot(tempoal_domain, latin_damage, 'Marker', '*', 'LineWidth', 1, 'LineStyle', '--', 'Color', 'red', 'DisplayName', 'ROM');
ylabel('Damage');
xlabel('Time (sec)');
legend
box on
grid on
hold off

subplot(5, 1, 3);
err = abs(nr_damage-latin_damage) ./ nr_damage;
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error (%)');
xlabel('Time (sec)');
box on
grid on
hold off

subplot(5, 1, 4);
err = abs(nr_stress-latin_stress) ./ nr_stress;
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error (%)');
xlabel('Time (sec)');
title('stress');
box on
grid on
hold off

subplot(5, 1, 5);
err = abs(nr_strain-latin_strain) ./ nr_strain;
err(~isfinite(err)) = 0;
err = err * 100;
plot(tempoal_domain, err);
ylabel('Relative error (%)');
xlabel('Time (sec)');
title('strain');
box on
grid on
hold off

filename = 'output/temporal_scheme_1_2.tex';
cleanfigure;
saveas(gcf, filename(1:end-4), 'epsc')
matlab2tikz('figurehandle', gcf, 'filename', filename, 'standalone', true);
close

%% plot load
figure
plot(tempoal_domain, applied_load, 'LineWidth', 1.5, 'LineStyle', '-', 'Color', 'black');
ylabel('Prescribed displacement (mm)');
xlabel('Time (sec)');
% title('Number of PGD modes in each cycle');
box on
grid on
hold off
filename = 'output/temporal_scheme_1_1.tex';
cleanfigure;
saveas(gcf, filename(1:end-4), 'epsc')
matlab2tikz('figurehandle', gcf, 'filename', filename, 'standalone', true);
close

%% plot number of modes
figure
bar(n_modes)
ylabel('Number of PGD modes');
xlabel('Number of cycles');
% title('Number of PGD modes in each cycle');
box on
grid on
hold off
filename = 'output/temporal_scheme_1_3.tex';
cleanfigure;
saveas(gcf, filename(1:end-4), 'epsc')
matlab2tikz('figurehandle', gcf, 'filename', filename, 'standalone', true);
close

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
% title('Error indicator w.r.t. number of iterations for all nodal cycles');
box on
grid on
hold off
filename = 'output/temporal_scheme_1_4.tex';
cleanfigure;
saveas(gcf, filename(1:end-4), 'epsc')
matlab2tikz('figurehandle', gcf, 'filename', filename, 'standalone', true);
close