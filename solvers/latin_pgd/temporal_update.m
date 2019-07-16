function temporal_modes = temporal_update(strain_spatial_modes, local_obj, numerical_model, temporal_modes)

% exploit the symmetry in A?
% A is a scalar when generating a new time mode and has the dimension
% \mu x \mu when updating

A = (numerical_model.solver_parameters.elasticity_reduction_factor * strain_spatial_modes' * numerical_model.submesh.integral_elasticity_tensor_diagonal * strain_spatial_modes);
B = full(spatial_integration(strain_spatial_modes, numerical_model.mesh)'*local_obj.minus_residual);
temporal_modes = transpose(A \ B);

% % TODONOW
% if nargin == 4
%     B_restricted = B * temporal_modes;
%     c = A \ B_restricted;
%     temporal_modes = transpose(c * temporal_modes');
% else
%     temporal_modes = transpose(A \ B);
% end

% zero initial conditions
temporal_modes(1, :) = 0;

end