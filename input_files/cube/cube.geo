// Gmsh project created on Thu Nov 16 22:26:03 2017

elements = 1;

x = 1.0;
y = 1.0;
z = 1.0;

number_of_coarse_elements = elements;
number_of_fine_elements = elements;

SetFactory("OpenCASCADE");
Box(1) = {0, 0, 0, x, y, z};
//+
Physical Surface("Zsym") = {5};
//+
Physical Surface("ZLoad") = {6};
//+
Physical Surface("Ysym") = {3};
//+
Physical Surface("Xsym") = {1};
//+
Physical Volume("cube") = {1};

Transfinite Line {11, 8, 9, 4, 2, 10, 6, 12} = number_of_coarse_elements+1 Using Bump 1;
Transfinite Line {3, 7, 5, 1} = number_of_fine_elements+1 Using Progression 1.3;
Transfinite Surface "*";
Recombine Surface "*";
Transfinite Volume "*";
