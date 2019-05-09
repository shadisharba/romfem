classdef loading < handle
    
    properties
        temporal_mesh
        magnitude
    end
    
    methods
        function obj = loading(varargin)
            if nargin
                [number_of_cycles, period, steps_per_cycle_div_4, amplitude, phase] = deal(varargin{:});
            else
                error('loading class: not implemented');
            end
            
            omega = 2 * pi / period; % angular frequency = 2*pi*f
            total_time = number_of_cycles * period;
            number_of_time_steps = number_of_cycles * steps_per_cycle_div_4 * 4 + 1; % 4 is used to capture the wave peaks and 1 is for the time point zero
            
            obj.temporal_mesh = linspace(0, total_time, number_of_time_steps);
            obj.magnitude = amplitude * sin(omega*obj.temporal_mesh+phase);
            obj.magnitude(abs(obj.magnitude) <= 1e-15) = 0; %parameter
        end
        
        function [scaling_factor, shift] = scaling_factor(new_load, old_load)
            scaling_factor = new_load.magnitude ./ old_load.magnitude;
            scaling_factor(~isfinite(scaling_factor(:))) = 1;
            % shift is used for zero values in obj_old.magnitude
            shift = new_load.magnitude - scaling_factor .* old_load.magnitude;
            shift(abs(shift) <= 1e-15) = 0; %parameter
        end
        
    end
end
