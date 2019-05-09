function elastic_result = elastic_solution(numerical_model)

% TODO: include force control (nodal forces/ traction)

material = numerical_model.material;
spatial_dofs = numerical_model.mesh.dof;
essential_dof = numerical_model.boundary_conditions.essential_dof;
free_dof = numerical_model.boundary_conditions.free_dof;

% this assumes that the load is proportional within a cycle
[~, idx] = max(numerical_model.boundary_conditions.essential_displacement(:));
[row, col] = ind2sub(size(numerical_model.boundary_conditions.essential_displacement), idx);
temporal_function = numerical_model.boundary_conditions.essential_displacement(row, :) ./ numerical_model.boundary_conditions.essential_displacement(row, col);

% no external forces so no F = F - ...
residual = -numerical_model.submesh.K_FE * numerical_model.boundary_conditions.essential_displacement(:, col);

displacement = zeros(spatial_dofs, 1);
displacement(essential_dof) = numerical_model.boundary_conditions.essential_displacement(:, col);
displacement(free_dof) = numerical_model.submesh.K_FF \ residual;

elastic_result.first_residual = pgd(residual, temporal_function);

elastic_result.displacement = pgd(displacement, temporal_function);

elastic_result.strain = pgd(numerical_model.submesh.gradient_operator*displacement, temporal_function);

elastic_result.stress = pgd(material.elasticity_tensor_diagonal*elastic_result.strain.spatial_modes, temporal_function);

end
