function kinematic_hardening_rate = kinematic_hardening_evolution(material, plastic_multiplier, normal_without_damage, back_stress)
kinematic_hardening_rate = plastic_multiplier .* (normal_without_damage - (material.user_material.a / material.user_material.c) * back_stress);
end