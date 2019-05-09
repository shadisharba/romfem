function x = read_structure_from_binary(file_name)

fileID = fopen(file_name,'r');
while ~feof(fileID)
    siz = fread(fileID,2,'int')';
    if norm(siz)
        field = fread(fileID,siz ,'uint8=>char');
        siz = fread(fileID,2 ,'int')';
        x.(field) = fread(fileID,siz ,'double');
    end
end
fclose all;

end