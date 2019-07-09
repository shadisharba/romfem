function temporal_modes = temporal_update(strain_spatial_modes, local_obj, numerical_model)

% exploit the symmetry in A?
% A is a scalar when generating a new time mode and has the dimension
% \mu x \mu when updating

temporal_modes = transpose((numerical_model.solver_parameters.elasticity_reduction_factor * strain_spatial_modes' * numerical_model.submesh.integral_elasticity_tensor_diagonal * strain_spatial_modes) \ ...
    full(spatial_integration(strain_spatial_modes, numerical_model.mesh)'*local_obj.minus_residual));

% zero initial conditions
temporal_modes(1,:) = 0;

end