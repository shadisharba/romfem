close all
period = 10;
new_load = loading(1, 10, 25, 3, 0);
old_load = loading(1, 10, 25, 1, -0.3);
% old_load.magnitude(end)=old_load.magnitude(end-1);
% old_load.magnitude(end) = old_load.magnitude(end)+0.1;

old_load.magnitude(end) = [];
new_load.magnitude(end) = [];

[scaling_factor, shift] = new_load.scaling_factor(old_load);

error('copy_cyclic is moved to duplicate_cycles')
out = copy_cyclic(old_load.magnitude, scaling_factor, shift);

% plot([old_load.magnitude,nan,out])
plot(linspace(0, 5, size(old_load.magnitude, 2)), old_load.magnitude, linspace(5, 7.5, size(out, 2)), out)
