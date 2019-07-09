classdef mesh < handle
    % mesh class that hendles the given mesh topology and quadrature scheme
    % limited to hexahedron elements

    properties
        nodal_coordinates
        connectivity
        boundary_conditions

        number_of_nodes
        dimension
        nodal_dof
        dof
        number_of_elements

        quadrature_dof
        quadrature_total_dof
        number_of_quadrature

        extrapolation_matrix

        local_shape_functions_diagonal
        gradient_operator_diagonal
        integration_coefficient
    end

    methods
        function mesh = mesh(user_mesh_file)

            [topology, quadrature] = hexahedron8();
            mesh = mesh.load_mesh(user_mesh_file);

            mesh.number_of_nodes = size(mesh.nodal_coordinates, 1);
            mesh.dimension = size(mesh.nodal_coordinates, 2);
            mesh.nodal_dof = reshape(1:numel(mesh.nodal_coordinates), mesh.dimension, mesh.number_of_nodes)';
            mesh.dof = numel(mesh.nodal_coordinates);
            mesh.number_of_elements = size(mesh.connectivity, 1);

            mesh.quadrature_dof = quadrature.dof;
            mesh.number_of_quadrature = quadrature.number_of_quadrature * mesh.number_of_elements;
            mesh.quadrature_total_dof = mesh.number_of_quadrature * mesh.quadrature_dof;

            mesh.extrapolation_matrix = quadrature.extrapolation;

            mesh = mesh.evaluate_shape_functions(topology, quadrature);

            fprintf('%dD, %d %s elements, %d nodes, %d dof\n', mesh.dimension, mesh.number_of_elements, 'hex8', mesh.number_of_nodes, mesh.dof);
        end


        function mesh = load_mesh(mesh, user_mesh_file)

            data = jsondecode(fileread(user_mesh_file));

            % one volume and the rest are boundary conditions
            empty_volume = true;
            boundary_conditions_counter = 1;
            mesh_bc(length(data.Elements)-1) = struct('Name', [], 'NodalConnectivity', [], 'Type', []);

            for element = data.Elements' % loop over each set of elements
                % http://gmsh.info/doc/texinfo/gmsh.html

                if element.Type == 3 % 4-node quadrilateral [used te set the boundary conditions]
                    mesh_bc(boundary_conditions_counter) = element;
                    % change from zero-index to one-index
                    mesh_bc(boundary_conditions_counter).NodalConnectivity = element.NodalConnectivity + 1;

                    boundary_conditions_counter = boundary_conditions_counter + 1;

                elseif element.Type == 5 && empty_volume
                    volume = element; % 8-node hexahedron.
                    empty_volume = false;
                    if min(volume.NodalConnectivity(:)) ~= 0
                        error('should use --zero-based option');
                    end
                    % change from zero-index to one-index
                    volume.NodalConnectivity = volume.NodalConnectivity + 1;
                else
                    error('mesh loading is not successful');
                end
            end

            mesh.boundary_conditions = mesh_bc;
            mesh.nodal_coordinates = data.Nodes.Coordinates;
            mesh.connectivity = volume.NodalConnectivity;

            % remove nodes that aren't in the connectivity
            nodal_numbering = 1:size(mesh.nodal_coordinates, 1);
            idx_to_remove = setdiff(nodal_numbering, mesh.connectivity);
            if ~isempty(idx_to_remove)
                warning('There are extra nodes in the mesh file\n');
                mesh.nodal_coordinates(idx_to_remove, :) = [];
                nodal_numbering(idx_to_remove) = [];

                [row, col, nodal_number] = find(mesh.connectivity);
                % find nodal_number in nodal_numbering
                [~, new_nodal_number] = ismember(nodal_number, nodal_numbering);
                mesh.connectivity = full(sparse(row, col, new_nodal_number));
            end

        end

        function mesh = evaluate_shape_functions(mesh, topology, quadrature)

            % stack of elemental components N, B, det(J) * w
            shape_functions_stack = cell(mesh.number_of_elements, 1);
            global_gradient_stack = cell(mesh.number_of_elements, 1);
            element_integration_coefficient = zeros(quadrature.number_of_quadrature, mesh.number_of_elements); % jacobian_determinant * quadrature.weights(quadrature_idx);

            element_local_shape_functions_stack = cell(quadrature.number_of_quadrature, 1);
            element_global_gradient_stack = cell(quadrature.number_of_quadrature, 1);

            % loop over elements and quadrature points
            for element_idx = 1:mesh.number_of_elements

                node_idx = mesh.connectivity(element_idx, :);

                for quadrature_idx = 1:quadrature.number_of_quadrature

                    quadrature_coordinates = quadrature.local_coordinates(quadrature_idx, :);

                    local_shape_functions_evaluated = kron(topology.N(quadrature_coordinates(1), quadrature_coordinates(2), quadrature_coordinates(3)), eye(topology.dof)); % (1 x 8) * 3 dof
                    local_shape_functions_derivative = [ ...
                        topology.dN_xi(quadrature_coordinates(1), quadrature_coordinates(2), quadrature_coordinates(3)); ...
                        topology.dN_eta(quadrature_coordinates(1), quadrature_coordinates(2), quadrature_coordinates(3)); ...
                        topology.dN_zeta(quadrature_coordinates(1), quadrature_coordinates(2), quadrature_coordinates(3))];% 3 x 8

                    jacobian_matrix = local_shape_functions_derivative * mesh.nodal_coordinates(node_idx, :);
                    jacobian_determinant = det(jacobian_matrix); % jacobian determinant (the volume of the element divided by the volume of the reference element)
                    % mteric = inv(jacobian_matrix)'*inv(jacobian_matrix);
                    if jacobian_determinant <= eps
                        error('one of the elements is distorted');
                    end

                    global_shape_functions_derivative = jacobian_matrix \ local_shape_functions_derivative; % 3 x 8

                    % [xx,yy,zz,yz,xz,xy] only affects the postprocessing phase
                    position_x = [1, 0, 0; 0, 0, 0; 0, 0, 0; 0, 0, 0; 0, 0, 1; 0, 1, 0];
                    position_y = [0, 0, 0; 0, 1, 0; 0, 0, 0; 0, 0, 1; 0, 0, 0; 1, 0, 0];
                    position_z = [0, 0, 0; 0, 0, 0; 0, 0, 1; 0, 1, 0; 1, 0, 0; 0, 0, 0];
                    global_gradient_operator = ...
                        kron(global_shape_functions_derivative(1, :), position_x) ...
                        +kron(global_shape_functions_derivative(2, :), position_y) ...
                        +kron(global_shape_functions_derivative(3, :), position_z);

                    global_gradient_operator = global_gradient_operator ./ [1, 1, 1, sqrt(2), sqrt(2), sqrt(2)]'; % Mandel notation [1 / sqrt(2) = 1/2 * sqrt(2)] % https://en.wikipedia.org/wiki/Deformation_(mechanics)
                    % 6 components x (8 nodes x 3 dof)

                    element_local_shape_functions_stack{quadrature_idx} = local_shape_functions_evaluated;
                    element_global_gradient_stack{quadrature_idx} = sparse(global_gradient_operator);
                    element_integration_coefficient(quadrature_idx, element_idx) = jacobian_determinant * quadrature.weights(quadrature_idx);

                end

                shape_functions_stack{element_idx} = vertcat(element_local_shape_functions_stack{:}); % 8 nodes, each (1 x 8) * 3 dof -> 24 x 24 (nodal_dof x nodal_dof)
                global_gradient_stack{element_idx} = vertcat(element_global_gradient_stack{:}); % 8 quadrature points, each 6 components x (8 nodes x 3 dof) -> 48 x 24 (quadrature_dof x nodal_dof)
            end

            mesh.local_shape_functions_diagonal = blkdiagmex(shape_functions_stack{:});
            mesh.gradient_operator_diagonal = blkdiagmex(global_gradient_stack{:});
            mesh.integration_coefficient = spdiags(repelem(element_integration_coefficient(:), quadrature.dof), 0, mesh.quadrature_total_dof, mesh.quadrature_total_dof);
            % sum (diag(mesh.integration_coefficient)) = 6 * volume
        end
    end
end
