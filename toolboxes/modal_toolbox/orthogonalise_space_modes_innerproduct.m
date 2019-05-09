function [orth_space_modes, updated_time_modes] = orthogonalise_space_modes_innerproduct(space_modes, time_modes, type, inner_product_L)
% L: lower triangular matrix of the inner product metric M = L*L'
error('this function is not maintained');

space_modes_l = inner_product_L' * space_modes;
[orth_space_modes_l, updated_time_modes] = orthogonalise_space_modes(space_modes_l, time_modes, type);
orth_space_modes = (inner_product_L' \ orth_space_modes_l);

%% check the orthogonality
% diag(U'*M*U)
end

%         % better weight for the time functions when using an energy inner product

%     case 'svd_inner_product'
%         % SVD
%         % input_solution is multiplied by inner_product_L' in order to
%         % maintain the original solution when multiplying the space and
%         % time modes
