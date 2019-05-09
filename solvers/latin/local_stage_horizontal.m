function local_fields = local_stage_horizontal(numerical_model, old_global_fields, old_local_fields, solver_parameters)
% global build_mode_debug
material = numerical_model.material;

local_fields.global_search_direction = solver_parameters.elasticity_reduction_factor .* material.elasticity_tensor_diagonal;

ncomp = numerical_model.mesh.quadrature_dof;
temporal_dof = numerical_model.temporal.dof;

internal_plastic_strain = sparse(repmat(old_global_fields.initial_values.internal_plastic_strain, [1, temporal_dof]));
internal_kinematic = sparse(repmat(old_global_fields.initial_values.internal_kinematic, [1, temporal_dof]));
internal_isotropic = sparse(repmat(old_global_fields.initial_values.internal_isotropic, [1, temporal_dof]));
damage = sparse(repmat(old_global_fields.initial_values.internal_damage, [1, temporal_dof]));

stress = old_global_fields.stress;
back_stress = old_local_fields.back_stress;
isotropic_hardening = old_local_fields.isotropic_hardening;

repelem_memoized = memoize(@repelem);
[equivalent_apparent_stress, deviatoric_apparent_stress, equivalent_stress] = compute_equivalent_stress(stress, back_stress, repelem_memoized(damage, ncomp, 1));
[f_vp, row, col, row6] = evaluate_yield_function(equivalent_apparent_stress, isotropic_hardening, material.user_material.sigma_y);

% Do not touch the first column that correspond to the initial conditions
f_vp = f_vp(:, col ~= 1);
col(col == 1) = [];

if max(equivalent_apparent_stress(:)) > 2 * material.user_material.sigma_y
    local_fields = local_stage_vertical(numerical_model, old_global_fields, old_local_fields, solver_parameters);
    return
    %     stress = stress / 1.5;
end

inv_elasticity = material.inv_elasticity_tensor_diagonal(row6, row6);

if nnz(row)
    
    old_damage = old_local_fields.internal_damage(row, col);
    
    normal_without_damage = evaluate_normal_without_damage(deviatoric_apparent_stress(row6, col), repelem(equivalent_apparent_stress(row, col), ncomp, 1));
    
    plastic_multiplier = evaluate_plastic_multiplier(material, f_vp);
    
    internal_plastic_strain_rate = sparse(length(row6), temporal_dof);
    internal_kinematic_rate = internal_plastic_strain_rate;
    internal_isotropic_rate = sparse(length(row), temporal_dof);
    damage_rate = internal_isotropic_rate;
    
    internal_plastic_strain_rate(:, col) = plastic_strain_evolution(repelem(plastic_multiplier, ncomp, 1), normal_without_damage, repelem(old_damage, ncomp, 1));
    internal_plastic_strain(row6, :) = internal_plastic_strain(row6, :) + temporal_cumulative_integration(internal_plastic_strain_rate, numerical_model.temporal);
    
    internal_kinematic_rate(:, col) = kinematic_hardening_evolution(material, repelem(plastic_multiplier, ncomp, 1), normal_without_damage, back_stress(row6, col));
    internal_kinematic(row6, :) = internal_kinematic(row6, :) + temporal_cumulative_integration(internal_kinematic_rate, numerical_model.temporal);
    back_stress(row6, :) = compute_back_stress(material, internal_kinematic(row6, :));
    
    internal_isotropic_rate(:, col) = isotropic_hardening_evolution(plastic_multiplier);
    internal_isotropic(row, :) = internal_isotropic(row, :) + temporal_cumulative_integration(internal_isotropic_rate, numerical_model.temporal);
    isotropic_hardening(row, :) = compute_isotropic_hardening(material, internal_isotropic(row, :));
    
    Y = compute_energy_release_rate(stress(row6, col), inv_elasticity, old_damage);
    damage_rate(:, col) = damage_evolution(material, Y, plastic_multiplier, old_damage, evaluate_damage_evolution_condition(material, equivalent_stress(row, col), internal_isotropic(row, col)));
    damage(row, :) = damage(row, :) + temporal_cumulative_integration(damage_rate, numerical_model.temporal);
    
    if max(damage(:)) > 0.99
        warning('damage exceeds the maximum allowed damage');
        local_fields = [];
        return
        % damage=old_local_fields.internal_damage;
    end
end

elastic_strain = compute_elastic_strain(stress, material.inv_elasticity_tensor_diagonal, repelem_memoized(damage, ncomp, 1));
elastic_strain(row6, :) = compute_elastic_strain(stress(row6, :), inv_elasticity, repelem(damage(row, :), ncomp, 1));

local_fields.strain = elastic_strain + internal_plastic_strain;
local_fields.stress = stress;

local_fields.back_stress = back_stress;
local_fields.isotropic_hardening = isotropic_hardening;
local_fields.internal_damage = damage;

local_fields.initial_values.internal_plastic_strain = internal_plastic_strain(:, end);
local_fields.initial_values.internal_kinematic = internal_kinematic(:, end);
local_fields.initial_values.internal_isotropic = internal_isotropic(:, end);
local_fields.initial_values.internal_damage = damage(:, end);

local_fields.minus_residual = local_fields.global_search_direction * (local_fields.strain - old_global_fields.strain) - (local_fields.stress - old_global_fields.stress);

end