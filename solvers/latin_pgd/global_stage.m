function global_fields = global_stage(global_fields, numerical_model, local_fields, iter)
% internal variables [needed because the local stage is explicit]
global_fields.back_stress = local_fields.back_stress;
global_fields.isotropic_hardening = local_fields.isotropic_hardening;
global_fields.internal_damage = local_fields.internal_damage;

score = 0;

% if parameters.iter<3
if iter ~= 1 || size(global_fields.temporal_modes, 1)
    delta_time_mode = temporal_update(global_fields.strain_spatial_modes, local_fields, numerical_model,global_fields.temporal_modes);
    score = vecnorm(delta_time_mode)./ vecnorm(global_fields.temporal_modes);
end

if max(score) < 0.1 % TODO: 0.3 %parameter % && size(global_fields.temporal_modes, 1) < 3
    global_fields = new_modes(global_fields, numerical_model, local_fields);
else
    idx = score > 1e-6; %parameter
    global_fields.temporal_modes(:, idx) = global_fields.temporal_modes(:, idx) + delta_time_mode(:, idx);
end

strain_correction = pgd(global_fields.strain_spatial_modes,[],global_fields.temporal_modes);

% the essential boundary and initial conditions are still satisfied when computing strain_correction.full
strain_correction.orthonormalise_modes(@rsvd);
global_fields.strain_spatial_modes = strain_correction.spatial_modes;
global_fields.temporal_modes = strain_correction.temporal_modes * strain_correction.singular_values;

global_fields.number_of_modes(end+1) = strain_correction.size;

global_fields.strain = global_fields.elastic_result.strain + strain_correction;

global_fields.sum_residual = global_fields.sum_residual - local_fields.minus_residual;

global_fields.stress = (global_fields.elastic_result.stress + local_fields.global_search_direction * strain_correction) + global_fields.sum_residual;
% global_fields.stress = local_fields.stress + local_fields.global_search_direction * (global_fields.strain - local_fields.strain); % global search direction equation

end
