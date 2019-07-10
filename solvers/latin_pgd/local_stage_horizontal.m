function local_fields = local_stage_horizontal(numerical_model, old_global_fields, iter)
% global build_mode_debug
material = numerical_model.material;

local_fields.global_search_direction = numerical_model.solver_parameters.elasticity_reduction_factor .* material.elasticity_tensor_diagonal;

ncomp = numerical_model.mesh.quadrature_dof;
temporal_dof = numerical_model.temporal.dof;

n = 4;

if iter <= -3
    gp = numerical_model.mesh.number_of_quadrature;
    ncomp = numerical_model.mesh.quadrature_dof;
    n_t = numerical_model.temporal.dof;
    
    stress = full(old_global_fields.stress);
    back_stress = old_global_fields.back_stress;
    isotropic_hardening = old_global_fields.isotropic_hardening;
    internal_damage = old_global_fields.internal_damage;
    
    input = vertcat(reshape(full(stress), [ncomp, gp * n_t]), ...
        reshape(full(back_stress), [ncomp, gp * n_t]), ...
        reshape(full(isotropic_hardening), [1, gp * n_t]), ...
        reshape(full(internal_damage), [1, gp * n_t]));
    
    y = neural_constitutive_model(input);
    
    internal_plastic_strain = reshape(y(1:6, :), [ncomp * gp, n_t]);
    internal_kinematic = reshape(y(7:12, :), [ncomp * gp, n_t]);
    internal_isotropic = reshape(y(13, :), [gp, n_t]);
    internal_damage = reshape(y(14, :), [gp, n_t]);
    
else
    internal_plastic_strain = sparse(repmat(old_global_fields.initial_values.internal_plastic_strain, [1, temporal_dof]));
    internal_kinematic = sparse(repmat(old_global_fields.initial_values.internal_kinematic, [1, temporal_dof]));
    internal_isotropic = sparse(repmat(old_global_fields.initial_values.internal_isotropic, [1, temporal_dof]));
    internal_damage = sparse(repmat(old_global_fields.initial_values.internal_damage, [1, temporal_dof]));
    
    if ~numerical_model.solver_parameters.strain_pgd
        stress = full(old_global_fields.stress);
    else
        stress = old_global_fields.stress;
    end
    
    back_stress = old_global_fields.back_stress;
    isotropic_hardening = old_global_fields.isotropic_hardening;
    old_internal_damage = old_global_fields.internal_damage;
    
    one_minus_internal_damage_pgd_old = repelem(1-old_internal_damage, ncomp, 1);
    if numerical_model.solver_parameters.strain_pgd
        %     one_minus_internal_damage_pgd_old = full_to_pgd(one_minus_internal_damage_pgd_old,2*iter,1e-8); % eps
        one_minus_internal_damage_pgd_old = full_to_pgd(one_minus_internal_damage_pgd_old, old_global_fields.strain.size+n, 1e-8); % eps
    end
    
    [equivalent_apparent_stress, deviatoric_apparent_stress] = compute_equivalent_stress(stress, back_stress, one_minus_internal_damage_pgd_old);
    [f_vp, row, col, row6] = evaluate_yield_function(equivalent_apparent_stress, isotropic_hardening, material.user_material.sigma_y);
    
    % Do not touch the first column that correspond to the initial conditions
    f_vp = f_vp(:, col ~= 1);
    col(col == 1) = [];
    
    if max(equivalent_apparent_stress(:)) > 2 * material.user_material.sigma_y
        local_fields = local_stage_vertical(numerical_model, old_global_fields);
        return
        %     stress = stress / 1.5;
    end
    
    inv_elasticity = material.inv_elasticity_tensor_diagonal(row6, row6);
    
    if nnz(row)
        
        old_damage = old_internal_damage(row, col);
        old_back_stress = back_stress(row6, col);
        
        normal_without_damage = evaluate_normal_without_damage(deviatoric_apparent_stress(row6, col), repelem(equivalent_apparent_stress(row, col), ncomp, 1));
        
        plastic_multiplier = evaluate_plastic_multiplier(material, f_vp);
        
        internal_plastic_strain_rate = sparse(length(row6), temporal_dof);
        internal_kinematic_rate = internal_plastic_strain_rate;
        internal_isotropic_rate = sparse(length(row), temporal_dof);
        damage_rate = internal_isotropic_rate;
        
        internal_plastic_strain_rate(:, col) = plastic_strain_evolution(repelem(plastic_multiplier, ncomp, 1), normal_without_damage, repelem(1-old_damage, ncomp, 1));
        internal_plastic_strain(row6, :) = internal_plastic_strain(row6, :) + temporal_cumulative_integration(internal_plastic_strain_rate, numerical_model.temporal);
        
        internal_kinematic_rate(:, col) = kinematic_hardening_evolution(material, repelem(plastic_multiplier, ncomp, 1), normal_without_damage, old_back_stress);
        internal_kinematic(row6, :) = internal_kinematic(row6, :) + temporal_cumulative_integration(internal_kinematic_rate, numerical_model.temporal);
        back_stress(row6, :) = compute_back_stress(material, internal_kinematic(row6, :));
        
        internal_isotropic_rate(:, col) = isotropic_hardening_evolution(plastic_multiplier);
        internal_isotropic(row, :) = internal_isotropic(row, :) + temporal_cumulative_integration(internal_isotropic_rate, numerical_model.temporal);
        isotropic_hardening(row, :) = compute_isotropic_hardening(material, internal_isotropic(row, :));
        
        Y = compute_energy_release_rate(stress(row6, col), inv_elasticity, 1-old_damage);
        damage_rate(:, col) = damage_evolution(material, Y, plastic_multiplier, 1-old_damage, 1);
        % evaluate_damage_evolution_condition(material, equivalent_stress(row, col), internal_isotropic(row, col))
        internal_damage(row, :) = internal_damage(row, :) + temporal_cumulative_integration(damage_rate, numerical_model.temporal);
        
        if max(internal_damage(:, end)) > 0.99
            warning('damage exceeds the maximum allowed damage');
            local_fields = [];
            return
            % damage=old_local_fields.internal_damage;
        end
    end
end

one_minus_internal_damage_pgd = repelem(1-internal_damage, ncomp, 1);
if numerical_model.solver_parameters.strain_pgd
    %     one_minus_internal_damage_pgd = full_to_pgd(one_minus_internal_damage_pgd,2*iter,1e-8); % eps
    one_minus_internal_damage_pgd = full_to_pgd(one_minus_internal_damage_pgd, old_global_fields.strain.size+n, 1e-8); % eps
end

elastic_strain = compute_elastic_strain(stress, material.inv_elasticity_tensor_diagonal, one_minus_internal_damage_pgd);

local_fields.strain = elastic_strain + internal_plastic_strain;
local_fields.stress = stress;

local_fields.back_stress = back_stress;
local_fields.isotropic_hardening = isotropic_hardening;
local_fields.internal_damage = internal_damage;

local_fields.initial_values.internal_plastic_strain = internal_plastic_strain(:, end);
local_fields.initial_values.internal_kinematic = internal_kinematic(:, end);
local_fields.initial_values.internal_isotropic = internal_isotropic(:, end);
local_fields.initial_values.internal_damage = internal_damage(:, end);

if numerical_model.solver_parameters.strain_pgd
    % TODO: compare the error with nr
    local_fields.strain = full_to_pgd(local_fields.strain, old_global_fields.strain.size+n, 1e-8); % eps
    %     local_fields.strain = full_to_pgd(local_fields.strain,2*iter,1e-8); % eps
    %     old_global_fields.strain.normalise_spatial_modes;
    %     strain = pgd(local_fields.strain * old_global_fields.strain.temporal_modes,[],old_global_fields.strain.temporal_modes);
    %     local_fields.strain = strain + full_to_pgd(local_fields.strain - strain,2);
    %     local_fields.strain = pgd(old_global_fields.strain.spatial_modes, [], (old_global_fields.strain.spatial_modes' * local_fields.strain)');
end

local_fields.minus_residual = local_fields.global_search_direction * (local_fields.strain - old_global_fields.strain);
% local_fields.minus_residual = local_fields.global_search_direction * (local_fields.strain - old_global_fields.strain) - (local_fields.stress - old_global_fields.stress);

% initial_values = old_global_fields.initial_values;
% stress = full(old_global_fields.stress);
% back_stress = old_global_fields.back_stress;
% isotropic_hardening = old_global_fields.isotropic_hardening;
% old_internal_damage = old_global_fields.internal_damage;

end

% full_to_pgd(local_fields.back_stress,20,1e-8)
% full_to_pgd(local_fields.back_stress,20,1e-8)
% full_to_pgd(local_fields.strain,20,1e-8)
% decomposin the internal variables is possible but requires more modes due
% to the involved nonlinearity

% use it only with
% [equivalent_apparent_stress, deviatoric_apparent_stress, equivalent_stress] = compute_equivalent_stress(stress, back_stress, repelem(old_internal_damage, ncomp, 1));
% [f_vp, row, col, row6] = evaluate_yield_function(equivalent_apparent_stress, isotropic_hardening, material.user_material.sigma_y);
