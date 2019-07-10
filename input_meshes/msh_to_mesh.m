[file, path] = uigetfile('input_files/*.msh');
[status, cmdout] = system(sprintf('source ~/.bashrc && imr --zero-based %s', fullfile(path, file)), '-echo');
assert(status == 0)

% gmsh -3 cube.geo -o cube.msh
% gmsh -refine cube.msh -o cube_r1.msh
% gmsh -refine cube_r1.msh -o cube_r2.msh

% [~,index_A,index_B] = intersect(A,B,'rows');
% C = intersect(A,B,'rows')
% index_A= find(ismember(A,C,'rows'));
% index_B= find(ismember(B,C,'rows'));
