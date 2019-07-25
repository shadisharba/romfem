% profile on

input_file_name = @input_verify;

add_folder_to_path
rmdir('output', 's');
mkdir('output');

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode] = input_file_name('any');

%% timing and accuracy
% %{
amplitude = [40, 41, 42, 43, 44, 44, 43, 42, 41, 40] * 1e-4;
period = [5, 10, 5, 10, 5, 10, 5, 10, 5, 10];
timestep_per_cycle_div4 = 10;
[user_boundary_conditions,user_load] = loading_history(false,true,amplitude,period,timestep_per_cycle_div4);
solver_parameters.local_stage_neural_networks = 5; % number of iterations with neural networks
%}
%% convergence
%{
amplitude = [56] * 1e-4;
period = [5];
timestep_per_cycle_div4 = 10;
[user_boundary_conditions,user_load] = loading_history(false,true,amplitude,period,timestep_per_cycle_div4);
solver_parameters.local_stage_neural_networks = 1; % number of iterations with neural networks
% %  if max(equivalent_apparent_stress(:)) > 2 * material.user_material.sigma_y        error('***********');
%}

solver_parameters.update_error = 5; % calculate the error every n iterations
solver_parameters.convergence_tol = 1E-6;

% tic;
% solver_parameters.solver = 'nr';
% solver_parameters.output_path = 'output/nr/plate_mesh';
% solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode, false);
% nr_timing = toc;

tic;
solver_parameters.solver = 'latin';
solver_parameters.output_path = 'output/latin/plate_mesh';
sa_profile(@() solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode, false));
latin_timing = toc;

diary('output/speedup.txt')
fprintf('latin : %e, \t \n', latin_timing);
diary('off')

% post_process_verify
% profile viewer
profile off
% return
