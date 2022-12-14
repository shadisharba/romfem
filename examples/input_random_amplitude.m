function [solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode] = input_random_amplitude(solver)
close all;
clc;
clearAllMemoizedCaches

build_mode = struct('build_mode_debug', false, 'convergence_plot', false, 'save_mat_files', false, 'cyclic_plot', false, 'profiler', false, 'parallel', true, 'clean_output', false);

if ~nargout
    return
end

user_mesh = 'plate.mesh';

clamped = false; % clamped or sym B.C.
tension = true; % tension or bending

number_of_cycles = 1e4;
a = 53e-4;
b = 56e-4;
amplitude = a + (b - a) .* rand(1, number_of_cycles);
period = 10 * ones(1, number_of_cycles);
timestep_per_cycle_div4 = 10;
[user_boundary_conditions, user_load] = loading_history(clamped, tension, amplitude, period, timestep_per_cycle_div4);

cycles_to_save = [1:99:number_of_cycles];

solver_parameters.solver = solver;
solver_parameters.local_stage_pgd = false; % when true, use convergence_tol 1e-6
solver_parameters.error_indecator_pgd = false;
solver_parameters.local_stage_neural_networks = 0; % number of iterations with neural networks
solver_parameters.update_error = 2; % calculate the error every n iterations
solver_parameters.elasticity_reduction_factor = 0.41;
solver_parameters.max_iter = 100;
solver_parameters.stagnation_tol = 1E-3;
solver_parameters.convergence_tol = 1E-3;
solver_parameters.output_path = sprintf('output/%s', strrep(user_mesh, '.', '_'));

ductile_material = true;
if ductile_material
    user_material = struct('S', 0.6, 's', 1.1, 'E', 134e3, 'nu', 0.3, 'n', 2.5, 'k', 1220, 'c', 2/3*5500, 'a', 250, ...
        'sigma_y', 85, 'sigma_u', 137, 'sigma_inf', 60, 'r_inf', 30, 'r_exp', 2, 'eps_p_d', 0, 'm', 4, 'd_c', 0.2);
    % 'eps_p_d', 0.2,
else
    user_material = struct('S', 2.8, 's', 2, 'E', 200e3, 'nu', 0.3, 'n', 12.5, 'k', 195, 'c', 2/3*20600, 'a', 140, ...
        'sigma_y', 180, 'sigma_u', 450, 'sigma_inf', 140, 'r_inf', 6, 'r_exp', 2, 'eps_p_d', 0.12, 'm', 2, 'd_c', 0.2);
end

end
