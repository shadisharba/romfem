function cum_integral_x = temporal_cumulative_integration(x, temporal_mesh)
cum_integral_x = x .* temporal_mesh.integration_coefficient;
cum_integral_x = cumsum(cum_integral_x, 2);
end