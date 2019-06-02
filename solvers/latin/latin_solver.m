function solution = latin_solver(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, previous_cycle)
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

local_fields = global_fields;
err_indicator = 1;
stag = 1;
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
while err_indicator(end) > solver_parameters.convergence_tol && iter < solver_parameters.max_iter
    iter = iter + 1;
    
    if cyclic_plot
        id = 148;
        plot(global_fields.strain(id*6-3, :), global_fields.stress(id*6-3, :));
        hold on
    end
    
    % local_fields = local_stage_vertical(numerical_model_obj, global_fields, solver_parameters);
    local_fields = local_stage_horizontal(numerical_model_obj, global_fields, solver_parameters);
    if isempty(local_fields)
        solution = [];
        return
    end
    
    global_fields = global_stage(global_fields, numerical_model_obj, local_fields, iter, solver_parameters);
    
    err_indicator = error_indicator(global_fields, numerical_model_obj.submesh, numerical_model_obj.temporal, iter, err_indicator);
    
    
    if iter > 1
        stag = abs(err_indicator(end-1)-err_indicator(end)) / (err_indicator(end-1) + err_indicator(end));
    end
    
    if build_mode_debug
        deviatoric_stress = deviatoric(global_fields.stress);
        equivalent_stress = sqrt(3/2.*double_dot_product(deviatoric_stress, deviatoric_stress));
        equivalent_strain = compute_equivalent_strain(global_fields.strain);
        
        max_damage = full(max(local_fields.initial_values.internal_damage(:)));
        if nnz(max_damage) == 0
            max_damage = 0;
        end
        fprintf('---> #%5d, err %e,  %d,  stress %e,  strain %e,  D %e \n', ...
            iter, err_indicator(end), global_fields.number_of_modes(end), ...
            max(equivalent_stress(:)), max(equivalent_strain(:)), max_damage);
        
        
        if convergence_plot
            scatter((local_fields.strain(idx, idy)), (local_fields.stress(idx, idy)));
            scatter((global_fields.strain(idx, idy)), (global_fields.stress(idx, idy)), 'filled');
            %             [~,idx]=max(equivalent_stress(:,end));
            %             [a,b]=max(equivalent_stress,[],1);
            %             [~,d]=max(a);
            %             row=b(d)
            %             col=d
        end
    end
    
    if err_indicator(end) < solver_parameters.convergence_tol % && (iter > 1)
        break
    elseif stag < solver_parameters.stagnation_tol
        % stagnation
        if build_mode_debug
            fprintf('---> #%5d, err %e,  %d,  stress %e,  strain %e,  D %e \n', ...
                iter, err_indicator(end), global_fields.number_of_modes(end), ...
                max(equivalent_stress(:)), max(equivalent_strain(:)), max_damage);
            
        end
        
        fprintf('stagnation : \t %e \t err: %e \n', stag);
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

solution = extract_relevant_info(numerical_model_obj, global_fields, err_indicator, solver_parameters, cycles_to_save);
solution.results.err_indicator = err_indicator;

diary off
end
