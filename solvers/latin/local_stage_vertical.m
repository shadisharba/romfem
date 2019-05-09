% TODONOW
function local_fields = local_stage_vertical(numerical_model, old_global_fields, old_local_fields, solver_parameters)

local_fields = old_global_fields;
local_fields.global_search_direction = solver_parameters.elasticity_reduction_factor .* numerical_model.material.elasticity_tensor_diagonal;

for time_step = 2:length(numerical_model.temporal.mesh)
    
    strain = old_global_fields.strain(:, time_step);
    local_fields_incremental = update_internal_variables(numerical_model, strain, local_fields.initial_values, time_step, solver_parameters, true);
    
    local_fields.stress(:, time_step) = local_fields_incremental.stress;
    local_fields.strain(:, time_step) = local_fields_incremental.strain;
    local_fields.back_stress(:, time_step) = local_fields_incremental.back_stress;
    local_fields.isotropic_hardening(:, time_step) = local_fields_incremental.isotropic_hardening;
    local_fields.internal_damage(:, time_step) = local_fields_incremental.internal_damage;
    local_fields.initial_values = local_fields_incremental.initial_values;
    
end

% global_search_direction = average(local_fields_incremental.algorithmic_tangent_diagonal);
local_fields.minus_residual = -(local_fields.stress - old_global_fields.stress);

end
