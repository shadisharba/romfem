function add_folder_to_path()

output_folder = fullfile(pwd, 'output');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

addpath(genpath('examples'));
addpath(genpath('fem_routines'));
addpath(genpath('fem_spatial'));
addpath(genpath('fem_temporal'));
addpath(genpath('input_meshes'));
addpath(genpath('solvers'));
addpath(genpath('temporal_scheme'));
addpath(genpath('material_model'));
addpath(genpath('modes_toolbox'));
addpath(genpath('toolboxes'));
addpath(genpath('submodules'));

feature accel on
% setenv('LD_LIBRARY_PATH','');   % setenv('LD_LIBRARY_PATH',pwd);
% setenv('LD_PRELOAD','');    %  setenv LD_PRELOAD /lib/libgcc_s.so.1
% mtimesx('SPEEDOMP', 'OMP_SET_NUM_THREADS(8)'); % mtimesx

% MBeautify.formatCurrentEditorPage(true)
% MBeautify.formatFiles('/home/alameddin/src/romfem/', '*.m')
% folders = dir;
% for folder = folders'
%     MBeautify.formatFiles(fullfile(pwd, folder.name), '*.m')
% end

% dbstop if error // dbstop error
% ! rm -rf output/*
% ! git worktree add ../dellllllllllll
end
