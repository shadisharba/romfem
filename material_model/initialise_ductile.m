function global_fields = initialise_ductile(numerical_model, initial_guess)

n_gp = numerical_model.mesh.number_of_quadrature;
tensor_components = numerical_model.mesh.tensor_components;

if isempty(initial_guess)
    
    global_fields.elastic_result = elastic_solution(numerical_model);
    
    global_fields.initial_values.internal_plastic_strain = zeros(n_gp*tensor_components, 1);
    global_fields.initial_values.internal_kinematic = zeros(n_gp*tensor_components, 1);
    global_fields.initial_values.internal_isotropic = zeros(n_gp, 1);
    global_fields.initial_values.internal_damage = zeros(n_gp, 1);
    
    global_fields.stress = global_fields.elastic_result.stress;
    global_fields.strain = global_fields.elastic_result.strain;
    global_fields.sum_residual = pgd(zeros(n_gp*tensor_components, 1), [], numerical_model.temporal.mesh);
    
    % global_fields.displacement_spatial_modes = [];
    global_fields.strain_spatial_modes = [];
    global_fields.temporal_modes = [];
    
    % global_fields.displacement_spatial_modes = global_fields.elastic_result.displacement.spatial_modes;
    % global_fields.strain_spatial_modes = global_fields.elastic_result.strain.spatial_modes;
    % global_fields.temporal_modes = global_fields.elastic_result.displacement.temporal_modes;
    
    % internal variables
    global_fields.back_stress = zeros(n_gp*tensor_components, numerical_model.temporal.dof);
    global_fields.isotropic_hardening = zeros(n_gp, numerical_model.temporal.dof);
    global_fields.internal_damage = zeros(n_gp, numerical_model.temporal.dof);
else
    
    % The elstic solution satisfies the boundary conditions
    global_fields.elastic_result = initial_guess.elastic_result;
    
    global_fields.initial_values = initial_guess.initial_values;
    
    global_fields.stress = initial_guess.stress;
    global_fields.strain = initial_guess.strain;
    global_fields.sum_residual = initial_guess.sum_residual;
    
    % global_fields.displacement_spatial_modes = initial_guess.displacement_spatial_modes;
    global_fields.strain_spatial_modes = initial_guess.strain_spatial_modes;
    global_fields.temporal_modes = initial_guess.temporal_modes;
    
    % internal variables
    global_fields.back_stress = initial_guess.back_stress;
    global_fields.isotropic_hardening = initial_guess.isotropic_hardening;
    global_fields.internal_damage = initial_guess.internal_damage;
end

global_fields.number_of_modes = size(global_fields.strain_spatial_modes, 2);

end

%% test how good an initial guess is
% - obtain a solution
% - change initialise_ductile to start with zero initial values/conditions
% - deactivate copy_cyclic in duplicate_cycles
% - should converge within one iteration only
