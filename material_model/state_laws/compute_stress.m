function stress = compute_stress(elastic_strain, elasticity_tensor, one_minus_damage)
stress = elasticity_tensor * (elastic_strain .* one_minus_damage);
end
% crack closure may be included here
