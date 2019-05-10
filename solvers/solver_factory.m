function [current_solution, accumulated_solutions] = solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, accumulate_solutions)
global build_mode_debug;

current_solution = [];
accumulated_solutions = [];
y = zeros(length(user_load)+1, 1);

for cycle_number = 1:length(user_load) % compute the cycles incrementally
    
    if build_mode_debug
        fprintf('\t computed_cycles %d \n', cycle_number);
    end
    
    if ~isempty(current_solution)
        [scaling_factor, shift] = user_load(cycle_number).scaling_factor(user_load(cycle_number-1));
        current_solution = duplicate_cycles(current_solution, scaling_factor, shift);
    end
    
    if strcmp(solver_parameters.solver, 'nr')
        current_solution = newton_solver(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load(cycle_number), sum(cycle_number == cycles_to_save), current_solution);
    elseif strcmp(solver_parameters.solver, 'nr_pod')
        rb = load('pod_rob.mat');
        current_solution = newton_solver_pod(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load(cycle_number), sum(cycle_number == cycles_to_save), current_solution, rb.u);
    elseif strcmp(solver_parameters.solver, 'latin')
        current_solution = latin_solver(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load(cycle_number), sum(cycle_number == cycles_to_save), current_solution);
    else
        error('not implemented');
    end
    
    if sum(cycle_number == cycles_to_save)
        fprintf('******* cycle %5d \n', cycle_number);
    end
    if isempty(current_solution)
        return
    end
    if accumulate_solutions
        accumulated_solutions(cycle_number).results = current_solution.results;
    end
    
    y(cycle_number+1) = max(current_solution.results.internal_damage(:));
    
end

x = linspace(0, length(user_load), length(user_load)+1)';
file_name = ['output/damage', datestr(now, 'yyyymmdd_HHMMSSFFF'), num2str(randi(1e6)), '.mat'];
while exist(file_name, 'file')
    file_name = ['output/damage', datestr(now, 'yyyymmdd_HHMMSSFFF'), num2str(randi(1e6)), '.mat'];
end
save(file_name, '-mat', 'x', 'y', '-v6');

end
