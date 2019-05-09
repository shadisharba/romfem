function [U, R] = house_qr_stewart(A)
% Householder reflections for QR decomposition.
% [U,R] = house_qr(A) returns
% U, the reflector generators for use by house_apply.
% R, the upper triangular factor.
H = @(u, x) x - u * (u' * x);
[m, n] = size(A);
U = zeros(m, n);
R = A;
for j = 1:min(m, n)
    u = house_gen(R(j:m, j));
    U(j:m, j) = u;
    R(j:m, j:n) = H(u, R(j:m, j:n));
    R(j+1:m, j) = 0;
end
end

function [u, nu] = house_gen(x)
% [u,nu] = housegen(x)
% Generate Householder reflection.
% G. W. Stewart, "Matrix Algorithms, Volume 1", SIAM, 1998.
% [u,nu] = housegen(x).
% H = I - uu' with Hx = -+ nu e_1
%    returns nu = norm(x).
u = x;
nu = norm(x);
if nu == 0
    u(1) = sqrt(2);
    return
end
u = x / nu;
if u(1) >= 0
    u(1) = u(1) + 1;
    nu = -nu;
else
    u(1) = u(1) - 1;
end
u = u / sqrt(abs(u(1)));
end