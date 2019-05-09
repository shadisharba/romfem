classdef material_model < handle
    properties
        user_material
        
        mu
        lambda
        
        elasticity_tensor
        inv_elasticity_tensor
        
        elasticity_tensor_diagonal
        inv_elasticity_tensor_diagonal
        
    end
    methods
        function material = material_model(user_material, mesh)
            material.user_material = user_material;
            material.mu = user_material.E / (2 * (1 + user_material.nu));
            material.lambda = user_material.nu * user_material.E / ((1 + user_material.nu) * (1 - 2 * user_material.nu));
            
            % Mandel notation is used here
            material.elasticity_tensor = 2 * material.mu * eye(6) + blkdiagmex(material.lambda*ones(3), zeros(3));
            material.inv_elasticity_tensor = inv(material.elasticity_tensor);
            
            material.elasticity_tensor_diagonal = kron(speye(sum(mesh.number_of_quadrature)), material.elasticity_tensor);
            material.inv_elasticity_tensor_diagonal = kron(speye(sum(mesh.number_of_quadrature)), material.inv_elasticity_tensor);
            
        end
    end
end
