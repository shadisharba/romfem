function plastic_strain_rate = plastic_strain_evolution(plastic_multiplier, normal_without_damage, one_minus_damage)
plastic_strain_rate = plastic_multiplier .* normal_without_damage ./ one_minus_damage;
end