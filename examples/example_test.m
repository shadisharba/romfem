profile on

add_folder_to_path
rmdir('output', 's');
mkdir('output');

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode] = input_verify('any');

[user_boundary_conditions, user_load] = loading_history(false, true, [36, 38]*1e-4, [5, 10], 10);

solver_parameters.solver = 'latin';
solver_parameters.output_path = 'output/latin/plate_mesh';
solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, build_mode, false);

profile viewer
profile off