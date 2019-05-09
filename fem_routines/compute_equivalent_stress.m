function [equivalent_apparent_stress, deviatoric_apparent_stress, equivalent_stress] = compute_equivalent_stress(stress, back_stress, damage)
deviatoric_stress = deviatoric(stress);
equivalent_stress = sqrt(3/2.*double_dot_product(deviatoric_stress, deviatoric_stress));

deviatoric_apparent_stress = deviatoric_stress ./ (1 - damage) - back_stress;
equivalent_apparent_stress = sqrt(3/2.*double_dot_product(deviatoric_apparent_stress, deviatoric_apparent_stress));
end
