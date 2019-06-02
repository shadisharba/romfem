% Posted by Cleve Moler, October 27, 2016
% downloaded from: https://blogs.mathworks.com/cleve/2016/10/27/apologies-to-gram-schmidt/

function [Q, R] = gs_stewart(X)
% Classical Gram-Schmidt.  [Q,R] = gs(X);
% G. W. Stewart, "Matrix Algorithms, Volume 1", SIAM, 1998.

[n, p] = size(X);
Q = zeros(n, p);
R = zeros(p, p);
for k = 1:p
    Q(:, k) = X(:, k);
    if k ~= 1
        R(1:k-1, k) = Q(:, 1:k-1)' * Q(:, k);
        Q(:, k) = Q(:, k) - Q(:, 1:k-1) * R(1:k-1, k);
    end
    R(k, k) = norm(Q(:, k));
    Q(:, k) = Q(:, k) / R(k, k);
end
end