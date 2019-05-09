function derivative_of_x = temporal_derivation(x, temporal_mesh)
derivative_of_x = gradient(x, temporal_mesh);
end
% gradient function calculates the central difference for interior data points
% and single-sided differences for values along the edges of the matrix.