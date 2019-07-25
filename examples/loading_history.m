function [user_boundary_conditions,user_load] = loading_history(varargin)
%[clamped, tension, amplitude, period, timestep_per_cycle_div4] = deal(varargin{:});

[clamped, tension, amplitude, period, timestep_per_cycle_div4] = deal(varargin{:});

user_load = loading.empty([length(amplitude), 0]);
for i = 1:length(amplitude)
    user_load(i) = loading(1, period(i), timestep_per_cycle_div4, amplitude(i), 0);
end

if tension
    load_direction = 3;
else % bending
    load_direction = 1;
end
user_boundary_conditions(1) = struct('name','zload','direction',load_direction,'magnitude',user_load(1).magnitude');

if clamped
    user_boundary_conditions(2) = struct('name','zsym','direction',[1, 2, 3],'magnitude',zeros(3, length(user_load(1).temporal_mesh)));
else % 'symmetry'
    user_boundary_conditions(2) = struct('name','xsym','direction',[1],'magnitude',zeros(1, length(user_load(1).temporal_mesh)));
    user_boundary_conditions(3) = struct('name','ysym','direction',[2],'magnitude',zeros(1, length(user_load(1).temporal_mesh)));
    user_boundary_conditions(4) = struct('name','zsym','direction',[3],'magnitude',zeros(1, length(user_load(1).temporal_mesh)));
end

end