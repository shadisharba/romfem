function relative_err = compute_relative_error(minus_residual, norm_first_residual_free_dof, delta_displacement, norm_displacement)
if norm_first_residual_free_dof
    relative_err_focre = norm(minus_residual) / norm_first_residual_free_dof;
else
    relative_err_focre = norm(minus_residual);
end
if norm_displacement
    relative_err_displacement = norm(delta_displacement) / norm_displacement;
else
    relative_err_displacement = norm(delta_displacement);
end
relative_err = max(relative_err_focre, relative_err_displacement);
end