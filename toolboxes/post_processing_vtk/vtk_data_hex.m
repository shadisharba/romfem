% Modified from https://www.mathworks.com/matlabcentral/fileexchange/33656-vtkpipe
% version 1.0.0.0 (5.54 KB) by LeFlaux
%
% Author:     Florian Frank
% eMail:      snflfran@gmx.net
% Version:    1.00
% Date:       Jun 16th, 2010
%
% Copyright see license.txt

function vtk_data_hex(nodal_position, connectivity, data, filename)
% assert(ischar(varname) && ischar(filename))

hex8_elem = 12;
hex8_offset = 8;
hex20_elem = 25;
quad8_elem = 23;
quad4_elem = 9;

numC = size(connectivity, 1); % number of cells
if size(nodal_position, 1) ~= 3
    nodal_position = nodal_position';
end
numP = size(nodal_position, 2); % number of points

if ~strcmp(filename(end-3:end), '.vtu') % append file extension if not specified yet
    filename = [filename, '.vtu'];
end
file = fopen(filename, 'wt'); % OPEN FILE

% HEADER
fprintf(file, '<?xml version="1.0"?>\n');
fprintf(file, '<VTKFile type="UnstructuredGrid" version="0.1" byte_order="LittleEndian" compressor="vtkZLibDataCompressor">\n');
fprintf(file, '  <UnstructuredGrid>\n');
fprintf(file, '    <Piece NumberOfPoints="%d" NumberOfCells="%d">\n', numP, numC);

% POINTS / nodal points position
fprintf(file, '      <Points>\n');
fprintf(file, '        <DataArray type="Float32" NumberOfComponents="3" format="ascii">\n');
fprintf(file, '          %.3e %.3e %.3e\n', nodal_position);
fprintf(file, '        </DataArray>\n');
fprintf(file, '      </Points>\n');

% CELLS / elements base on the nodal connectivity
fprintf(file, '      <Cells>\n');
fprintf(file, '        <DataArray type="Int32" Name="connectivity" format="ascii">\n');
fprintf(file, '           %d %d %d %d %d %d %d %d \n', connectivity'-1);
fprintf(file, '        </DataArray>\n');
fprintf(file, '        <DataArray type="Int32" Name="offsets" format="ascii">\n'); % cell offset
fprintf(file, '           %d\n', (1:numC)*hex8_offset);
fprintf(file, '        </DataArray>\n');
fprintf(file, '        <DataArray type="UInt8" Name="types" format="ascii">\n'); % cell type
fprintf(file, '           %d\n', repelem(hex8_elem, numC, 1));
fprintf(file, '        </DataArray>\n');
fprintf(file, '      </Cells>\n');

% PointData
fprintf(file, '      <PointData>\n');
data_fields = fieldnames(data);
for field = data_fields'
    vtk_data = data.(field{:});
    if size(vtk_data, 1) == numP
        fprintf(file, '        <DataArray type="Float32" Name="%s" NumberOfComponents="%d" format="ascii">\n', field{:}, size(vtk_data, 2));
        fprintf(file, '          %.3e ', vtk_data');
        fprintf(file, '\n        </DataArray>\n');
    end
end
fprintf(file, '      </PointData>\n');

% CellData
fprintf(file, '      <CellData>\n');
data_fields = fieldnames(data);
for field = data_fields'
    vtk_data = data.(field{:});
    if size(vtk_data, 1) == numC
        fprintf(file, '        <DataArray type="Float32" Name="%s" NumberOfComponents="%d" format="ascii">\n', field{:}, size(vtk_data, 2));
        fprintf(file, '          %.3e ', vtk_data');
        fprintf(file, '\n        </DataArray>\n');
    end
end
fprintf(file, '      </CellData>\n');

% FOOTER
fprintf(file, '    </Piece>\n');
fprintf(file, '  </UnstructuredGrid>\n');
fprintf(file, '</VTKFile>\n');
fclose(file);
end
