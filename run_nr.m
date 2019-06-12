function run_nr(input_file_name)

add_folder_to_path
!rm -rf output/*

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = input_file_name('any');

tic;
solver_parameters.solver = 'nr';
solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, false);
nr_timing = toc;

disp(nr_timing)
end