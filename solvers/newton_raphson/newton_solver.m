function [global_fields, relative_err] = newton_solver(numerical_model_obj, global_fields)
global build_mode_debug;

global_fields.stress = full(global_fields.stress);
global_fields.strain = full(global_fields.strain);
global_fields.displacement = zeros(numerical_model_obj.mesh.dof,numerical_model_obj.temporal.dof);

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
    
    local_fields = update_internal_variables(numerical_model_obj, strain, global_fields.initial_values, time_step, true);
    
    f_int = submesh.integral_gradient_operator' * local_fields.stress;
    minus_residual = f_ext - f_int(free_dof);
    relative_err = compute_relative_error(minus_residual, norm_first_residual_free_dof, 0, norm(displacement(free_dof)));
    
    iter = 0;
    
    while norm(relative_err) > numerical_model_obj.solver_parameters.convergence_tol && iter < numerical_model_obj.solver_parameters.max_iter
        
        stiffness = submesh.gradient_operator' * local_fields.algorithmic_tangent_diagonal * submesh.integral_gradient_operator;
        
        % stiffness = 0.5 * (stiffness+stiffness');
        
        f_int = submesh.integral_gradient_operator' * local_fields.stress;
        
        minus_residual = f_ext - f_int(free_dof);
        
        delta_displacement = stiffness(free_dof, free_dof) \ minus_residual;
        
        displacement(free_dof) = displacement(free_dof) + delta_displacement;
        
        relative_err = compute_relative_error(minus_residual, norm_first_residual_free_dof, delta_displacement, norm(displacement(free_dof)));
        
        strain = numerical_model_obj.submesh.gradient_operator * displacement;
        
        local_fields = update_internal_variables(numerical_model_obj, strain, global_fields.initial_values, time_step, true);
        
        iter = iter + 1;
        
    end
    
    global_fields.displacement(:, time_step) = displacement;
    global_fields.stress(:, time_step) = local_fields.stress;
    global_fields.strain(:, time_step) = local_fields.strain;
    global_fields.internal_damage(:, time_step) = local_fields.internal_damage;
    global_fields.initial_values = local_fields.initial_values;
    
    if iter == numerical_model_obj.solver_parameters.max_iter
        warning('Newton-Raphson solver did not converge, current relative error: %e', norm(relative_err));
    end
    
    if build_mode_debug
        fprintf('---> #%5d, iter %3d, err %e \n', time_step, iter, relative_err);
    end
    
end

if build_mode_debug
    max_damage = max(local_fields.internal_damage(:));
    if nnz(max_damage) == 0
        max_damage = 0;
    end
    fprintf('--- --- --- > maximum damage %e \n', max_damage);
end

end
