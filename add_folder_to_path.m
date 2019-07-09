function add_folder_to_path()

addpath(genpath('examples'));
addpath(genpath('fem_routines'));
addpath(genpath('fem_spatial'));
addpath(genpath('fem_temporal'));
addpath(genpath('input_files'));
addpath(genpath('input_meshes'));
addpath(genpath('solvers'));
addpath(genpath('temporal_scheme'));
addpath(genpath('material_model'));
addpath(genpath('modes_toolbox'));
addpath(genpath('toolboxes'));
addpath(genpath('submodules'));

% dbstop if error // dbstop error

% MBeautify.formatCurrentEditorPage(true)
% MBeautify.formatFiles('/home/alameddin/src/romfem/', '*.m')
% folders = dir;
% for folder = folders'
%     MBeautify.formatFiles([pwd, filesep, folder.name], '*.m')
% end

% ! rm -rf output/*

% ! git worktree add ../dellllllllllll
end
