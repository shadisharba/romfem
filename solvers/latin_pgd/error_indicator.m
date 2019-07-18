function indic = error_indicator(global_fields, local_fields, submesh, temporal_mesh, iter, indic, solver_parameters)

strain_increment = global_fields.strain - local_fields.strain;
stress_increment = global_fields.stress - local_fields.stress;

sum_strains = 0.5 * (global_fields.strain + local_fields.strain);
sum_stresses = 0.5 * (global_fields.stress + local_fields.stress);

if solver_parameters.error_indecator_pgd
    norm_addition = space_time_norm(sum_stresses, sum_strains, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
    norm_difference = space_time_norm(stress_increment, strain_increment, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
else
    norm_addition = space_time_norm(full(sum_stresses), full(sum_strains), submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
    norm_difference = space_time_norm(full(stress_increment), full(strain_increment), submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
end

indic(iter, 1) = norm_difference / norm_addition;

end
