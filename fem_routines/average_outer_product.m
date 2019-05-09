function x_outer_y = average_outer_product(x, y)
% outer_product for symmetric tensors with 6 stored components (averaged over time)
components = 6;
dims = [components, 1, size(x, 2), size(x, 1) / components];
x = reshape(x, dims);
y = reshape(y, dims);
z = mtimesx(x, y, 't');

q = num2cell(z, [1, 2]);
if size(q, 3) > 1
    x_outer_y = sparse(dims(1)*dims(4), dims(1)*dims(4));
    for jj = 1:size(q, 3)
        x_outer_y = x_outer_y + blkdiagmex(q{:, :, jj, :});
    end
    x_outer_y = x_outer_y / size(q, 3);
else
    x_outer_y = blkdiagmex(q{:});
end

end
