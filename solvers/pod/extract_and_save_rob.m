function extract_and_save_rob()

load('numerical_model.mat');

load('nr_solution.mat');

free_dof = numerical_model_obj.boundary_conditions.free_dof;
submesh = numerical_model_obj.submesh;

[u,s,v] = svds(nr_solution(1).results.displacement(free_dof,:),20);

semilogy(diag(s)/s(1))

save('pod_rob.mat','u');

end
