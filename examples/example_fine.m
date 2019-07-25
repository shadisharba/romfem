% profile on

add_folder_to_path
rmdir('output', 's');
mkdir('output');

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode] = input_verify('any');

user_mesh = 'plate_fine.mesh';

[user_boundary_conditions,user_load] = loading_history(false,true,20 * 1e-5,10,50);

solver_parameters.local_stage_pgd = false; % when true, use convergence_tol 1e-6
solver_parameters.error_indecator_pgd = false;
solver_parameters.update_error = 5; % calculate the error every n iterations
solver_parameters.convergence_tol = 1E-6;

solver_parameters.solver = 'latin';
solver_parameters.output_path = 'output/latin/plate_fine_mesh';
sa_profile(@() solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode, false));

% profile viewer
% profile off