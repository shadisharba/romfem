% dublicate QoI and scale it depending on the load
function R_out = duplicate_cycles(R_in, scaling_factor, shift)

R_out = R_in;

% scale the elastic solution to be used in the follwoing cycle
for field = fieldnames(R_in.results.elastic_result)'
    R_out.results.elastic_result.(field{:}) = pgd(R_in.results.elastic_result.(field{:}).spatial_modes, [], R_in.results.elastic_result.(field{:}).temporal_modes.*scaling_factor+shift);
    % TODO: is + shift correct here?
    if sum(shift)
        error('shift is not verified yet');
    end
end

if ~isempty(R_in.results.temporal_modes)
    R_out.results.temporal_modes = copy_cyclic(R_in.results.temporal_modes, scaling_factor, shift);
end

R_out.results.stress = copy_cyclic(R_in.results.stress, scaling_factor, shift);
R_out.results.strain = copy_cyclic(R_in.results.strain, scaling_factor, shift);
R_out.results.sum_residual = copy_cyclic(R_in.results.sum_residual, scaling_factor, shift);

% internal variables
R_out.results.back_stress = copy_cyclic(R_in.results.back_stress, scaling_factor, shift);
R_out.results.isotropic_hardening = repmat(R_in.results.isotropic_hardening(:, end), [1, size(R_in.results.isotropic_hardening, 2)]);
R_out.results.internal_damage = repmat(R_in.results.internal_damage(:, end), [1, size(R_in.results.internal_damage, 2)]);

% plot([R_in.results.elastic_result.(field{:}).temporal_modes,nan,R_out.results.elastic_result.(field{:}).temporal_modes])
% id6 = 148 * 6 - 3;
% plot([R_in.results.stress(id6,:),nan,R_out.results.stress(id6,:)])
end
