function local_fields = update_internal_variables(numerical_model, strain, initial_values, time_step, solver_parameters, compute_tangent)
% TODO: this update is sensitive to the time step, which is normal for the current material model but recheck the implementation!

material = numerical_model.material;
if compute_tangent
    local_fields.algorithmic_tangent_diagonal = material.elasticity_tensor_diagonal;
end

ncomp = numerical_model.mesh.quadrature_dof;

internal_plastic_strain = initial_values.internal_plastic_strain;
internal_isotropic = initial_values.internal_isotropic;
internal_kinematic = initial_values.internal_kinematic;
internal_damage = initial_values.internal_damage;

back_stress = compute_back_stress(material, internal_kinematic);
isotropic_hardening = compute_isotropic_hardening(material, internal_isotropic);

repelem_memoized = memoize(@repelem);
elastic_strain = strain - internal_plastic_strain;
stress = compute_stress(elastic_strain, material.elasticity_tensor_diagonal, repelem_memoized(1-internal_damage, ncomp));

[f_vp, row, ~, row6] = evaluate_yield_function(compute_equivalent_stress(stress, back_stress, repelem_memoized(1-internal_damage, ncomp, 1)), isotropic_hardening, material.user_material.sigma_y);

if nnz(row)
    delta_t = numerical_model.temporal.mesh(time_step) - numerical_model.temporal.mesh(time_step-1);
    
    row_6_range = @(idx) row6(1+ncomp*(idx - 1):idx*ncomp);
    row_range = @(idx) row(idx);
    
    stress_trial = @(idx) stress(row_6_range(idx));
    eps_e_trial = @(idx) elastic_strain(row_6_range(idx));
    old_eps_p = @(idx) internal_plastic_strain(row_6_range(idx));
    old_back_stres = @(idx) back_stress(row_6_range(idx));
    old_isotropic_hardening = @(idx) isotropic_hardening(row_range(idx));
    old_internal_isotropic = @(idx) internal_isotropic(row_range(idx));
    old_damage = @(idx) internal_damage(row_range(idx));
    
    for idx = 1:length(f_vp)
        
        y = [0; stress_trial(idx); old_back_stres(idx); old_isotropic_hardening(idx); old_damage(idx)];
        
        % options = optimoptions('fsolve', 'Display', 'off', 'TolFun', 1e-15, 'TolX', 1e-15);
        % [y, ~, ~, ~, jacobian] = fsolve(@(y) constitutive_model(y, material, delta_t, idx, eps_e_trial, old_internal_isotropic, old_back_stres, old_damage), y, options);
        
        iter = 0;
        r = 1;
        delta_y = 1;
        while max(norm(r), norm(delta_y)) > solver_parameters.convergence_tol && iter < solver_parameters.max_iter
            [r, jacobian] = constitutive_model(y, material, delta_t, idx, eps_e_trial, old_internal_isotropic, old_back_stres, old_damage);
            delta_y = -jacobian \ r;
            y = y + delta_y;
            iter = iter + 1;
        end
        
        stress(row_6_range(idx)) = y(2:7);
        back_stress(row_6_range(idx)) = y(8:13);
        isotropic_hardening(row_range(idx)) = y(14);
        internal_damage(row_range(idx)) = y(15);
        
        internal_plastic_strain(row_6_range(idx)) = old_eps_p(idx) + plastic_strain_evolution(y(1), normal_tilde(stress(row_6_range(idx)), back_stress(row_6_range(idx)), internal_damage(row_range(idx))), internal_damage(row_range(idx)));
        internal_isotropic(row_range(idx)) = old_internal_isotropic(idx) + isotropic_hardening_evolution(y(1));
        internal_kinematic(row_6_range(idx)) = compute_internal_kinematic(material, back_stress(row_6_range(idx)));
    end
    if iter == solver_parameters.max_iter
        warning('check the update_of_internal_variables');
    end
    if compute_tangent
        inv_jacobian = inv(jacobian);
        local_fields.algorithmic_tangent_diagonal(row_6_range(idx), row_6_range(idx)) = inv_jacobian(2:7, 2:7) * material.elasticity_tensor * (1 - internal_damage(row_range(idx)));
    end
end

local_fields.stress = stress;
local_fields.strain = strain;
local_fields.back_stress = back_stress;
local_fields.isotropic_hardening = isotropic_hardening;
local_fields.internal_damage = internal_damage;

local_fields.initial_values.internal_plastic_strain = internal_plastic_strain;
local_fields.initial_values.internal_isotropic = internal_isotropic;
local_fields.initial_values.internal_kinematic = internal_kinematic;
local_fields.initial_values.internal_damage = internal_damage;

end

function [f, jacobian] = constitutive_model(y, material, delta_t, idx, eps_e_trial, old_internal_isotropic, old_back_stres, old_damage)
delta_plastic_multiplier = y(1);
stress = y(2:7);
back_stress = y(8:13);
isotropic_hardening = y(14);
internal_damage = y(15);

N_tilde = normal_tilde(stress, back_stress, internal_damage);
sigma_dev = deviatoric(stress);
tau_dev = sigma_dev / (1 - internal_damage) - back_stress;

internal_isotropic_trial = @(idx, delta_plastic_multiplier) old_internal_isotropic(idx) + isotropic_hardening_evolution(delta_plastic_multiplier);

A_lambda_f = -delta_t * (material.user_material.n / material.user_material.k) * (evaluate_yield_function(compute_equivalent_stress(stress, back_stress, 1-internal_damage), isotropic_hardening, material.user_material.sigma_y) / material.user_material.k)^(material.user_material.n - 1);
d_ntilde_d_sigma = (sqrt(1.5) / (1 - internal_damage) * (deviatoric_identity(6) / norm(tau_dev) - (tau_dev * tau_dev') / (norm(tau_dev)^3)));
d_ntilde_d_beta = -(sqrt(1.5) * (eye(6) / norm(tau_dev) - (tau_dev * tau_dev') / (norm(tau_dev)^3)));
d_ntilde_d_damage = sqrt(1.5) / (1 - internal_damage)^2 * (sigma_dev / norm(tau_dev) - ((tau_dev * tau_dev') * sigma_dev) / (norm(tau_dev)^3));
damage_condition = evaluate_damage_evolution_condition(material, sqrt(3/2*double_dot_product(sigma_dev, sigma_dev)), internal_isotropic_trial(idx, delta_plastic_multiplier));
A_d_lambda = -((compute_energy_release_rate(stress, material.inv_elasticity_tensor, internal_damage) / material.user_material.S).^material.user_material.s) ./ (1 - internal_damage) * damage_condition;

f = [delta_plastic_multiplier - delta_t * evaluate_plastic_multiplier(material, evaluate_yield_function(compute_equivalent_stress(stress, back_stress, 1-internal_damage), isotropic_hardening, material.user_material.sigma_y)); ...
    stress - compute_stress(eps_e_trial(idx)-plastic_strain_evolution(delta_plastic_multiplier, N_tilde, internal_damage), material.elasticity_tensor, 1-internal_damage); ...
    back_stress - old_back_stres(idx) - compute_back_stress(material, kinematic_hardening_evolution(material, delta_plastic_multiplier, N_tilde, back_stress)); ...
    isotropic_hardening - compute_isotropic_hardening(material, internal_isotropic_trial(idx, delta_plastic_multiplier)); ...
    internal_damage - old_damage(idx) - damage_evolution(material, compute_energy_release_rate(stress, material.inv_elasticity_tensor, internal_damage), delta_plastic_multiplier, internal_damage, damage_condition)];



jacobian = speye(15);
jacobian(1, 2:7) = A_lambda_f * N_tilde ./ (1 - internal_damage);
jacobian(1, 8:13) = -A_lambda_f * N_tilde;
jacobian(1, 14) = -A_lambda_f;
jacobian(1, 15) = A_lambda_f * N_tilde' * sigma_dev / (1 - internal_damage)^2;
jacobian(2:7, 1) = material.elasticity_tensor * N_tilde;
jacobian(2:7, 2:7) = jacobian(2:7, 2:7) + delta_plastic_multiplier * material.elasticity_tensor * d_ntilde_d_sigma;
jacobian(2:7, 8:13) = delta_plastic_multiplier * material.elasticity_tensor * d_ntilde_d_beta;
jacobian(2:7, 15) = material.elasticity_tensor * (eps_e_trial(idx) + delta_plastic_multiplier * d_ntilde_d_damage);
jacobian(8:13, 1) = -material.user_material.c * N_tilde + material.user_material.a * back_stress;
jacobian(8:13, 2:7) = -material.user_material.c * delta_plastic_multiplier * d_ntilde_d_sigma;
jacobian(8:13, 8:13) = jacobian(8:13, 8:13) * (1 + material.user_material.a * delta_plastic_multiplier) - material.user_material.c * delta_plastic_multiplier * d_ntilde_d_beta;
jacobian(8:13, 15) = -material.user_material.c * delta_plastic_multiplier * d_ntilde_d_damage;
jacobian(14, 1) = -material.user_material.r_exp * material.user_material.r_inf * exp(-material.user_material.r_exp*(internal_isotropic_trial(idx, delta_plastic_multiplier)));
jacobian(15, 1) = A_d_lambda;
jacobian(15) = jacobian(15) + delta_plastic_multiplier * A_d_lambda ./ (1 - internal_damage);
end

function normal_tilde = normal_tilde(sigma, beta, D)
[equivalent_apparent_stress, deviatoric_apparent_stress, ~] = compute_equivalent_stress(sigma, beta, 1-D);

normal_tilde = evaluate_normal_without_damage(deviatoric_apparent_stress, equivalent_apparent_stress);
end