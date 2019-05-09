function stress = compute_stress(elastic_strain, elasticity_tensor, damage)
stress = elasticity_tensor * (elastic_strain .* (1 - damage));
end
% crack closure may be included here
