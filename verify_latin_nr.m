function verify_latin_nr(input_file_name)

add_folder_to_path

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = input_file_name('any');

!rm -rf output/*
tic;
solver_parameters.solver = 'NR';
[~, nr_solution] = solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, true);
nr_timing = toc;
save('nr_solution.mat', 'nr_solution', 'nr_timing');

!rm -rf output/*
tic;
solver_parameters.solver = 'romfem';
[~, latin_solution] = solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, true);
latin_timing = toc;
save('latin_solution.mat', 'latin_solution', 'latin_timing');

end