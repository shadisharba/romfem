function isotropic_hardening = compute_isotropic_hardening(material, internal_isotropic)
isotropic_hardening = material.user_material.r_inf * (1 - exp(-material.user_material.r_exp*internal_isotropic));
end