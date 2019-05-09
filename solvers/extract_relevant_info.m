function obj = extract_relevant_info(numerical_model, global_fields, parameters, cycles_to_save)
global build_mode_debug;
global save_mat_files;

global_fields = frmfield(global_fields, {'strain_increment', 'stress_increment'}); % strain stress back_stress isotropic_hardening

if save_mat_files && build_mode_debug && cycles_to_save
    save(sprintf('%s/qoi.mat', parameters.output_path), '-mat', 'global_fields', '-v6');
end

obj.results = global_fields;
obj.numerical_model = numerical_model;
end

% clc
% clear all
%
% x = rand(1, 2e8);   % 1.6GB data
% tic;
% f = fopen('aaavaa.dat', 'w');
% fwrite(f, x, 'double');
% fclose(f);
% toc
%
% tic
% save('aaaaa.mat','x','-v6');
% toc

% % Elapsed time is 0.515016 seconds.
% % Elapsed time is 0.537325 seconds.