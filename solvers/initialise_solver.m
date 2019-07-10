function [numerical_model_obj, global_fields] = initialise_solver(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, previous_cycle)

global build_mode_debug;
global save_mat_files;

solver_parameters.output_path = [solver_parameters.output_path, '_', datestr(now, 'yyyymmdd_HHMMSSFFF')];

if build_mode_debug && cycles_to_save
    mkdir(solver_parameters.output_path);
    diary(sprintf('%s/Out_terminal.txt', solver_parameters.output_path));
end

if isempty(previous_cycle)
    numerical_model_obj = numerical_model(user_mesh, user_material, user_boundary_conditions, user_load.temporal_mesh, solver_parameters);
    if save_mat_files
        warning('off', 'all');
        save('output/numerical_model.mat', '-mat', 'numerical_model_obj', '-v6');
        warning('on', 'all');
    end
    % Initialisation
    global_fields = initialise_ductile(numerical_model_obj, []);
else
    numerical_model_obj = previous_cycle.numerical_model;
    numerical_model_obj.temporal = temporal_mesh(user_load.temporal_mesh);
    user_boundary_conditions(1).magnitude(1, :) = user_load.magnitude;
    numerical_model_obj.boundary_conditions = boundary_conditions(previous_cycle.numerical_model.mesh, user_boundary_conditions);
    
    % cycle by cycle
    % initialisation based on the previously generated modes
    global_fields = initialise_ductile(numerical_model_obj, previous_cycle.results);
end

numerical_model_obj.solver_parameters = solver_parameters;

end