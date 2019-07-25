function obj = extract_relevant_info(numerical_model_obj, global_fields, err_indicator, cycles_to_save, save_mat_files)

global_fields = frmfield(global_fields, {'strain_increment', 'stress_increment'}); % strain stress back_stress isotropic_hardening

if save_mat_files && cycles_to_save
    % https://undocumentedmatlab.com/blog/trapping-warnings-efficiently
    s = warning('error','MATLAB:save:sizeTooBigForMATFile');
    try
        save(sprintf('%s/qoi.mat', numerical_model_obj.solver_parameters.output_path), '-mat', 'global_fields', 'err_indicator', '-v6');
    catch ME
        save(sprintf('%s/qoi.mat', numerical_model_obj.solver_parameters.output_path), '-mat', 'global_fields', 'err_indicator', '-v7.3', '-nocompression');
    end
    warning(s);
end

obj.results = global_fields;
obj.numerical_model = numerical_model_obj;
end

% it's faster to store the results in /tmp/
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