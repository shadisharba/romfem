function nrm = space_time_norm(dual, primal, integral_inv_elasticity_tensor_diagonal, integral_elasticity_tensor_diagonal, temporal_mesh)
% should get a scalar at each integration point (stress:strain) then integrate over space and time
% devide by T (we have this term in both the nominator and demnuminator ...)
nrm = sqrt(sum(temporal_integration(...
    double_dot_product(primal, integral_elasticity_tensor_diagonal*primal)+double_dot_product(dual, integral_inv_elasticity_tensor_diagonal*dual),...
    temporal_mesh)));
end