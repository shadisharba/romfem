function [equivalent_strain, deviatoric_strain] = compute_equivalent_strain(strain)
deviatoric_strain = deviatoric(strain);
equivalent_strain = sqrt(2/3*double_dot_product(deviatoric_strain, deviatoric_strain));
end
