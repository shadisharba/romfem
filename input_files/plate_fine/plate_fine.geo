GROSD1 = 10 ;
PETID1 = 5 ;
RAYO1 = 2 ;
DENS1 = 1; // mesh density
R = 15;
r = 5;
PETIT1 = (GROSD1 - PETID1) ;
LONG1 = 2 * GROSD1 ;

Point(1) = {0,RAYO1,0};
Point(2) = {0,LONG1,0};
Point(3) = {GROSD1,LONG1,0};
Point(4) = {GROSD1,0,0};
Point(5) = {PETIT1,0,0};
Point(6) = {(PETIT1 - RAYO1),RAYO1,0};

Line(1) = {1,2} ;
Line(2) = {2,3} ;
Line(3) = {3,4} ;
Line(4) = {4,5} ;
Point(100) = {(PETIT1 - RAYO1),0,0};
Circle(5) = {5,100,6};
Line(6) = {6,1} ;
Line Loop(1) = {1,2,3,4,5,6} ;
Plane Surface(1) = {1};

Rotate {{1, 0, 0}, {1, 0, 0}, Pi/2} {
  Surface{1};
}

//+
Extrude {0, 1, 0} {
  Surface{1}; Line{2}; Line{3}; Line{4}; Line{5}; Line{6}; Line{1}; Layers{6}; Recombine;
}

//+
Physical Surface("ZLoad") = {21};
//+
Physical Surface("Zsym") = {29};
//+
Physical Surface("Xsym") = {17};
//+
Physical Surface("Ysym") = {1};
//+
Physical Volume("plate_fine") = {1};
