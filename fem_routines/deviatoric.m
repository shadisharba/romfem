function deviatoric_x = deviatoric(x)
deviatoric_identity_memoized = memoize(@deviatoric_identity);
deviatoric_x = deviatoric_identity_memoized(size(x, 1)) * x;
end

% SLOW
% deviatoric_1 = @(x) cell2mat(reshape(arrayfun(@(i)
% (x(i:i+5)-(sum(x(i:i+2))/3)*[1 1 1 0 0
% 0])',1:6:length(x(:))-5,'UniformOutput',false),[size(x,1)/6,size(x,2)]));
