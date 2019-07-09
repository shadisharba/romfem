classdef temporal_mesh < handle
    
    properties
        mesh
        dof
        
        integration_coefficient
        mass_integration_coefficient
    end
    
    methods
        
        function temporal = temporal_mesh(user_temporal_mesh)
            temporal.mesh = user_temporal_mesh;
            temporal.dof = length(temporal.mesh);
            
            dt = diff(temporal.mesh);
            
            temporal.integration_coefficient = sparse(temporal.dof, 1);
            temporal.mass_integration_coefficient = sparse(temporal.dof, temporal.dof);
            
            % 1D finite element discretisation
            % one integration poing in the middle
            shape_function = [0.5; 0.5]; % det(J) * w = dt/2 * 2 = dt
            
            % two integration points at -1/sqrt(3) and 1/sqrt(3)
            % a=(3+sqrt(3))/6; b=(3-sqrt(3))/6; N=[a b; b a]
            mass_matrix = [2, 1; 1, 2] / 3; % N'*N
            % det(J) * w = dt/2 * 1
            
            for dof = 1:temporal.dof - 1
                temporal.integration_coefficient(dof:dof+1) = temporal.integration_coefficient(dof:dof+1) + dt(dof) * shape_function; % force integrator
                temporal.mass_integration_coefficient(dof:dof+1, dof:dof+1) = temporal.mass_integration_coefficient(dof:dof+1, dof:dof+1) + dt(dof) / 2 * mass_matrix; % mass integrator
            end
            
        end
        
    end
end
