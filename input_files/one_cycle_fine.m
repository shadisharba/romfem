function [solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = one_cycle_fine(solver)
close all;
clc;
clearAllMemoizedCaches

global build_mode_debug;
global convergence_plot;
global save_mat_files;
global cyclic_plot;
global profiler;
global parallel;
global clean_output;

build_mode_debug = true;
convergence_plot = false;
cyclic_plot = false;
save_mat_files = true;
profiler = false;
parallel = false;
clean_output = true;

if ~nargout
    return
end

user_mesh = 'plate_fine.mesh';
ductile_material = true;
clamped = false; % clamped or sym B.C.
tension = true; % tension or bending

amplitude = [40] * 1e-5;
period = [10];
timestep_per_cycle_div4 = 50;

cycles_to_save = 1:length(amplitude);

user_load = loading.empty([length(amplitude), 0]);
for i = 1:length(amplitude)
    user_load(i) = loading(1, period(i), timestep_per_cycle_div4, amplitude(i), 0);
end

solver_parameters.solver = solver;
solver_parameters.local_stage_pgd = false;
solver_parameters.error_indecator_pgd = false;
solver_parameters.update_error = 2; % calculate the error every n iterations
solver_parameters.elasticity_reduction_factor = 1;
solver_parameters.max_iter = 100;
solver_parameters.stagnation_tol = 1E-2;
solver_parameters.convergence_tol = 1E-14;
solver_parameters.output_path = sprintf('output/%s', strrep(user_mesh, '.', '_'));

% model on page 53 // 2.6 Table of Material Damage Parameters, P: 139, 265
% \cite{lemaitre2005engineering} CrMo at 580 C [page: 132] // c=gamma*X_inf
% a = gamma
% \cite{lemaitre2005engineering} CrMo at 20 C [page: 217]  // c=gamma*X_inf
if ductile_material
    % S shifts the range or the curve but the ratio of the limits is (higher S, slower evolutio) % s controls the slope (higher s, slower evolutio)
    user_material = struct('S', 0.6, 's', 2, 'E', 134e3, 'nu', 0.3, 'n', 2.5, 'k', 1220, 'c', 2/3*5500, 'a', 250, ...
        'sigma_y', 85, 'sigma_u', 137, 'sigma_inf', 60, 'r_inf', 30, 'r_exp', 2, 'eps_p_d', 0, 'm', 4, 'd_c', 0.2);
    % 'eps_p_d', 0.2,
else
    user_material = struct('S', 2.8, 's', 2, 'E', 200e3, 'nu', 0.3, 'n', 12.5, 'k', 195, 'c', 2/3*20600, 'a', 140, ...
        'sigma_y', 180, 'sigma_u', 450, 'sigma_inf', 140, 'r_inf', 6, 'r_exp', 2, 'eps_p_d', 0.12, 'm', 2, 'd_c', 0.2);
end

user_boundary_conditions(1).name = 'zload';
if tension
    user_boundary_conditions(1).direction = 3;
else % bending
    user_boundary_conditions(1).direction = 1;
end

user_boundary_conditions(1).magnitude(1, :) = user_load(1).magnitude;

if clamped
    user_boundary_conditions(end+1).name = 'zsym';
    user_boundary_conditions(end).direction = [1, 2, 3];
    user_boundary_conditions(end).magnitude = zeros(3, length(user_load(1).temporal_mesh));
else % 'symmetry'
    user_boundary_conditions(end+1).name = 'xsym';
    user_boundary_conditions(end).direction = 1;
    user_boundary_conditions(end).magnitude = zeros(1, length(user_load(1).temporal_mesh));

    user_boundary_conditions(end+1).name = 'ysym';
    user_boundary_conditions(end).direction = 2;
    user_boundary_conditions(end).magnitude = zeros(1, length(user_load(1).temporal_mesh));

    user_boundary_conditions(end+1).name = 'zsym';
    user_boundary_conditions(end).direction = 3;
    user_boundary_conditions(end).magnitude = zeros(1, length(user_load(1).temporal_mesh));
end

end
