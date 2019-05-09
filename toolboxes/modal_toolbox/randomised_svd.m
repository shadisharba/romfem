function [V, S, L] = randomised_svd(A, k)

n = size(A, 2);

random_mat = randn(n, min(k+5, n));

approximate_basis = A * random_mat;
[E, ~, ~] = svd(approximate_basis, 'econ'); % orthonormalise approximate_basis

A_restricted = E' * A; % less rows
[V_t, S, L] = svds(A_restricted, k);

V = E * V_t;

end

% [V_t, S, L] = svd(A_reduced, 'econ');

% qr(Y,0)
% f=@() orth(Y);
% g=@() svd(Y, 'econ');
% timeit(f)
% timeit(g,3)
