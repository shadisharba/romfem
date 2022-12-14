function hydrostatic_operator = hydrostatic_identity(number_of_rows)
tensor_components = 6;
hydrostatic_operator = blkdiagmex(spones(ones(3))/3, zeros(3));
hydrostatic_operator = kron(speye(number_of_rows/tensor_components), hydrostatic_operator);
end
