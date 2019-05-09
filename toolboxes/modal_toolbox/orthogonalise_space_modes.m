function [orth_space_modes, updated_time_modes] = orthogonalise_space_modes(space_modes, time_modes, type)
% Orthogonalisation for PGD space modes
% Only for modes statistically admissible to zero
% Modes over free degrees of freedom, No boundary conditions

% qr, gs and mgs preserve the already orthogonal modes or the first mode at
% least

switch type
    case 'qr' % QR decomposition
        [orth_space_modes, R] = qr(space_modes, 0);
        updated_time_modes = R * time_modes;
    case 'mgs' % Modified gram schmidt
        [orth_space_modes, R] = mgs_stewart(space_modes);
        updated_time_modes = R * time_modes;
    case 'orth'
        orth_space_modes = orth(space_modes);
        R = orth_space_modes \ space_modes;
        updated_time_modes = R * time_modes;
    case 'gs' % Gram schmidt
        [orth_space_modes, R] = gs_stewart(space_modes);
        updated_time_modes = R * time_modes;
    case 'household_qr' % household_qr
        [U, R] = house_qr_stewart(space_modes);
        orth_space_modes = house_apply(U, eye(size(U, 1)));
        updated_time_modes = R * time_modes;
    case 'gram_schmidt'
        [orth_space_modes, updated_time_modes] = gram_schmidt(space_modes,time_modes);
    case 'rsvd'
        K = size(space_modes, 2);
        [orth_space_modes, singular_values, normalised_time_modes] = randomised_svd(space_modes*time_modes, K);
        updated_time_modes = singular_values * normalised_time_modes';
        
        score_modes = (diag(singular_values) / singular_values(1));
        idx_del = score_modes < 1e-8;
        if sum(idx_del)
            orth_space_modes(:, idx_del) = [];
            updated_time_modes(idx_del, :) = [];
        end
    case 'svds'
        K = size(space_modes, 2);
        [orth_space_modes, singular_values, normalised_time_modes] = svds(space_modes*time_modes, K);
        updated_time_modes = singular_values * normalised_time_modes';
        
        score_modes = (diag(singular_values) / singular_values(1));
        idx_del = score_modes < 1e-8;
        if sum(idx_del)
            orth_space_modes(:, idx_del) = [];
            updated_time_modes(idx_del, :) = [];
        end
    case 'rsvd_decomposed' % randomised svd with compression of the spatial and temporal modes
        % this leads to a faster decay in the singular values than only
        % orthonormalising the spatial modes
        
        % SVD of a decomposed matrix
        K = size(space_modes, 2);
        [q_s, r_s] = qr(space_modes, 0);
        [q_t, r_t] = qr(time_modes', 0);
        
        [orth_space_modes, singular_values, normalised_time_modes] = randomised_svd(r_s*r_t', K);
        orth_space_modes = q_s * orth_space_modes;
        updated_time_modes = singular_values * normalised_time_modes' * q_t';
        
        %  updated_time_modes(:,1) = time_modes(:,1);
        
        % modes compression [this doesn't have effect when
        % orthonormalising space_modes instead of space_modes * time_modes]
        score_modes = (diag(singular_values) / singular_values(1));
        idx_del = score_modes < 1e-8; %parameter
        if sum(idx_del)
            orth_space_modes(:, idx_del) = [];
            updated_time_modes(idx_del, :) = [];
        end
    case 'svds_decomposed' 
        K = size(space_modes, 2);
        [q_s, r_s] = qr(space_modes, 0);
        [q_t, r_t] = qr(time_modes', 0);
        
        [orth_space_modes, singular_values, normalised_time_modes] = svds(r_s*r_t', K);
        orth_space_modes = q_s * orth_space_modes;
        updated_time_modes = singular_values * normalised_time_modes' * q_t';

        score_modes = (diag(singular_values) / singular_values(1));
        idx_del = score_modes < 1e-8; %parameter
        if sum(idx_del)
            orth_space_modes(:, idx_del) = [];
            updated_time_modes(idx_del, :) = [];
        end
    otherwise
        error('not implemented')
end
end