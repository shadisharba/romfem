
%% same number of time steps per cycle is assumed otherwise an interpolation
% scheme should be used [y_new = interp1(x,y,x_new,'makima'); %makima spline]
% openExample('matlab/InterpolationofCoarselySampledSineFunctionExample')
function x_new = copy_cyclic(x_old, scale_factor, shift)
% dimensionless coordinate t \in [0,1]

if sum(shift)
    error('shift is not verified yet');
end

if isa(x_old, 'pgd')
    t = linspace(0, 1, length(scale_factor))';
    
    x_scaled = x_old .* scale_factor; % TODO + shift;
    
    h = x_old(:, end) - x_scaled(:, 1);
    g = x_old(:, end) - x_scaled(:, end) - h;
    
    x_new = x_scaled + pgd(g, [], t) + pgd(h, [], ones(length(scale_factor), 1));
    
else
    t = linspace(0, 1, length(scale_factor))';
    
    if size(x_old, 2) == length(scale_factor) % matrix
        x_scaled = x_old .* scale_factor' + shift';
        h = x_old(:, end) - x_scaled(:, 1);
        g = x_old(:, end) - x_scaled(:, end) - h;
        x_new = x_scaled + g * t' + h;
    else % temporal modes
        x_scaled = x_old .* scale_factor + shift;
        h = x_old(end, :) - x_scaled(1, :);
        g = x_old(end, :) - x_scaled(end, :) - h;
        x_new = x_scaled + g .* t + h;
    end
    
end

% plot([x_old,x_new]')
end