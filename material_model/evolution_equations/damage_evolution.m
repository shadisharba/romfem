function damage_rate = damage_evolution(material, Y, plastic_multiplier, old_damage, damage_condition)
damage_rate = ((Y ./ material.user_material.S).^material.user_material.s) .* plastic_multiplier ./ (1 - old_damage) .* damage_condition;
end