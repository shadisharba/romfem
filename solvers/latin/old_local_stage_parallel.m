function local_fields = local_stage_parallel(numerical_model, global_fields)
error('this function is not maintained')

material = numerical_model.material;
ncomp = numerical_model.mesh.quadrature_dof;

dim_in = size(global_fields.stress);
ngp = (dim_in(1) / ncomp);
ntp = (dim_in(2));
dim = [ncomp, dim_in(1) / ncomp, dim_in(2)];
dim_d = [1, dim_in(1) / ncomp, dim_in(2)];

D_full;
sigma_full = mat2cell(global_fields.stress, ncomp*ones(1, ngp), ones(1, ntp));
beta_full = mat2cell(global_fields.stress, ncomp*ones(1, ngp), ones(1, ntp));

d_eps_p = mat2cell(global_fields.stress*0, ncomp*ones(1, ngp), ones(1, ntp));
d_alpha = mat2cell(global_fields.stress*0, ncomp*ones(1, ngp), ones(1, ntp));
d_D = D_full;

cc = material.inv_elasticity_tensor;
parfor i = 1:ngp
    for j = 1:ntp
        D = D_full{i, j};
        sigma = sigma_full{i, j};
        beta = beta_full{i, j};
        
        Y = 0.5 * sigma' * (cc * sigma) ./ (1 - D).^2;
        
        tau = (sigma - beta);
        tau = tau - sum(tau(1:3)) * [1, 1, 1, 0, 0, 0]' / 3;
        von_mises = sqrt(3/2) * norm(tau);
        
        f_vp = evaluate_yield_function(von_mises, beta, D, material);
        f_d = evaluate_damage_yield_function(Y, material);
        
        if f_vp || f_d
            N_tild = 1.5 * tau ./ (von_mises * (1 - D));
            
            d_plastic_multip_dof = material.user_material.k * f_vp.^material.user_material.n;
            
            d_eps_p{i, j} = d_plastic_multip_dof .* N_tild;
            d_alpha{i, j} = d_plastic_multip_dof .* (N_tild - (material.gamma / material.user_material.c) * beta);
            d_D{i, j} = material.kd * (f_d.^material.nd);
        end
    end
end

internal_plastic_strain = global_fields.initial_values.internal_plastic_strain + integration(cell2mat(d_eps_p), numerical_model.temporal);
internal_kinematic = global_fields.initial_values.internal_kinematic + integration(cell2mat(d_alpha), numerical_model.temporal);
D = global_fields.initial_values.internal_damage + integration(cell2mat(d_D), numerical_model.temporal);
D_dof = repelem(D, ncomp, 1);
eps_e = compute_elastic_strain(global_fields, material, D_dof);

% lF_Y.delta_D = D(:, end) - D(:, 1);

local_fields = {lF_S, lF_X, [], lF_Y};
% local_fields{1}.delta_p = 0;
% local_fields{1}.p_mu_end = internal_plastic_strain(:, end);

local_fields{1}.initial_values.internal_plastic_strain = internal_plastic_strain(:, end);
local_fields{1}.initial_values.internal_kinematic = internal_kinematic(:, end);


global global_search_direction alpha_global;

alpha_global = 0.41 * (1 - max(D(:, end)));
% alpha_global = 0.2;
global_search_direction = alpha_global .* material.elasticity_tensor_diagonal;

local_fields{1}.minus_residual = (material.elasticity_tensor_diagonal * (lF_S.strain - global_fields.strain) - (lF_S.stress - global_fields.stress));

end
