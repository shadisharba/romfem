%%
clc
load t1.mat
err_indicator = @() error_indicator(global_fields, submesh, temporal_mesh, iter, indic);
timeit(err_indicator)

load t2.mat
err_indicator = @() error_indicator(global_fields, submesh, temporal_mesh, iter, indic);
timeit(err_indicator)


%%
load t2.mat
norm_addition = @() space_time_norm(global_fields.sum_stresses, global_fields.sum_strains, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
norm_difference = @() space_time_norm(global_fields.stress_increment, global_fields.strain_increment, submesh.integral_inv_elasticity_tensor_diagonal, submesh.integral_elasticity_tensor_diagonal, temporal_mesh);
timeit(norm_addition)
timeit(norm_difference)


%% 
clc
rng(0)
A = rand(5e2,100);
A(:,end+1:end+5) = 1;
A(end+1:end+5,:) = 1;
tic
[q,r] = qr_decomp(A);
toc
tic
[q,r] = rsvd(A,10);
toc
