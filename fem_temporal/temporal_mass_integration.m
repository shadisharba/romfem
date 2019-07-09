function integral_xy = temporal_mass_integration(x, y, temporal_mesh)
integral_xy = x * temporal_mesh.mass_integration_coefficient * y;
end
