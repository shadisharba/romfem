function verify_latin_nr(input_file_name)

add_folder_to_path
!rm -rf output/*

rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = input_file_name('any');

tic;
solver_parameters.solver = 'nr';
solver_parameters.output_path = 'output/nr/plate_mesh';
solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, false);
nr_timing = toc;

tic;
solver_parameters.solver = 'latin';
solver_parameters.output_path = 'output/latin/plate_mesh';
solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, false);
latin_timing = toc;

diary('output/speedup.txt')
fprintf('NR : %e,\t latin : %e, \t speedup %e \n', nr_timing, latin_timing, nr_timing/latin_timing);
diary('off')

end