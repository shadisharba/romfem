function global_fields = global_stage(global_fields, numerical_model, local_fields, iter)
old_global_fields = global_fields;
score = 0;

% if parameters.iter<3
if iter ~= 1 || size(global_fields.temporal_modes, 1)
    delta_time_mode = temporal_update(global_fields.strain_spatial_modes, local_fields, numerical_model);
    score = sqrt(sum(delta_time_mode.^2, 2)./sum(global_fields.temporal_modes.^2, 2));
    
    idx = score > 1e-6; %parameter
    global_fields.temporal_modes(idx, :) = global_fields.temporal_modes(idx, :) + delta_time_mode(idx, :);
end

if max(score) < 0.1 % TODO: 0.3 %parameter
    global_fields = old_global_fields;
    global_fields = new_modes(global_fields, numerical_model, local_fields);
end

% the essential boundary and initial conditions are still satisfied when computing global_fields.displacement_spatial_modes * global_fields.temporal_modes
if size(global_fields.displacement_spatial_modes, 2) > 1
    [global_fields.strain_spatial_modes, global_fields.temporal_modes] = orthogonalise_space_modes(global_fields.strain_spatial_modes, global_fields.temporal_modes, 'svds_decomposed');
end
% [global_fields.displacement_spatial_modes, global_fields.temporal_modes] = orthogonalise_space_modes(global_fields.displacement_spatial_modes, global_fields.temporal_modes, 'svds');
% global_fields.strain_spatial_modes = numerical_model.submesh.gradient_operator * global_fields.displacement_spatial_modes;

global_fields.number_of_modes(end+1) = size(global_fields.strain_spatial_modes, 2);

global_fields.strain = global_fields.elastic_result.strain.full + global_fields.strain_spatial_modes * global_fields.temporal_modes;

% global_fields.stress = local_fields.stress + local_fields.global_search_direction * (global_fields.strain - local_fields.strain); % global search direction equation

% TODONOW: sth wrong is going when using the following formulation
global_fields.sum_residual = global_fields.sum_residual - local_fields.minus_residual;
global_fields.stress = global_fields.elastic_result.stress.full + (local_fields.global_search_direction * global_fields.strain_spatial_modes) * global_fields.temporal_modes + global_fields.sum_residual;

global_fields.strain_increment = global_fields.strain - local_fields.strain;
global_fields.stress_increment = global_fields.stress - local_fields.stress;

global_fields.sum_stresses = 0.5 * (global_fields.stress + local_fields.stress);
global_fields.sum_strains = 0.5 * (global_fields.strain + local_fields.strain);

end
