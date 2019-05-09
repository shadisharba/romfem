function normal = evaluate_normal_without_damage(deviatoric_apparent_stress,equivalent_apparent_stress)
normal = 1.5 * deviatoric_apparent_stress ./ equivalent_apparent_stress;
normal(~isfinite(normal)) = 0;
end