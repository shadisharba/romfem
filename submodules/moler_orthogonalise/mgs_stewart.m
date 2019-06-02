% Posted by Cleve Moler, October 17, 2016
% downloaded from: https://blogs.mathworks.com/cleve/2016/10/17/compare-gram-schmidt-and-householder-orthogonalization-algorithms-2/

function [Q, R] = mgs_stewart(X)
% Modified Gram-Schmidt.  [Q,R] = mgs(X);
% G. W. Stewart, "Matrix Algorithms, Volume 1", SIAM, 1998.

[n, p] = size(X);
Q = zeros(n, p);
R = zeros(p, p);
for k = 1:p
    Q(:, k) = X(:, k);
    for i = 1:k - 1
        R(i, k) = Q(:, i)' * Q(:, k);
        Q(:, k) = Q(:, k) - R(i, k) * Q(:, i);
    end
    R(k, k) = norm(Q(:, k))';
    Q(:, k) = Q(:, k) / R(k, k);
end
end