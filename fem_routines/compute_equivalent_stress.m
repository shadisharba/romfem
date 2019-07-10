function [equivalent_apparent_stress, deviatoric_apparent_stress] = compute_equivalent_stress(stress, back_stress, one_minus_damage)
% deviatoric_stress = deviatoric(stress);
% equivalent_stress = sqrt(3/2.*full(double_dot_product(deviatoric_stress, deviatoric_stress)));
deviatoric_apparent_stress = deviatoric(stress) ./ one_minus_damage - back_stress;
equivalent_apparent_stress = sqrt(1.5.*double_dot_product(deviatoric_apparent_stress, deviatoric_apparent_stress));
end
