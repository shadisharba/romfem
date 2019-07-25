function [f_vp, row, col, row6] = evaluate_yield_function(equivalent_apparent_stress, isotropic_hardening, sigma_y)
f_vp = max(0, equivalent_apparent_stress-isotropic_hardening-sigma_y);

[row, col] = find(f_vp);
row = unique(row);
col = unique(col);

tensor_components = 6;
row6 = [row * tensor_components - [(tensor_components - 1):-1:0]]';
row6 = row6(:);

f_vp = f_vp(row, col);
end

% crack closure
% one_min_D = (1-D(i,j));
% one_min_hD = (1-h * D(i,j));
