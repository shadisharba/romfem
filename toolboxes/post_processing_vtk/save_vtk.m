% function save_vtk(obj)
% works only with hex elements
[file, path] = uigetfile('output/*qoi.mat');
load(fullfile(path, file), 'global_fields');
load('/home/alameddin/src/romfem/output/numerical_model.mat');

exported_data = [];
input_structure = [];

fields = {'stress', 'strain', 'internal_damage', 'strain_spatial_modes'};
for field = fields
    if isfield(global_fields, field{:})
        input_structure.(field{:}) = full(global_fields.(field{:}));
    end
end

deviatoric_stress = deviatoric(global_fields.stress);
input_structure.equivalent_stress = sqrt(3/2.*double_dot_product(deviatoric_stress, deviatoric_stress));
input_structure.equivalent_strain = compute_equivalent_strain(global_fields.strain);
input_structure.equivalent_strain_spatial_modes = compute_equivalent_strain(global_fields.strain_spatial_modes);

connectivity = numerical_model_obj.mesh.connectivity';
nodal_position = numerical_model_obj.mesh.nodal_coordinates;
extrapolation_matrix = numerical_model_obj.mesh.extrapolation_matrix;
ngp = numerical_model_obj.mesh.number_of_quadrature;
ntp = numerical_model_obj.temporal.dof;
name = 'output';
connectivity_transposed = connectivity';

dcomp = 3; % displacement_components
tcomp = 6; % 2nd order tensor components
extrapolation = kron(speye(size(connectivity, 2)), extrapolation_matrix);
saving_path = 'output/vtk';
mkdir(saving_path);

for time_point = 1:ntp
    try
        data_structure = input_structure;
        data_fields = fieldnames(data_structure);
        for field = data_fields'
            fld = field{:};
            data = data_structure.(fld);
            data = data(:, time_point);
            
            if length(data) / dcomp == size(nodal_position, 1) % nodal data: no acumulation or extrapolation
                exported_data.(fld) = [];
                for j = 1:dcomp
                    data_tmp = data(j:dcomp:end);
                    exported_data.(fld) = [exported_data.(fld), data_tmp];
                end
                
            elseif length(data) == ngp
                exported_data.(fld) = [];
                data_tmp = extrapolation * data;
                data_tmp = accumarray(connectivity(:), data_tmp, [], @(x) mean(x)); % sorts,sums and averages
                exported_data.(fld) = [exported_data.(fld), data_tmp];
                
            elseif length(data) / 6 == ngp
                exported_data.(fld) = [];
                scaling_factor = [1, 1, 1, 1 / sqrt(2), 1 / sqrt(2), 1 / sqrt(2)];
                for j = [1, 2, 3, 6, 4, 5] % xx yy zz xy yz xz % neon 0 4 8 1,3 5,7 2,6
                    data_tmp = data(j:tcomp:end); % collect based on the direction
                    data_tmp = extrapolation * (scaling_factor(j) .* data_tmp);
                    data_tmp = accumarray(connectivity(:), data_tmp, [], @(x) mean(x)); % sorts,sums and averages
                    exported_data.(fld) = [exported_data.(fld), data_tmp];
                end
            else
                error('neither nodal nor integration point values');
            end
        end
    end
    vtk_data_hex(nodal_position, connectivity_transposed, exported_data, sprintf('%s/%s_%d', saving_path, name, time_point));
end
!source ~/.bashrc && /usr/bin/paraview 'output/vtk/output_..vtu'

% vtkquiver(x,y,z,r,0*r,0*r,'velocity','vtkquiver.vtu');
% vtk_cpp(mesh.connectivity,x,y,z);

%% paraview: tools - start trace
% macros
% view - python shell
% file - save state
% https://www.paraview.org/Wiki/ParaView_and_Python
% https://www.paraview.org/Wiki/ParaView/Python_Scripting