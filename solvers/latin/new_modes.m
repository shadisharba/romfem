function global_fields = new_modes(global_fields, numerical_model, local_obj)

% As long as we have no idea how the new temporal mode looks like, no need
% to give a cyclic or ... initial guess [the fixed-point iteration converges very fast]
temporal_mode = numerical_model.temporal.mesh;
displacement_spatial_mode = zeros(numerical_model.mesh.dof, 1);

for i = 1:5 %parameter
    old_temporal_mode = temporal_mode;

    b = numerical_model.submesh.integral_gradient_operator' * temporal_mass_integration(local_obj.minus_residual, temporal_mode, numerical_model.temporal);

    % KA0: zero correction for the dofs with imposed displacement
    displacement_spatial_mode(numerical_model.boundary_conditions.free_dof) = numerical_model.submesh.K_FF \ b(numerical_model.boundary_conditions.free_dof);

    % this normalisation ensures not having very small numbers in the temporal_update
    displacement_spatial_mode = displacement_spatial_mode ./ norm(displacement_spatial_mode);

    strain_spatial_mode = numerical_model.submesh.gradient_operator * displacement_spatial_mode;

    temporal_mode = temporal_update(strain_spatial_mode, local_obj, numerical_model);

    if norm(old_temporal_mode-temporal_mode) < 1e-6 %parameter
        break;
    end
end

global_fields.displacement_spatial_modes = [global_fields.displacement_spatial_modes, displacement_spatial_mode];
global_fields.strain_spatial_modes = [global_fields.strain_spatial_modes, strain_spatial_mode];
global_fields.temporal_modes = [global_fields.temporal_modes; temporal_mode];

end

% scalars in front of the stiffness matrix are ignored as long as the
% spatial modes will be normalised afterwards
% a = temporal_mass_integration(time_mode, time_mode,
% numerical_model.temporal); % ./ (alpha_global .* a);
