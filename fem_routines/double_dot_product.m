function x_yimes_y = double_dot_product(X, Y)
% double_dot_product for symmetric tensors with 6 stored components
components = 6;
dims = [components, size(X, 1) / components, size(X, 2)];
x_yimes_y = shiftdim(sum(reshape(X.*Y, dims), 1), 1);
end

% SLOW
% @(x) splitapply(@(xd) (sum(xd.^2)),x,repelem(1:size(x, 1) / 6, 6)');