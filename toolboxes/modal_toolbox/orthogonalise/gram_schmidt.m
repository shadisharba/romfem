function [space_modes, time_modes] = gram_schmidt(space_modes, time_modes)

[~, mu] = size(space_modes);

for k = 1:mu-1
    p = space_modes(:, k)' * space_modes(:, end);
    space_modes(:, end) = space_modes(:, end) - p * space_modes(:, k);
    time_modes(k, :) = time_modes(k, :) + p * time_modes(end, :);
end

new_norm = norm(space_modes(:, end));

space_modes(:, end) = space_modes(:, end) / new_norm;
time_modes(end, :) = time_modes(end, :) * new_norm;

end