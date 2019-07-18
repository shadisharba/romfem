function [global_fields, err_indicator] = latin_solver(numerical_model_obj, global_fields)
global build_mode_debug;
global convergence_plot;
global cyclic_plot;


local_fields = global_fields;
err_indicator = 1;
stagnation = 1;
iter = 0;

if convergence_plot
    [~, idx] = max(local_fields.internal_damage(:, end));
    idx = idx * 6 - 3;
    idy = 16;
    
    idx = 867; %879  867 885
    idy = 9;
    
    scatter((global_fields.strain(idx, idy)), (global_fields.stress(idx, idy)), 'filled');
    hold on;
end

% iter = 1;
% local_fields = local_stage(numerical_model_obj, global_fields, local_fields, solver_parameters);
% global_fields.strain_increment = global_fields.strain - local_fields.strain;
% global_fields.stress_increment = global_fields.stress - local_fields.stress;
% err_indicator = error_indicator(global_fields, local_fields, numerical_model_obj.submesh, numerical_model_obj.temporal, iter, err_indicator);

%% LATIN Iterations
while err_indicator(end) > numerical_model_obj.solver_parameters.convergence_tol && iter < numerical_model_obj.solver_parameters.max_iter
    iter = iter + 1;
    
    if cyclic_plot
        id = 148;
        plot(global_fields.strain(id*6-3, :), global_fields.stress(id*6-3, :));
        hold on
    end
    
    % local_fields = local_stage_vertical(numerical_model_obj, global_fields);
    local_fields = local_stage_horizontal(numerical_model_obj, global_fields, iter);
    if isempty(local_fields)
        global_fields = [];
        err_indicator = [];
        return
    end
    
    global_fields = global_stage(global_fields, numerical_model_obj, local_fields, iter);
    
    if mod(iter,numerical_model_obj.solver_parameters.update_error)==1
        err_indicator = error_indicator(global_fields, local_fields, numerical_model_obj.submesh, numerical_model_obj.temporal, iter, err_indicator, numerical_model_obj.solver_parameters);
    
        if iter > 1
            stagnation = abs(err_indicator(end-1)-err_indicator(end)) / (err_indicator(end-1) + err_indicator(end));
        end    
    end
    
    if build_mode_debug
        max_damage = full(max(local_fields.initial_values.internal_damage(:)));
        if nnz(max_damage) == 0
            max_damage = 0;
        end
        fprintf('---> #%5d, err %e,  %d, D %e \n', ...
            iter, err_indicator(end), global_fields.number_of_modes(end), max_damage);
        
        if convergence_plot
            scatter((local_fields.strain(idx, idy)), (local_fields.stress(idx, idy)));
            scatter((global_fields.strain(idx, idy)), (global_fields.stress(idx, idy)), 'filled');
        end
    end
    
    if err_indicator(end) < numerical_model_obj.solver_parameters.convergence_tol % && (iter > 1)
        break
    elseif stagnation < numerical_model_obj.solver_parameters.stagnation_tol
        fprintf('stagnation : \t %e \n', stagnation);
        break
    end
    % break if the error is increasing
    [~, I] = sort(err_indicator, 'descend');
    if length(setdiff(1:length(err_indicator), I)) > 5
        fprintf('The error is increasing');
        break
    end
end

% collect the initial_values "after convergence" in global_fields
global_fields.initial_values = local_fields.initial_values;

end
