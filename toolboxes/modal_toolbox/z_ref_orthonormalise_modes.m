error('this function is not maintained');

% function x = orthonormalise_modes(x, type)
% Orthogonalisation for spatial modes

% qr, gs and mgs preserve the already orthogonal modes or the first mode at
% least

% SVD leads to a faster decay in the singular values than only
% orthonormalising the spatial modes due to the compression of the spatial and temporal modes

% assert(isa(x, 'pgd'))
% switch type
%     case 'rsvd' % SVD of a decomposed matrix
%         [q_s, r_s] = qr(x.spatial_modes, 0);
%         [q_t, r_t] = qr(x.temporal_modes', 0);
%         
%         [orth_spatial_modes, singular_values, orth_temporal_modes] = randomised_svd(r_s*r_t', size(x));
%         x = pgd(q_s * orth_spatial_modes,singular_values,orth_temporal_modes' * q_t');
%         
%     case 'svds'
%         [q_s, r_s] = qr(x.spatial_modes, 0);
%         [q_t, r_t] = qr(x.temporal_modes', 0);
%         
%         [orth_spatial_modes, singular_values, orth_temporal_modes] = svds(r_s*r_t', size(x));
%         x = pgd(q_s * orth_spatial_modes,singular_values,orth_temporal_modes' * q_t');
%         
%     otherwise
%         error('not implemented')
% end

% rejection_tol = 1e-8; %parameter
% score_modes = (diag(singular_values) / singular_values(1));
% idx_del = score_modes < rejection_tol;
% if sum(idx_del)
%     [orth_spatial_modes,updated_time_modes] = compress_mode(orth_spatial_modes,singular_values,orth_temporal_modes,idx_del);
% end
% end

% case 'gram_schmidt'
%     [orth_space_modes, updated_time_modes] = gram_schmidt(space_modes,time_modes);
%     idx_del = false(size(space_modes,2),1);
%     if norm(updated_time_modes(end, :))/norm(updated_time_modes(1, :)) < rejection_tol
%         idx_del(end) = true;
%     end
%     if sum(idx_del)
%         [orth_space_modes,updated_time_modes] = compress_mode(orth_space_modes,updated_time_modes,idx_del);
%     end

%     case 'qr' % QR decomposition
%         [orth_space_modes, R] = qr(space_modes, 0);
%         updated_time_modes = R * time_modes;
%     case 'mgs' % Modified gram schmidt
%         [orth_space_modes, R] = mgs_stewart(space_modes);
%         updated_time_modes = R * time_modes;
%     case 'orth'
%         orth_space_modes = orth(space_modes);
%         R = orth_space_modes \ space_modes;
%         updated_time_modes = R * time_modes;
%     case 'gs' % Gram schmidt
%         [orth_space_modes, R] = gs_stewart(space_modes);
%         updated_time_modes = R * time_modes;
%     case 'household_qr' % household_qr
%         [U, R] = house_qr_stewart(space_modes);
%         orth_space_modes = house_apply(U, eye(size(U, 1)));
%         updated_time_modes = R * time_modes;
%     case 'gram_schmidt'

%% orthogonalise_space_modes_innerproduct
% function [orth_space_modes, updated_time_modes] = orthogonalise_space_modes_innerproduct(space_modes, time_modes, type, inner_product_L)
% % L: lower triangular matrix of the inner product metric M = L*L'
% error('this function is not maintained');
% 
% space_modes_l = inner_product_L' * space_modes;
% [orth_space_modes_l, updated_time_modes] = orthogonalise_space_modes(space_modes_l, time_modes, type);
% orth_space_modes = (inner_product_L' \ orth_space_modes_l);
% 
% %% check the orthogonality
% % diag(U'*M*U)
% end
% 
% %         % better weight for the time functions when using an energy inner product
% 
% %     case 'svd_inner_product'
% %         % SVD
% %         % input_solution is multiplied by inner_product_L' in order to
% %         % maintain the original solution when multiplying the space and
% %         % time modes
