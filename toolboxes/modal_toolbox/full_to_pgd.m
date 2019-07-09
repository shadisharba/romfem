function y = full_to_pgd(x, k, rejection_tol)
if ~exist('rejection_tol', 'var')
    rejection_tol = eps;
end
[spatial_modes, singular_values, temporal_modes] = rsvd(x, k, rejection_tol);
is_orthogonal = true;
y = pgd(spatial_modes, singular_values, temporal_modes,is_orthogonal);
end