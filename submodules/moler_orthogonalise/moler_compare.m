% Posted by Cleve Moler, October 17, 2016
% downloaded from: https://blogs.mathworks.com/cleve/2016/10/17/compare-gram-schmidt-and-householder-orthogonalization-algorithms-2/

function moler_compare(X)
% compare(X). Compare three QR decompositions.

I = eye(size(X));
qrerr = zeros(1, 3);
ortherr = zeros(1, 3);

%% Classic Gram Schmidt
[Q, R] = gs_stewart(X);
qrerr(1) = norm(Q*R-X, inf) / norm(X, inf);
ortherr(1) = norm(Q'*Q-I, inf);

%% Modified Gram Schmidt
[Q, R] = mgs_stewart(X);
qrerr(2) = norm(Q*R-X, inf) / norm(X, inf);
ortherr(2) = norm(Q'*Q-I, inf);

%% Householder QR Decomposition
[U, R] = house_qr_stewart(X);
QR = house_apply(U, R);
QQ = house_apply_transpose(U, house_apply(U, I));
qrerr(3) = norm(QR-X, inf) / norm(X, inf);
ortherr(3) = norm(QQ-I, inf);
% Q = house_apply(U,I)

%% Report results
fprintf('\n                 Classic   Modified  Householder\n')
fprintf('QR error      %10.2e %10.2e %10.2e\n', qrerr)
fprintf('Orthogonality %10.2e %10.2e %10.2e\n', ortherr)
end
