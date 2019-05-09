function [V, S, L] = randomised_svd_row_col(A, k)
error('this function is not maintained');
n = size(A, 2);

Q = randn(n, min(k+5, n));

approximate_basis = A * Q;
[E1, ~, ~] = qr(approximate_basis, 0); % orthonormalise approximate_basis

A_col_reduced = E1' * A; % less rows

Q = randn(min(k+5, n), min(k+5, n));

approximate_basis = A_col_reduced' * Q;
[E2, ~, ~] = qr(approximate_basis, 0); % orthonormalise approximate_basis

A_row_reduced = A_col_reduced * E2; % less rows

[V_t, S, L_t] = svds(A_row_reduced, k);

V = E1 * V_t;
L = E2 * L_t;
end