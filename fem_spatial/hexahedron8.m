function [topology, quadrature] = hexahedron8()

topology.dimension = 3;
topology.dof = 3; % per node
topology.number_of_nodes = 8;

quadrature.number_of_quadrature = 8;
quadrature.dof = 6; % per integration point

% base on gmsh hexahedron element [http://gmsh.info/doc/texinfo/gmsh.html]
topology.local_coordinates = [-1, -1, -1; ...
    1, -1, -1; ...
    1, 1, -1; ...
    -1, 1, -1; ...
    -1, -1, 1; ...
    1, -1, 1; ...
    1, 1, 1; ...
    -1, 1, 1];

syms xi eta zeta % ensure the function arguments order
shape_functions = prod(1+topology.local_coordinates'.*[xi; eta; zeta], 1) / 8;

topology.N = matlabFunction(shape_functions, 'Vars', [xi, eta, zeta], 'Sparse', true);
topology.dN_xi = matlabFunction(diff(shape_functions, xi), 'Vars', [xi, eta, zeta], 'Sparse', true);
topology.dN_eta = matlabFunction(diff(shape_functions, eta), 'Vars', [xi, eta, zeta], 'Sparse', true);
topology.dN_zeta = matlabFunction(diff(shape_functions, zeta), 'Vars', [xi, eta, zeta], 'Sparse', true);
% [xi, eta, zeta] are given to ensure the arguments order

quadrature.local_coordinates = topology.local_coordinates / sqrt(3);

quadrature.weights = [1, 1, 1, 1, 1, 1, 1, 1]';

quadrature.extrapolation = zeros(8, 8);
counter = 1;
for gp = quadrature.local_coordinates'
    quadrature.extrapolation(counter, :) = topology.N(gp(1), gp(2), gp(3));
    counter = counter + 1;
end
quadrature.extrapolation = inv(quadrature.extrapolation);

end
