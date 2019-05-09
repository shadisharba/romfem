%TODONOW
classdef pgd < handle
    % PGD class that handles spatial and temporal modes and gives access to
    % the full tensor as well
    
    properties
        spatial_modes
        temporal_modes
    end
    
    methods
        function obj = pgd(spatial_modes, temporal_modes)
            obj.spatial_modes = spatial_modes;
            obj.temporal_modes = temporal_modes;
        end
        function full_x = full(obj)
            warning('full is being used');
            full_x = obj.spatial_modes * obj.temporal_modes;
        end
        function deviatoric_x = deviatoric(x)
            deviatoric_x = pgd(deviatoric(x.spatial_modes),x.temporal_modes);
        end
        function x_yimes_y = double_dot_product(x, y)
            x_yimes_y = pgd(double_dot_product(x.spatial_modes,y.spatial_modes),x.temporal_modes .* y.temporal_modes);
        end
        function a_times_b = times(a,b) % .*
            a_times_b = pgd(b.spatial_modes, a.* b.temporal_modes);
        end
        function a_times_b = rdivide(a,b) % ./
            if ~isa(b,'pgd')
            a_times_b = a.full ./ b;    
            else
            a_times_b = pgd(a.spatial_modes ./ b, a.temporal_modes);
            end
        end
        function a_minus_b = minus(a,b)
            a_minus_b = pgd([a.spatial_modes,b.spatial_modes],[a.temporal_modes;-b.temporal_modes]);
        end
        function a_times_b = mtimes(a,b)
            a_times_b = pgd(a*b.spatial_modes,b.temporal_modes);
        end
        function sqrt_x = sqrt(x)
            sqrt_x = pgd(sqrt(x.spatial_modes), sqrt(x.temporal_modes));
        end
%         function y = subsindex(x)
%             x;
%         end
        function varargout = subsref(x,s)
            switch s.type
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',x,s);
                case '()'
                    varargout{1} = x.spatial_modes(s.subs{1},:) * x.temporal_modes(:,s.subs{2},:);
            end
        end
%         function y = subsasgn(x)
%             x;
%         end       
        % TODO: implement a norm function and an integrator
        % TODONOW: implement a copy_cyclic function
    end
end
