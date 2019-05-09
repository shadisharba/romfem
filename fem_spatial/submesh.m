classdef submesh < handle
    % This class is responsible for the assembly of the stiffness matrix,
    % gradient of shape functions and the elemental integrators
    properties
        
        gradient_operator
        integral_gradient_operator
        
        K_FF
        K_FE
        
        integral_elasticity_tensor_diagonal
        integral_inv_elasticity_tensor_diagonal
    end
    
    methods
        
        function submesh = submesh(material, mesh, boundary_conditions)
            
            essential_dof = boundary_conditions.essential_dof;
            free_dof = boundary_conditions.free_dof;
            
            submesh.gradient_operator = submesh.gradient_assembly(mesh, mesh.gradient_operator_diagonal);
            
            submesh.integral_elasticity_tensor_diagonal = spatial_integration(material.elasticity_tensor_diagonal, mesh);
            submesh.integral_inv_elasticity_tensor_diagonal = spatial_integration(material.inv_elasticity_tensor_diagonal, mesh);
            submesh.integral_gradient_operator = spatial_integration(submesh.gradient_operator, mesh);
            
            stiffness = submesh.gradient_operator' * submesh.integral_elasticity_tensor_diagonal * submesh.gradient_operator;
            stiffness = (stiffness + stiffness') ./ 2;
            
            submesh.K_FF = stiffness(free_dof, free_dof);
            submesh.K_FE = stiffness(free_dof, essential_dof);
            
            % stiffness_diagonal = diag(stiffness(essential_dof, essential_dof));
            % submesh.K_FF(essential_dof, :) = 0;
            % submesh.K_FF(:, essential_dof) = 0;
            % idx = sub2ind(size(stiffness), essential_dof, essential_dof);
            % submesh.K_FF(idx) = stiffness_diagonal;
        end
        
        function assembled_gradient = gradient_assembly(~, mesh, matrix)
            
            [row, col_local_dof, value] = find(matrix);
            
            idx = reshape(mesh.connectivity', 1, []);
            dof = size(matrix, 2) / numel(idx);
            
            shift_dof = linspace(dof-1, 0, dof)';
            % matrix that contains the global dof corresponding to the
            % nodes in the connectivity matrix
            local_to_global_dof = repmat(idx*dof, [dof, 1]) - shift_dof;
            
            assembled_gradient = sparse(row, local_to_global_dof(col_local_dof), value, size(matrix, 1), mesh.dof);
        end
        
    end
end
