function indic = error_indicator(global_fields, submesh, temporal_mesh, iter, indic)

norm_addition = space_time_norm(global_fields.sum_stresses, global_fields.sum_strains, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
norm_difference = space_time_norm(global_fields.stress_increment, global_fields.strain_increment, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);

indic(iter, 1) = norm_difference / norm_addition;

end
