function main(node_index, input_file_name)
% main(0,@test_latin)
% runromfem hermite 'main(0,@test_latin);exit;'

add_folder_to_path

if nargin == 0
    node_index = 0;
    input_file_name = @one_cycle;
end

% parallel pool settings
c = parcluster('local');
t = tempname();
mkdir(t);
c.JobStorageLocation = t;
poolobj = gcp('nocreate');

input_file_name();
global profiler;
global parallel;
global clean_output;

if clean_output
    % this will delete timing.txt
    !rm -rf output/*
end

if parallel
    if isempty(poolobj)
        parpool(c);
    end
    spmd
        rng(mod(str2double(datestr(now, 'yymmddHHMMSSFFF'))+1e1*labindex+1e2*node_index, 2^32-1), 'simdTwister');
        [solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = input_file_name();
        solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, false);
    end
    delete(poolobj);
else
    rng(0)
    [solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save] = input_file_name();
    if profiler
        sa_profile(@() solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save,false));
    else
        solver_factory(solver_parameters, user_mesh, user_material, user_boundary_conditions, user_load, cycles_to_save, false);
    end
end

end
