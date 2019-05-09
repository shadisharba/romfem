function save_structure_to_binary(output_path, x)

fileID = fopen(sprintf('%s/qoi.dat', output_path), 'w');
for field = fieldnames(x)'
    fwrite(fileID, size(field{:}), 'int');
    fwrite(fileID, field{:}, 'uint8');
    fwrite(fileID, size(x.(field{:})), 'int');
    fwrite(fileID, full(x.(field{:})), 'double');
end
fclose all;

end

% extension:
% sparse is not supported and full() is used but the underlying data
% structure of sparse matrices may be saved find() -> (row, col, val) for instance
% which should be more efficient than using full()

% can be extended to look for nested structures as well
