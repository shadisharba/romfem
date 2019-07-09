classdef numerical_model < handle
    properties
        mesh
        boundary_conditions
        
        material
        submesh
        
        temporal
        solver_parameters
        
    end
    methods
        % material mesh submesh boundary_conditions
        function numerical_model = numerical_model(user_mesh, user_material, user_boundary_conditions, user_temporal_mesh,solver_parameters)
            
            numerical_model.mesh = mesh(user_mesh);
            
            numerical_model.boundary_conditions = boundary_conditions(numerical_model.mesh, user_boundary_conditions);
            
            numerical_model.material = material_model(user_material, numerical_model.mesh);
            
            numerical_model.submesh = submesh(numerical_model.material, numerical_model.mesh, numerical_model.boundary_conditions);
            
            % [numerical_model.submesh, numerical_model.boundary_conditions] = numerical_model.reorder_and_decompose_stiffness(numerical_model.submesh, numerical_model.boundary_conditions);
            numerical_model.submesh.K_FF = decomposition(numerical_model.submesh.K_FF, 'chol'); % L L' // L'\(L\F);
            
            numerical_model.temporal = temporal_mesh(user_temporal_mesh);
            
            numerical_model.solver_parameters = solver_parameters;
        end
        
        % TODO can we change the stiffness to row-major in MATLAB?
        function [submesh, boundary_conditions] = reorder_and_decompose_stiffness(~, submesh, boundary_conditions)
            
            % symamdmex, colamdmex
            % reordering_vec = symamd(submesh.K_FF); % Symmetric approximate minimum degree permutation (less non-zero entries)
            reordering_vec = symrcm(submesh.K_FF); % Sparse reverse Cuthill-McKee ordering
            % spy(submesh.K_FF(reordering_vec, reordering_vec));
            
            submesh.K_FF = decomposition(submesh.K_FF(reordering_vec, reordering_vec), 'chol');
            submesh.K_FE = submesh.K_FE(reordering_vec, :);
            
            % either change free_dof or gradient not both because the
            % resulting displacement is in the original order (easier for post processing and
            % might save some time when applying the gradient operator)
            % boundary_conditions.free_dof = boundary_conditions.free_dof(reordering_vec);
            
            submesh.gradient_operator(:, boundary_conditions.free_dof) = submesh.gradient_operator(:, boundary_conditions.free_dof(reordering_vec));
            submesh.integral_gradient_operator(:, boundary_conditions.free_dof) = submesh.integral_gradient_operator(:, boundary_conditions.free_dof(reordering_vec));
            
        end
    end
end
