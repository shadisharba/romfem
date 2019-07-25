function local_fields = local_stage_horizontal(numerical_model, old_global_fields, iter)

number_of_local_modes = old_global_fields.strain.size + 1; % 2*iter old_global_fields.strain.size+n
rejection_tol = 1e-8;

material = numerical_model.material;
tensor_components = numerical_model.mesh.tensor_components;
temporal_dof = numerical_model.temporal.dof;
number_of_quadrature = numerical_model.mesh.number_of_quadrature;

local_fields.global_search_direction = numerical_model.solver_parameters.elasticity_reduction_factor .* material.elasticity_tensor_diagonal;

back_stress = old_global_fields.back_stress;
isotropic_hardening = old_global_fields.isotropic_hardening;
one_minus_damage = repelem(1-old_global_fields.internal_damage, tensor_components, 1);

if numerical_model.solver_parameters.local_stage_pgd
    stress = old_global_fields.stress;
    one_minus_damage = full_to_pgd(one_minus_damage, 1);
else
    stress = full(old_global_fields.stress);
end

if iter <= numerical_model.solver_parameters.local_stage_neural_networks

    input = vertcat(reshape(full(stress), [tensor_components, number_of_quadrature * temporal_dof]), ...
        reshape(full(back_stress), [tensor_components, number_of_quadrature * temporal_dof]), ...
        reshape(full(isotropic_hardening), [1, number_of_quadrature * temporal_dof]), ...
        reshape(full(old_global_fields.internal_damage), [1, number_of_quadrature * temporal_dof]));

    y = neural_constitutive_model_00_mat(input);

    internal_plastic_strain_rate = abs(reshape(y(1:6, :), [tensor_components * number_of_quadrature, temporal_dof]));
    internal_kinematic_rate = reshape(y(7:12, :), [tensor_components * number_of_quadrature, temporal_dof]);
    internal_isotropic_rate = abs(reshape(y(13, :), [number_of_quadrature, temporal_dof]));
    internal_damage_rate = abs(reshape(y(14, :), [number_of_quadrature, temporal_dof]));

    internal_plastic_strain = old_global_fields.initial_values.internal_plastic_strain + temporal_cumulative_integration(internal_plastic_strain_rate, numerical_model.temporal);

    internal_kinematic = old_global_fields.initial_values.internal_kinematic + temporal_cumulative_integration(internal_kinematic_rate, numerical_model.temporal);
    back_stress = compute_back_stress(material, internal_kinematic);

    internal_isotropic = old_global_fields.initial_values.internal_isotropic + temporal_cumulative_integration(internal_isotropic_rate, numerical_model.temporal);
    isotropic_hardening = compute_isotropic_hardening(material, internal_isotropic);

    internal_damage = old_global_fields.initial_values.internal_damage + temporal_cumulative_integration(internal_damage_rate, numerical_model.temporal);


else
    internal_plastic_strain = sparse(tensor_components * number_of_quadrature, temporal_dof);
    internal_kinematic = sparse(tensor_components * number_of_quadrature, temporal_dof);
    internal_isotropic = sparse(repmat(old_global_fields.initial_values.internal_isotropic, [1, temporal_dof]));
    internal_damage = sparse(repmat(old_global_fields.initial_values.internal_damage, [1, temporal_dof]));

    [equivalent_apparent_stress, deviatoric_apparent_stress] = compute_equivalent_stress(stress, back_stress, one_minus_damage);

    if max(equivalent_apparent_stress(:)) > 2 * material.user_material.sigma_y
      if numerical_model.solver_parameters.local_stage_pgd
        error('this is not tested yet');
      end
      local_fields = local_stage_vertical(numerical_model, old_global_fields);
      return
      %     stress = stress / 1.5;
    end

    [f_vp, row, col, row6] = evaluate_yield_function(equivalent_apparent_stress, isotropic_hardening, material.user_material.sigma_y);
    % Do not touch the first column that correspond to the initial conditions
    f_vp = f_vp(:, col ~= 1);
    col(col == 1) = [];

    inv_elasticity = material.inv_elasticity_tensor_diagonal(row6, row6);

    if nnz(row)

        old_one_minus_damage = one_minus_damage(row, col);
        old_back_stress = back_stress(row6, col);

        normal_without_damage = evaluate_normal_without_damage(deviatoric_apparent_stress(row6, col), repelem(equivalent_apparent_stress(row, col), tensor_components, 1));

        plastic_multiplier = evaluate_plastic_multiplier(material, f_vp);

        internal_plastic_strain_rate = sparse(length(row6), temporal_dof);
        internal_kinematic_rate = internal_plastic_strain_rate;
        internal_isotropic_rate = sparse(length(row), temporal_dof);
        internal_damage_rate = internal_isotropic_rate;

        internal_plastic_strain_rate(:, col) = plastic_strain_evolution(repelem(plastic_multiplier, tensor_components, 1), normal_without_damage, repelem(old_one_minus_damage, tensor_components, 1));
        internal_plastic_strain(row6, :) = old_global_fields.initial_values.internal_plastic_strain(row6, :) + temporal_cumulative_integration(internal_plastic_strain_rate, numerical_model.temporal);

        internal_kinematic_rate(:, col) = kinematic_hardening_evolution(material, repelem(plastic_multiplier, tensor_components, 1), normal_without_damage, old_back_stress);
        internal_kinematic(row6, :) = old_global_fields.initial_values.internal_kinematic(row6, :) + temporal_cumulative_integration(internal_kinematic_rate, numerical_model.temporal);
        back_stress(row6, :) = compute_back_stress(material, internal_kinematic(row6, :));

        internal_isotropic_rate(:, col) = isotropic_hardening_evolution(plastic_multiplier);
        internal_isotropic(row, :) = old_global_fields.initial_values.internal_isotropic(row, :) + temporal_cumulative_integration(internal_isotropic_rate, numerical_model.temporal);
        isotropic_hardening(row, :) = compute_isotropic_hardening(material, internal_isotropic(row, :));

        Y = compute_energy_release_rate(stress(row6, col), inv_elasticity, old_one_minus_damage);
        internal_damage_rate(:, col) = damage_evolution(material, Y, plastic_multiplier, old_one_minus_damage, 1);
        % evaluate_damage_evolution_condition(material, equivalent_stress(row, col), internal_isotropic(row, col))
        internal_damage(row, :) = old_global_fields.initial_values.internal_damage(row, :) + temporal_cumulative_integration(internal_damage_rate, numerical_model.temporal);

        if max(internal_damage(:, end)) > 0.99
            warning('damage exceeds the maximum allowed damage');
            local_fields = [];
            return
            % damage=old_local_fields.internal_damage;
        end
    end
end

elastic_strain = compute_elastic_strain(stress, material.inv_elasticity_tensor_diagonal, one_minus_damage);

local_fields.strain = elastic_strain + internal_plastic_strain;
local_fields.stress = stress;

local_fields.back_stress = back_stress;
local_fields.isotropic_hardening = isotropic_hardening;
local_fields.internal_damage = internal_damage;

local_fields.initial_values.internal_plastic_strain = internal_plastic_strain(:, end);
local_fields.initial_values.internal_kinematic = internal_kinematic(:, end);
local_fields.initial_values.internal_isotropic = internal_isotropic(:, end);
local_fields.initial_values.internal_damage = internal_damage(:, end);

if numerical_model.solver_parameters.local_stage_pgd
    local_fields.strain = full_to_pgd(local_fields.strain, number_of_local_modes, rejection_tol);
end

local_fields.minus_residual = local_fields.global_search_direction * (local_fields.strain - old_global_fields.strain);
% local_fields.minus_residual = local_fields.global_search_direction * (local_fields.strain - old_global_fields.strain) - (local_fields.stress - old_global_fields.stress);

%% Neural network data
% ! rm -rf output_nn_datat/neural_network_training_*

%{
nn.stress = local_fields.stress;
nn.back_stress = local_fields.back_stress;
nn.isotropic_hardening = local_fields.isotropic_hardening;
nn.internal_damage = local_fields.internal_damage;

nn.internal_plastic_strain_rate = sparse(tensor_components * number_of_quadrature, temporal_dof);
nn.internal_kinematic_rate = nn.internal_plastic_strain_rate;
nn.internal_isotropic_rate = sparse(number_of_quadrature, temporal_dof);
nn.internal_damage_rate = nn.internal_isotropic_rate;

nn.internal_plastic_strain_rate(row6, :) = internal_plastic_strain_rate;
nn.internal_kinematic_rate(row6, :)=internal_kinematic_rate;
nn.internal_isotropic_rate(row, :)=internal_isotropic_rate;
nn.internal_damage_rate(row, :)=internal_damage_rate;

nn.gp = numerical_model.mesh.number_of_quadrature;
nn.tensor_components = numerical_model.mesh.tensor_components;
nn.n_t = numerical_model.temporal.dof;

cycle = 1;
file_name = sprintf('output_nn_datat/neural_network_training_%02d_%d.mat',cycle,iter);
while exist(file_name, 'file')
    cycle = cycle + 1;
    file_name = sprintf('output_nn_datat/neural_network_training_%02d_%d.mat',cycle,iter);
end
save(file_name,'nn')
%}

end