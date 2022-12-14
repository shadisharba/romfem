% Posted by Cleve Moler, October 3, 2016
% downloaded from: https://blogs.mathworks.com/cleve/2016/10/03/householder-reflections-and-the-qr-decomposition/

function Z = house_apply_transpose(U, X)
% Apply Householder transposed reflections.
% Z = house_apply(U,X), with U from house_qr
% computes Q'*X without actually computing Q'.

H = @(u, x) x - u * (u' * x);
Z = X;
[~, n] = size(U);
for j = 1:n
    Z = H(U(:, j), Z);
end
end