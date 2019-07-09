function cum_integral_x = temporal_cumulative_integration(x, temporal_mesh)
% zero initial conditions are assumed here
cum_integral_x = x .* temporal_mesh.integration_coefficient';
cum_integral_x = cumsum(cum_integral_x, 2);
% cum_integral_x2 = cumsum(x.*[0, diff(temporal_mesh.mesh)], 2);
end