function elastic_strain = compute_elastic_strain(stress, inv_elasticity_tensor_diagonal, one_minusdamage)
elastic_strain = inv_elasticity_tensor_diagonal * (stress ./ one_minusdamage);
end
% crack closure may be included here
