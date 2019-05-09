function solution = newton_solver(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, previous_cycle)
global build_mode_debug;
global convergence_plot;
global save_mat_files;
global cyclic_plot;

%             temporal.amplitude = user_temporal.amplitude;
% the elastic solution is already scaled to the current load

solver_parameters.output_path = [solver_parameters.output_path, '_', datestr(now, 'yyyymmdd_HHMMSSFFF')];

if build_mode_debug && cycles_to_save
    mkdir(solver_parameters.output_path);
    diary(sprintf('%s/Out_terminal.txt', solver_parameters.output_path));
end

if isempty(previous_cycle)
    numerical_model_obj = numerical_model(user_mesh, user_material, user_boundary_conditions, user_load.temporal_mesh);
    if save_mat_files && build_mode_debug
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

local_fields = global_fields;

free_dof = numerical_model_obj.boundary_conditions.free_dof;
submesh = numerical_model_obj.submesh;

for time_step = 2:length(numerical_model_obj.temporal.mesh)
    
    % displacment control only
    f_ext = zeros(length(free_dof), 1);
    % elastic solution
    displacement = global_fields.elastic_result.displacement(:, time_step);
    strain = global_fields.elastic_result.strain(:, time_step);
    
    norm_first_residual_free_dof = norm(global_fields.elastic_result.first_residual(:, time_step));
    
    local_fields = update_internal_variables(numerical_model_obj, strain, global_fields.initial_values, time_step, solver_parameters, true);
    
    f_int = submesh.integral_gradient_operator' * local_fields.stress;
    minus_residual = f_ext - f_int(free_dof);
    relative_err = compute_relative_error(minus_residual, norm_first_residual_free_dof, 0, norm(displacement(free_dof)));
    
    iter = 0;
    
    while norm(relative_err) > solver_parameters.convergence_tol && iter < solver_parameters.max_iter
        
        stiffness = submesh.gradient_operator' * local_fields.algorithmic_tangent_diagonal * submesh.integral_gradient_operator;
        
        % stiffness = 0.5 * (stiffness+stiffness');
        
        f_int = submesh.integral_gradient_operator' * local_fields.stress;
        
        minus_residual = f_ext - f_int(free_dof);
        
        delta_displacement = stiffness(free_dof, free_dof) \ minus_residual;
        
        displacement(free_dof) = displacement(free_dof) + delta_displacement;
        
        relative_err = compute_relative_error(minus_residual, norm_first_residual_free_dof, delta_displacement, norm(displacement(free_dof)));
        
        strain = numerical_model_obj.submesh.gradient_operator * displacement;
        
        local_fields = update_internal_variables(numerical_model_obj, strain, global_fields.initial_values, time_step, solver_parameters, true);
        
        iter = iter + 1;
        
    end
    
    global_fields.displacement(:, time_step) = displacement;
    global_fields.stress(:, time_step) = local_fields.stress;
    global_fields.strain(:, time_step) = local_fields.strain;
    global_fields.back_stress(:, time_step) = local_fields.back_stress;
    global_fields.isotropic_hardening(:, time_step) = local_fields.isotropic_hardening;
    global_fields.internal_damage(:, time_step) = local_fields.internal_damage;
    global_fields.initial_values = local_fields.initial_values;
    
    if iter == solver_parameters.max_iter
        warning('Newton-Raphson solver did not converge, current relative error: %e', norm(relative_err));
    end
    
    if build_mode_debug
        fprintf('---> #%5d, iter %3d, err %e \n', time_step, iter, relative_err);
    end
    
end

if build_mode_debug
    deviatoric_stress = deviatoric(global_fields.stress);
    equivalent_stress = sqrt(3/2.*double_dot_product(deviatoric_stress, deviatoric_stress));
    j2_eps = compute_equivalent_strain(global_fields.strain);
    
    max_damage = max(local_fields.internal_damage(:));
    if nnz(max_damage) == 0
        max_damage = 0;
    end
    fprintf('---> #%5d, err %e,  %d,  stress %e,  strain %e,  D %e \n', ...
        0, 0, 0, ...
        max(equivalent_stress(:)), max(j2_eps(:)), max_damage);
    
    
    
end

solution = extract_relevant_info(numerical_model_obj, global_fields, solver_parameters, cycles_to_save);

diary off
end


function relative_err = compute_relative_error(minus_residual, norm_first_residual_free_dof, delta_displacement, norm_displacement)
if norm_first_residual_free_dof
    relative_err_focre = norm(minus_residual) / norm_first_residual_free_dof;
else
    relative_err_focre = norm(minus_residual);
end
if norm_displacement
    relative_err_displacement = norm(delta_displacement) / norm_displacement;
else
    relative_err_displacement = norm(delta_displacement);
end
relative_err = max(relative_err_focre, relative_err_displacement);
end
