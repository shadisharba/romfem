function [solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode] = input_verify(solver)
close all;
clc;
clearAllMemoizedCaches

build_mode = struct('build_mode_debug', true, 'convergence_plot', false, 'save_mat_files', true, 'cyclic_plot', false, 'profiler', false, 'parallel', false, 'clean_output', true);

if ~nargout
    return
end

user_mesh = 'plate.mesh';

clamped = false; % clamped or sym B.C.
tension = true; % tension or bending
amplitude = [40, 41, 42, 43, 44, 44, 43, 42, 41, 40] * 1e-4;
period = [5, 10, 5, 10, 5, 10, 5, 10, 5, 10];
timestep_per_cycle_div4 = 50;
[user_boundary_conditions, user_load] = loading_history(clamped, tension, amplitude, period, timestep_per_cycle_div4);

cycles_to_save = 1:length(amplitude);

solver_parameters.solver = solver;
solver_parameters.local_stage_pgd = false; % when true, use convergence_tol 1e-6
solver_parameters.error_indecator_pgd = false;
solver_parameters.local_stage_neural_networks = 0; % number of iterations with neural networks
solver_parameters.update_error = 2; % calculate the error every n iterations
solver_parameters.elasticity_reduction_factor = 1;
solver_parameters.max_iter = 100;
solver_parameters.stagnation_tol = 1E-2;
solver_parameters.convergence_tol = 1E-14;
solver_parameters.output_path = sprintf('output/%s', strrep(user_mesh, '.', '_'));

ductile_material = true;
if ductile_material
    user_material = struct('S', 0.6, 's', 2, 'E', 134e3, 'nu', 0.3, 'n', 2.5, 'k', 1220, 'c', 2/3*5500, 'a', 250, ...
        'sigma_y', 85, 'sigma_u', 137, 'sigma_inf', 60, 'r_inf', 30, 'r_exp', 2, 'eps_p_d', 0, 'm', 4, 'd_c', 0.2);
    % 'eps_p_d', 0.2,
else
    user_material = struct('S', 2.8, 's', 2, 'E', 200e3, 'nu', 0.3, 'n', 12.5, 'k', 195, 'c', 2/3*20600, 'a', 140, ...
        'sigma_y', 180, 'sigma_u', 450, 'sigma_inf', 140, 'r_inf', 6, 'r_exp', 2, 'eps_p_d', 0.12, 'm', 2, 'd_c', 0.2);
end

end

% material model on page 53 // 2.6 Table of Material Damage Parameters, P: 139, 265
% \cite{lemaitre2005engineering} CrMo at 580 C [page: 132] // c=gamma*X_inf
% a = gamma
% \cite{lemaitre2005engineering} CrMo at 20 C [page: 217]  // c=gamma*X_inf
% S shifts the range or the curve but the ratio of the limits is (higher S, slower evolutio) % s controls the slope (higher s, slower evolutio)
%     T = 20;
%     E = 31800 * (1 - exp(1.88e-3*T)) + 199800
%     sigma_y = 70 * (1 - exp(1.58e-3*T)) + 191.5
%     r_inf = 0.78 * (1 + exp(6e-3*T)) + 4.5
%     X_inf = 150 - 0.216 * T
%     a = 0.392 * (1 + exp(9.69e-3*T)) + 140.5
%     c = a * X_inf % // c=gmma*X_inf
%     K = 190 + 0.25 * T + 2.7 * exp((T - 372.7)/35.32)
%     N = 10.315 * exp(-(0.022 * T)^4.89) + 2.41
%     eps_p_d = -0.000285 * T + 0.2657
%     S = 0.108 * (1 - exp(0.0052*T)) + 2.81
