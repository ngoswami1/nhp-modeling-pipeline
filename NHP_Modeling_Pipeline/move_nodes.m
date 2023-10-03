function [p,transmat] = move_nodes(p_in,x,y,z,yaw,pitch,roll)

% -----------------------------------------------------------------------------------
% Author: Neerav Goswami (Sommer Lab), 2023
%
% Linearly transforms a triangular mesh in global space. The output
% 'transmat' is meant to be used in SimNIBS to describe the translation and
% rotation of the coil relative to the origin.
%
% inputs:
%
% p_in - An nx3 matrix containing the vertices of the mesh.
% x - An integer indicating the displacement in the x direction.
% y - An integer indicating the displacement in the y direction.
% z - An integer indicating the displacement in the z direction.
% yaw - An integer indicating the amount of rotation about the z-axis.
% pitch - An integer indicating the amount of rotation about the y-axis.
% roll - An integer indicating the amount of rotation about the x-axis.
%
% outputs:
%
% p - An nx3 matrix containing the transformed vertices of the mesh.
% transmat - A 4x4 matrix describing the transformation.
% -----------------------------------------------------------------------------------

% convert angles to radians
yaw = yaw*(pi/180);
pitch = pitch*(pi/180);
roll = roll*(pi/180);

% calculate transformation matrix
R1(:,1) = [cos(yaw),-sin(yaw),0];
R1(:,2) = [sin(yaw),cos(yaw),0];
R1(:,3) = [0,0,1];
R2(:,1) = [cos(pitch),0,-sin(pitch)];
R2(:,2) = [0,1,0];
R2(:,3) = [sin(pitch),0,cos(pitch)];
R3(:,1) = [1,0,0];
R3(:,2) = [0,cos(roll),sin(roll)];
R3(:,3) = [0,-sin(roll),cos(roll)];
R = R3*R2*R1;
vhat1 = R(:,1);
vhat2 = R(:,2);
nhat = R(:,3);
transmat = R;
transmat(:,4) = [x y z]';
transmat(4,:) = [0 0 0 1];

% apply transformation matrix to mesh vertices
p = zeros(size(p_in));
p(1:end,1) = p_in(:,1)*vhat1(1)+p_in(:,2)*vhat2(1)+p_in(:,3)*nhat(1)+x;
p(1:end,2) = p_in(:,1)*vhat1(2)+p_in(:,2)*vhat2(2)+p_in(:,3)*nhat(2)+y;
p(1:end,3) = p_in(:,1)*vhat1(3)+p_in(:,2)*vhat2(3)+p_in(:,3)*nhat(3)+z;