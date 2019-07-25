input_file_name = @input_verify;

add_folder_to_path
try
    rmdir('output/latin', 's');
catch
end
% mkdir('output');

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode] = input_file_name('any');

solver_parameters.local_stage_pgd = true; % when true, use convergence_tol 1e-6
solver_parameters.error_indecator_pgd = false;
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
solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode, false);
latin_timing = toc;

diary('output/speedup.txt')
fprintf('latin : %e, \t \n', latin_timing);
diary('off')

% post_process_verify
return
