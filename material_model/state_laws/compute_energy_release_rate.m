function energy_release_rate = compute_energy_release_rate(stress, inv_elasticity_tensor_diagonal, damage)
energy_release_rate = 0.5 * double_dot_product(stress, inv_elasticity_tensor_diagonal*stress) ./ (1 - damage).^2;
end
% crack closure may be included here