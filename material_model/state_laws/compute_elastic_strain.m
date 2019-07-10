function elastic_strain = compute_elastic_strain(stress, inv_elasticity_tensor_diagonal, one_minus_damage)
elastic_strain = inv_elasticity_tensor_diagonal * (stress ./ one_minus_damage);
end
% crack closure may be included here
