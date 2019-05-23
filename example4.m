rng(0)
[solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = one_cycle('any');

!rm -rf output/*
tic;
solver_parameters.solver = 'latin';
[~, latin_solution] = solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, true);
latin_timing = toc;
save('latin_solution.mat', 'latin_solution', 'latin_timing');

% main(0,@() one_cycle('latin'));