function verify_nr_pod(input_file_name)

add_folder_to_path

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = input_file_name('any');

!rm -rf output/*
tic;
solver_parameters.solver = 'nr';
[~, nr_solution] = solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, true);
nr_timing = toc;
save('nr_solution.mat', 'nr_solution', 'nr_timing');

extract_and_save_rob()

n = 1;
u = load('pod_rob_full.mat');
u = u.u(:, 1:n);
save('pod_rob.mat', 'u');

!rm -rf output/*
tic;
solver_parameters.solver = 'nr_pod';
[~, nr_pod_solution] = solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, true);
nr_pod_timing = toc;
save('nr_pod_solution.mat', 'nr_pod_solution', 'nr_pod_timing');

post_process_verify()

end