// -----------------------------------------------------------------------------------
// Author: Neerav Goswami (Sommer Lab), 2023
//
// Combines all the input tissue surfaces into a .msh volumetric mesh.
// -----------------------------------------------------------------------------------

Mesh.Algorithm3D=4; //1=delaunay (tetgen) and 4=frontal (netgen)
Mesh.Optimize=1;
Mesh.OptimizeNetgen=1;

Surface Loop(1) = {1};
Surface Loop(2) = {2};
Surface Loop(3) = {3};
Surface Loop(4) = {4};
Surface Loop(5) = {5};

Volume(1) = {1};
Volume(2) = {1,2};
Volume(3) = {2,3};
Volume(4) = {3,4};
Volume(5) = {4,5};

Physical Surface(1) = {1};
Physical Surface(2) = {2};
Physical Surface(3) = {3};
Physical Surface(4) = {4};
Physical Surface(5) = {5};

Physical Volume(1) = {1};
Physical Volume(2) = {2};
Physical Volume(3) = {3};
Physical Volume(4) = {4};
Physical Volume(5) = {5};
