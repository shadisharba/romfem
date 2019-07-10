classdef boundary_conditions < handle
    % only displacement control over a surface
    properties
        free_dof
        essential_dof
        essential_displacement
    end
    
    methods
        function boundary_conditions = boundary_conditions(mesh, user_boundary_conditions)
            boundary_conditions.essential_dof = [];
            boundary_conditions.essential_displacement = [];
            
            count = 0;
            for input_bc = user_boundary_conditions
                for gmsh_bc = mesh.boundary_conditions
                    if strcmp(input_bc.name, gmsh_bc.Name)
                        count = count + 1;
                        
                        essential_dof = mesh.nodal_dof(unique(gmsh_bc.NodalConnectivity), input_bc.direction);
                        boundary_conditions.essential_dof = [boundary_conditions.essential_dof; essential_dof(:)];
                        boundary_conditions.essential_displacement = [boundary_conditions.essential_displacement; ...
                            repmat(input_bc.magnitude, length(essential_dof(:))/length(input_bc.direction), 1)];
                        
                    end
                end
            end
            if count ~= length(user_boundary_conditions)
                error('error in boundary_conditions');
            end
            
            boundary_conditions.free_dof = setdiff(1:mesh.dof, boundary_conditions.essential_dof)';
        end
    end
    
end
