% function save_vtk(obj)
% works only with hex elements

exported_data = [];
input_structure = [];
% obj.results{1} = fRMField(obj.results{1},'init_acc_eps_p'); %  rmfield

fields = {'stress', 'damage'}; %, 'eps', 'eps_e', 'sigma', 'von_mises', 'u', 'j2_sigma', 'j2_eps'};
% for i = 1:length(obj_to_save.results)
    for field = fields
        if isfield(obj_to_save.results, field{:})
            input_structure.(field{:}) = full(obj_to_save.results.(field{:}));
        end
    end
% end

load('/home/alameddin/src/romfem/output/numerical_model.mat');

connectivity = numerical_model_obj.mesh.connectivity';
nodal_position = numerical_model_obj.mesh.nodal_coordinates;
extrapolation_matrix = numerical_model_obj.mesh.extrapolation_matrix;
ngp = numerical_model_obj.mesh.number_of_quadrature;
ntp = numerical_model_obj.temporal.dof;
name = 'output';
connectivity_transposed = connectivity';


% TODO use bindary

dcomp = 3; % displacement_components
tcomp = 6; % 2nd order tensor components
extrapolation = kron(speye(size(connectivity, 2)), extrapolation_matrix);
saving_path = 'output/vtk';
mkdir(saving_path);

i=0;
for time_point = 1:ntp
%     for i = 1:length(input_structure)
        try
            data_structure = input_structure;
            data_fields = fieldnames(data_structure);
            for field = data_fields'
                data = data_structure.(field{:});
                data = data(:, time_point);
                fld = sprintf('%s_%i', field{:}, i); % could be changed to sth in obj.fields
                if length(data) == ngp
                    exported_data.(fld) = [];
                    data_tmp = extrapolation * data;
                    data_tmp = accumarray(connectivity(:), data_tmp, [], @(x) mean(x)); % sorts,sums and averages
                    exported_data.(fld) = [exported_data.(fld), data_tmp];

                elseif length(data) / dcomp == size(nodal_position, 1) % nodal data: no acumulation or extrapolation
                    exported_data.(fld) = [];
                    for j = 1:dcomp
                        data_tmp = data(j:dcomp:end);
                        % data_tmp = reshape(data_tmp,siz,siz,siz);
                        exported_data.(fld) = [exported_data.(fld), data_tmp];
                    end

                elseif length(data) / 6 == ngp
                    exported_data.(fld) = [];
                    scaling_factor = [1, 1, 1, 1 / sqrt(2), 1 / sqrt(2), 1 / sqrt(2)];
                    for j = [1, 2, 3, 6, 4, 5] % xx yy zz xy yz xz % neon 0 4 8 1,3 5,7 2,6
                        data_tmp = data(j:tcomp:end); % collect based on the direction
                        data_tmp = extrapolation * (scaling_factor(j) .* data_tmp);
                        data_tmp = accumarray(connectivity(:), data_tmp, [], @(x) mean(x)); % sorts,sums and averages
                        exported_data.(fld) = [exported_data.(fld), data_tmp];
                    end
                    %             else
                    %                 error('neither displacement neither nor stress');
                end
            end
        end
%     end
    vtk_data_hex(nodal_position, connectivity_transposed, exported_data, sprintf('%s/%s_%d', saving_path, name, time_point));
end
% ! paraview 'output/vtk/output_..vtu'

% vals.U = [data.U{1},data.U{2},data.U{3}];
% vals.eps = [data.eps{1},data.eps{2},data.eps{3},data.eps{6}/sqrt(2),data.eps{4}/sqrt(2),data.eps{5}/sqrt(2)];

% vtkquiver(x,y,z,r,0*r,0*r,'velocity','vtkquiver.vtu');
% vtk_cpp(mesh.connectivity,x,y,z);

%     numerical_model.mesh.connectivity_en_fct   % nodes to elements
