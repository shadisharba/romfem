function [q,r] = rqr_decomp(A,k)

n = size(A, 2);

random_mat = randn(n, min(k+5, n));

approximate_basis = A * random_mat;
[E, ~, ~] = svd(approximate_basis, 'econ'); % orthonormalise approximate_basis

A_restricted = E' * A; % less rows
[q_restricted, r] = qr_decomp(A_restricted);

q = E * q_restricted;
end
