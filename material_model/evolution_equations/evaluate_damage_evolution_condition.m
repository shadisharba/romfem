function damage_evolution_condition = evaluate_damage_evolution_condition(material, equivalent_stress, internal_isotropic)
pd_nominator = material.user_material.sigma_u - material.user_material.sigma_inf;
delta_stress_eq = (max(equivalent_stress, [], 2) + min(equivalent_stress, [], 2)) / 2; % maximum over a cycle (over the temporal domain)
damage_evolution_condition = (internal_isotropic >= (material.user_material.eps_p_d .* (pd_nominator ./ (delta_stress_eq - material.user_material.sigma_inf)).^material.user_material.m));
end

% TODO: the damage threshold can be changed to depend on the stored energy w_s
% \cite{lemaitre2005engineering} [page: 29]
