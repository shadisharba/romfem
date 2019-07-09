function [q,r] = qr_decomp(x)
  [q,r] = qr(x,0);
  idx_delete = abs(vecnorm(r,2,2)) < eps;
  idx_delete(1) = 0;
  q(:,idx_delete) = [];
  r(idx_delete,:) = [];
end
