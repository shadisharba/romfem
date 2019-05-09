function internal_kinematic = compute_internal_kinematic(material, back_stress)
internal_kinematic = back_stress / material.user_material.c;
end