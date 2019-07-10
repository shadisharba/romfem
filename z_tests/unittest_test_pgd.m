clc
clear

rng(0)

approx_zero = @(x) assert(norm(full(x)) < 1e-13);

m = 2 * 6;
n = 5;
modes = 3;
spatial_modes = rand(m, modes); %reshape(1:m*modes,[m modes]);
temporal_modes = rand(n, modes); %reshape(1:n*modes,[n modes]);
singular_values = diag(modes:-1:1);

x_full = spatial_modes * singular_values * temporal_modes';

x = pgd(spatial_modes, singular_values, temporal_modes);

x_pgd = full_to_pgd(x_full, 5, 1e-13);

%% indexing
approx_zero(x.spatial_modes(:, 1:2)-spatial_modes(:, 1:2))

approx_zero(x(1:2, 2:3)-x_full(1:2, 2:3))

%%
x + x + x + x + x + x + x;

x.normalise_spatial_modes;

approx_zero(full(x+x)-2*x_full)

approx_zero(x-x_pgd)

approx_zero(full(2*x-x)-x_full)

approx_zero(full(x./2)-x_full./2)

approx_zero(x.sum-sum(x_full(:)))

approx_zero(x.deviatoric-deviatoric(x_full))

approx_zero(double_dot_product(x, x)-double_dot_product(x_full, x_full))

approx_zero(x.size-modes)

approx_zero(x.full-x_full)

approx_zero(x.is_orthogonal-0)

x.orthonormalise_modes(@rsvd);

approx_zero(x.is_orthogonal-1)
