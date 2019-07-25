function deviatoric_operator = deviatoric_identity(number_of_rows)
tensor_components = 6;
deviatoric_operator = speye(tensor_components);
deviatoric_operator(1:3, 1:3) = deviatoric_operator(1:3, 1:3) - 1 / 3;
deviatoric_operator = kron(speye(number_of_rows/tensor_components), deviatoric_operator);
end

% 2D
% deviatoric_operator = speye(3);
% deviatoric_operator(1:2, 1:2) = deviatoric_operator(1:2, 1:2) - 1 / 2;
% deviatoric_operator = kron(speye(number_of_rows/3), deviatoric_operator);
