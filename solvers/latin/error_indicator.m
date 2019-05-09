function indic = error_indicator(global_fields, submesh, temporal_mesh, iter, indic)

norm_difference = compute_norm(global_fields.stress_increment, global_fields.strain_increment, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
norm_addition = compute_norm(global_fields.sum_stresses, global_fields.sum_strains, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);

indic(iter, 1) = norm_difference / norm_addition;

end

function nrm = compute_norm(dual, primal, integral_inv_elasticity_tensor_diagonal, integral_elasticity_tensor_diagonal, temporal_mesh)
% should get a scalar at each integration point (stress:strain) then integrate over space and time
% devide by T (we have this term in both the nominator and demnuminator ...)
nrm = sqrt(sum(temporal_integration(double_dot_product(primal, integral_elasticity_tensor_diagonal*primal)+double_dot_product(dual, integral_inv_elasticity_tensor_diagonal*dual), temporal_mesh)));
end
