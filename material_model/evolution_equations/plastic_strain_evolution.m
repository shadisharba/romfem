function plastic_strain_rate = plastic_strain_evolution(plastic_multiplier, normal_without_damage, damage)
plastic_strain_rate = plastic_multiplier .* normal_without_damage ./ (1 - damage);
end