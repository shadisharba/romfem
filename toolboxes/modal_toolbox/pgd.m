classdef pgd < handle

    %% orthonormal outerproduct format
    % PGD class that handles spatial and temporal modes
    % https://de.mathworks.com/help/matlab/matlab_oop/implementing-operators-for-your-class.html

    properties
        spatial_modes = []; % column vectors
        temporal_modes = []; % column vectors
        singular_values = []; % sparse diagonal matrix
        is_orthogonal = false;
    end

    methods
        function pgd_object = pgd(spatial_modes, singular_values, temporal_modes, is_orthogonal)
            assert(size(spatial_modes, 2) == size(temporal_modes, 2)); % same number of modes
            pgd_object.spatial_modes = spatial_modes;
            pgd_object.temporal_modes = temporal_modes;
            if isempty(singular_values)
                pgd_object.singular_values = eye(size(spatial_modes, 2));
            else
                pgd_object.singular_values = singular_values;
            end
            if exist('is_orthogonal', 'var')
                pgd_object.is_orthogonal = is_orthogonal;
            end
        end

        function full_matrix = full(pgd_object)
            full_matrix = pgd_object.spatial_modes * pgd_object.singular_values * pgd_object.temporal_modes';
        end

        function orthonormalise_modes(x, svd_function_handle,tol)
            if size(x) > 1
                [q_s, r_s] = qr_decomp(x.spatial_modes);
                [q_t, r_t] = qr_decomp(x.temporal_modes);
                
                [orth_spatial_modes, x.singular_values, orth_temporal_modes] = svd_function_handle(r_s*x.singular_values*r_t', size(x));
                
                x.spatial_modes = q_s * orth_spatial_modes; % orthogonal matrix
                x.temporal_modes = q_t * orth_temporal_modes;
                x.is_orthogonal = true;
                
                if exist('tol', 'var')
                    x.compress_pgd(tol);
                else
                    x.compress_pgd(eps);
                end
            end
        end

        function compress_pgd(x, rejection_tol)
            assert(x.is_orthogonal == true)
            score_modes = (diag(x.singular_values) / x.singular_values(1));
            idx_to_delete = score_modes < rejection_tol;
            if sum(idx_to_delete)
                x.spatial_modes(:, idx_to_delete) = [];
                x.temporal_modes(:, idx_to_delete) = [];
                x.singular_values(:, idx_to_delete) = [];
                x.singular_values(idx_to_delete, :) = [];
            end
        end

        function x_plus_y = plus(x, y) % +
            if isempty(x)
                x_plus_y = y;
                return;
            end
            if isa(x, 'pgd') && isa(y, 'pgd')
                if x.is_orthogonal && y.is_orthogonal
                    z_s = x.spatial_modes' * y.spatial_modes;
                    z_t = x.temporal_modes' * y.temporal_modes;

                    [q_s, r_s] = qr_decomp(y.spatial_modes-x.spatial_modes*z_s);
                    [q_t, r_t] = qr_decomp(y.temporal_modes-x.temporal_modes*z_t);

                    core = [x.singular_values + z_s * y.singular_values * z_t', z_s * y.singular_values * r_t'; ...
                        r_s * y.singular_values * z_t', r_s * y.singular_values * r_t'];
                    
                    x_plus_y = pgd(horzcat(x.spatial_modes, q_s), core, horzcat(x.temporal_modes, q_t));
                else
                    x_plus_y = pgd(horzcat(x.spatial_modes, y.spatial_modes), blkdiagmex(x.singular_values, y.singular_values), horzcat(x.temporal_modes, y.temporal_modes));
                end
                x_plus_y.orthonormalise_modes(@rsvd);
            else
                x_plus_y = full(x) + full(y);
            end
        end
        function x_minus_y = minus(x, y) % -
            x_minus_y = x + ((-1).*y);
        end
        function x_mtimes_y = mtimes(x, y) % Matrix multiplication
            if isa(x, 'pgd') && isa(y, 'pgd')
                error('not implemented');
            elseif isa(y, 'pgd')
                if isscalar(x)
                    x_mtimes_y = x.*y;
                else
                    x_mtimes_y = pgd(x * y.spatial_modes, y.singular_values, y.temporal_modes);
                end
            else
                if isscalar(y)
                    x_mtimes_y = x.*y;
                else
                    x_mtimes_y = pgd(x.spatial_modes, x.singular_values, y' * x.temporal_modes);
                end
            end
        end
        function x_times_y = times(x, y) % .*
            if isa(x, 'pgd') && isa(y, 'pgd')
            
                                        [x_permutations, y_permutations] = ndgrid(1:size(x), 1:size(y));

            diag_x = diag(x.singular_values);
            diag_y = diag(y.singular_values);

            x_times_y = pgd(x.spatial_modes(:, x_permutations(:)) .* y.spatial_modes(:, y_permutations(:)), ...
                diag(diag_x(x_permutations(:)) .* diag_y(y_permutations(:))) ...
                , x.temporal_modes(:,x_permutations(:)).*y.temporal_modes(:,y_permutations(:)));
            
            elseif isa(y, 'pgd')
                x_times_y = pgd(y.spatial_modes, y.singular_values, x.*y.temporal_modes);
            else
                x_times_y = pgd(x.spatial_modes, x.singular_values, y.*x.temporal_modes);
            end
        end
        function x_div_y = rdivide(x, y) % ./ Right element-wise division
            if isa(x, 'pgd') && isa(y, 'pgd')
                
                 [x_permutations, y_permutations] = ndgrid(1:size(x), 1:size(y));

            diag_x = diag(x.singular_values);
            diag_y = diag(y.singular_values);

            x_div_y = pgd(x.spatial_modes(:, x_permutations(:)) ./ y.spatial_modes(:, y_permutations(:)), ...
                diag(diag_x(x_permutations(:)) ./ diag_y(y_permutations(:))) ...
                , x.temporal_modes(:,x_permutations(:))./y.temporal_modes(:,y_permutations(:)));
            
            elseif isa(y, 'pgd')
                error('not implemented');
            else
                x_div_y = pgd(x.spatial_modes, x.singular_values, x.temporal_modes./y);
            end
        end

        function deviatoric_x = deviatoric(x) % by value
            deviatoric_x = pgd(deviatoric(x.spatial_modes), x.singular_values, x.temporal_modes);
        end
        function x_times_y = double_dot_product(x, y) % number of modes is squared here
            [x_permutations, y_permutations] = ndgrid(1:size(x), 1:size(y));

            diag_x = diag(x.singular_values);
            diag_y = diag(y.singular_values);

            x_times_y = pgd(double_dot_product(x.spatial_modes(:, x_permutations(:)), y.spatial_modes(:, y_permutations(:))), ...
                diag(diag_x(x_permutations(:)) .* diag_y(y_permutations(:))) ...
                , x.temporal_modes(:,x_permutations(:)).*y.temporal_modes(:,y_permutations(:)));
        end
        function sum_x = sum(x)
            sum_x = sum(sum(full(x)));
        end
        function sqrt_x = sqrt(x)
            sqrt_x = sqrt(full(x));
        end
        function size_x = size(x)
            size_x = size(x.spatial_modes, 2);
        end
        function [dof_spatial, dof_temporal] = dof(x)
            dof_spatial = size(x.spatial_modes, 1);
            dof_temporal = size(x.temporal_modes, 1);
        end
        function x = normalise_spatial_modes(x) % by reference so x will be changed
            norm_space = vecnorm(x.spatial_modes);
            norm_time = vecnorm(x.temporal_modes);
            x.spatial_modes = x.spatial_modes ./ norm_space;
            x.singular_values = x.singular_values .* norm_space .* norm_time;
            x.temporal_modes = x.temporal_modes ./ norm_time;
        end
        
        % indexing: https://de.mathworks.com/help/matlab/matlab_oop/code-patterns-for-subsref-and-subsasgn-methods.html
        function varargout = subsref(x, index)
            if length(index) == 2
                [varargout{1:nargout}] = builtin('subsref', x, index);
                return;
            end
            switch index.type
                case '.'
                    [varargout{1:nargout}] = builtin('subsref', x, index); % Execute built-in function from overloaded method
                case '()'
                    varargout{1} = x.spatial_modes(index.subs{1}, :) * x.singular_values * x.temporal_modes(index.subs{2},:)';
                otherwise
                    error('Not an implemented indexing expression')
            end
        end
        % subsindex(x) subsasgn(x)

    end
end


