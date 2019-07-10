function extract_and_save_rob()

clc
clear
close all

% results_path = uigetdir('output/nr');
results_path = 'output/nr';
names1 = dir([results_path, filesep, '*/qoi.mat']);

load('output/numerical_model.mat')

displacement = [];
for saved_cycle = 1:length(names1)
    nr_solution = load([names1(saved_cycle).folder, filesep, names1(saved_cycle).name]);
    displacement = [displacement, nr_solution.global_fields.displacement];
end

free_dof = numerical_model_obj.boundary_conditions.free_dof;
[u, s, ~] = svds(displacement(free_dof, :), size(displacement, 2));

semilogy(diag(s)/s(1))
save('output/pod_full_rob.mat', 'u');

end
