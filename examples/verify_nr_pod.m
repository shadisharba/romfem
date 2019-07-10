function verify_nr_pod(input_file_name)

add_folder_to_path
rmdir('output', 's'); mkdir('output');

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = input_file_name('any');

tic;
solver_parameters.solver = 'nr';
solver_parameters.output_path = 'output/nr/plate_mesh';
solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, false);
nr_timing = toc;

extract_and_save_rob()

n = 1;
u = load('output/pod_full_rob.mat');
u = u.u(:, 1:n);
save('output/pod_rob.mat', 'u');

tic;
solver_parameters.solver = 'nr_pod';
solver_parameters.output_path = 'output/nr_pod/plate_mesh';
solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, false);
nr_pod_timing = toc;

diary('output/speedup.txt')
fprintf('NR : %e,\t latin : %e, \t speedup %e \n', nr_timing, nr_pod_timing, nr_timing/nr_pod_timing);
diary('off')

% error = norm(solution1.displacement-solution2.displacement) / norm(solution1.displacement);
% disp(error * 100)
end