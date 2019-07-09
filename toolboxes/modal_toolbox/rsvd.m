%% randomised_svd
function [orth_space_modes, singular_values, updated_time_modes] = rsvd(A, k, rejection_tol)

n = size(A, 2);

random_mat = randn(n, min(k+5, n));

approximate_basis = A * random_mat;
[E, ~, ~] = svd(approximate_basis, 'econ'); % orthonormalise approximate_basis

A_restricted = E' * A; % less rows
[V_t, singular_values, updated_time_modes] = svds(A_restricted, k);

orth_space_modes = E * V_t;

if exist('rejection_tol','var') && ~isempty(rejection_tol)
    score_modes = (diag(singular_values) / singular_values(1));
    idx_del = score_modes < rejection_tol;
    if sum(idx_del)
        [orth_space_modes,singular_values,updated_time_modes] = compress_modes(orth_space_modes,singular_values,updated_time_modes,idx_del);
    end
end

end

% [V_t, S, L] = svd(A_reduced, 'econ');

% qr(Y,0)
% f=@() orth(Y);
% g=@() svd(Y, 'econ');
% timeit(f)
% timeit(g,3)

%% randomised_svd_row_col
% function [V, S, L] = randomised_svd_row_col(A, k)
% error('this function is not maintained');
% n = size(A, 2);
% 
% Q = randn(n, min(k+5, n));
% 
% approximate_basis = A * Q;
% [E1, ~, ~] = qr(approximate_basis, 0); % orthonormalise approximate_basis
% 
% A_col_reduced = E1' * A; % less rows
% 
% Q = randn(min(k+5, n), min(k+5, n));
% 
% approximate_basis = A_col_reduced' * Q;
% [E2, ~, ~] = qr(approximate_basis, 0); % orthonormalise approximate_basis
% 
% A_row_reduced = A_col_reduced * E2; % less rows
% 
% [V_t, S, L_t] = svds(A_row_reduced, k);
% 
% V = E1 * V_t;
% L = E2 * L_t;
% end