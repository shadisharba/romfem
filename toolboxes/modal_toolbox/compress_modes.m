function [spatial_modes, singular_values, temporal_modes] = compress_modes(spatial_modes, singular_values, temporal_modes, idx_to_delete)
spatial_modes(:, idx_to_delete) = [];
temporal_modes(:, idx_to_delete) = [];
singular_values(:, idx_to_delete) = [];
singular_values(idx_to_delete, :) = [];
end