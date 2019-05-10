function extract_and_save_rob()

clc
clear

!mv output/numerical_model.mat .

load('numerical_model.mat');
load('nr_solution.mat');

free_dof = numerical_model_obj.boundary_conditions.free_dof;
[u, s, ~] = svds(nr_solution(1).results.displacement(free_dof, :), size(nr_solution(1).results.displacement, 2));

semilogy(diag(s)/s(1))
save('pod_rob_full.mat', 'u');

end
