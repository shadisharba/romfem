function elastic_strain = compute_elastic_strain(stress, inv_elasticity_tensor_diagonal, damage)
elastic_strain = inv_elasticity_tensor_diagonal * (stress ./ (1 - damage));
end
% crack closure may be included here
