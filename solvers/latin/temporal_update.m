function temporal_modes = temporal_update(spatial_modes, local_obj, numerical_model)

% exploit the symmetry in A?
% A is a scalar when generating a new time mode and has the dimension
% \mu x \mu when updating

temporal_modes = (spatial_modes' * numerical_model.submesh.integral_elasticity_tensor_diagonal * spatial_modes) \ (spatial_integration(spatial_modes, numerical_model.mesh)' * local_obj.minus_residual);

% zero initial conditions
temporal_modes(:, 1) = 0;

end