
%% check the orthonormality or the resulting space_modes
row = 1e2;
col = 1e2;
space_modes = rand(row, col);
time_modes = rand(col, row);

space_modes(:, 1) = space_modes(:, 1) / norm(space_modes(:, 1));

tic;
[orth_space_modes, updated_time_modes] = orthogonalise_space_modes(space_modes, time_modes, 'rsvd');
toc;

disp(norm(orth_space_modes'*orth_space_modes-eye(col), inf))
disp(norm(orth_space_modes*updated_time_modes-space_modes*time_modes, inf))

%% check how many modes are preserved and how many are changed
clc
x1 = [1, 0];
x2 = [0.5, 0.5];
X = [x1', x2'];

[orth_space_modes, r] = qr(X, 0); % (nicer shape functions)
disp(orth_space_modes);

[orth_space_modes, ~] = orthogonalise_space_modes(X, time_modes, 'household_qr');
disp(orth_space_modes);

rng(0);
time_modes = rand(2, 2);
[orth_space_modes, ~] = orthogonalise_space_modes(X*time_modes, time_modes, 'household_qr');
disp(orth_space_modes);

%% randomised svd vs svds
row = 4e4;
col = 4e4;
space_modes = rand(row, col);
f = @() randomised_svd(space_modes, 10);
timeit(f, 3)

%%
clc
row = 50547; % dof
col = 126;
space_modes = rand(row, col);
time_modes = rand(col, 33);

tic;
[orth_space_modes, updated_time_modes] = orthogonalise_space_modes(space_modes, time_modes, 'svds');
toc;

tic;
[orth_space_modes, updated_time_modes] = orthogonalise_space_modes(space_modes, time_modes, 'rsvd');
toc;

tic;
[orth_space_modes, updated_time_modes] = orthogonalise_space_modes(space_modes, time_modes, 'rsvd_decomposed');
toc;

%% this is the extreme case where each model updats the final modes
clc
clear
load('~/src/arch/results/data_compression/0_plate_damage_result/qoi.mat')
nmodes = 7;
space_mode = obj_to_save.results{1}.space_mode(:, 1:nmodes); % ngp dof
time_mode = obj_to_save.results{1}.time_mode(1:nmodes, :);
local_obj.minus_residual = obj_to_save.results{1}.dual;
numerical_model = obj_to_save.numerical_model;

% temporal update
f = @() time_update(space_mode, local_obj, numerical_model);
g = @() sqrt(diag(time_mode*time_mode')) ./ sqrt(diag(time_mode*time_mode'));
579 * (timeit(f, 1) + timeit(g, 1))

tic;
for nmodes = 1:120
    space_mode = obj_to_save.results{1}.V(:, 1:nmodes);
    time_mode = obj_to_save.results{1}.time_mode(1:nmodes, :);
    orthogonalise_space_modes(space_mode, time_mode, 'gram_schmidt');
end
toc;

tic;
for nmodes = [1:7, 7 * ones(1, 571)]
    space_mode = obj_to_save.results{1}.V(:, 1:nmodes);
    time_mode = obj_to_save.results{1}.time_mode(1:nmodes, :);
    orthogonalise_space_modes(space_mode, time_mode, 'svds_decomposed');
end
toc;

% orthonormalisation
% f=@() orthogonalise_space_modes(space_mode, time_mode, 'mgs');
% 125*(timeit(f,2))