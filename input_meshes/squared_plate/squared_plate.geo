// Gmsh project created on Mon Sep  4 15:49:47 2017
//+
SetFactory("OpenCASCADE");
Block(1) = {0, 0, 0, 10, 0.5, 10};
//+
Cylinder(2) = {0, 0, 0, 0, 0.5, 0, 2, 2*Pi};
//+
BooleanDifference{ Volume{1}; Delete; }{ Volume{2}; Delete; }
//+
Physical Surface("zsym") = {6};
//+
Physical Surface("zload") = {3};
//+
Physical Surface("xsym") = {1};
//+
Physical Surface("ysym") = {2};



/////////////////////////////////////////////////////////////
//lc = 8;
//Field[6] = Box;
//Field[6].VIn = lc / 50;
//Field[6].VOut = lc;
//b=3.3;
//Field[6].XMin = 2;
//Field[6].XMax = 4;
//Field[6].YMin = -b;
//Field[6].YMax = b;
//Field[6].ZMin = -b;
//Field[6].ZMax = 2;

// Many other types of fields are available: see the reference manual for a
// complete list. You can also create fields directly in the graphical user
// interface by selecting Define->Fields in the Mesh module.

// Finally, let's use the minimum of all the fields as the background mesh field
// Field[7] = Min;
// Field[7].FieldsList = {1,2, 3, 5, 6};
// Background Field = 7;

//lc = 8;
//b=3.3;
//Field[6] = Cylinder; //Box;
//Field[6].VIn = lc / 48;
//Field[6].VOut = lc;

//Field[6].Radius = b;
//Field[6].XAxis = 0;
//Field[6].YAxis = 2;
//Field[6].ZAxis = 0;
//Field[6].XCenter = 0;
//Field[6].YCenter = 0;
//Field[6].ZCenter = 0;
//+
Physical Volume("squared_plate") = {1};
