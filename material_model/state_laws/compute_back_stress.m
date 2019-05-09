function back_stress = compute_back_stress(material, internal_kinematic)
back_stress = material.user_material.c * internal_kinematic;
end