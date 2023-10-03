function [img] = remove_outer_pixels(img)
% -----------------------------------------------------------------------------------
% Author: Neerav Goswami (Sommer Lab), 2023
%
% Removes pixels on the border of a 3D image in all dimensions.
%
% inputs:
%
% img - Input 3-dimensional image.
%
% outputs:
%
% img - Processed 3-dimentional image.
% -----------------------------------------------------------------------------------

img(1,:,:) = 0;
img(2,:,:) = 0;
img(end,:,:) = 0;
img(end-1,:,:) = 0;
img(:,1,:) = 0;
img(:,2,:) = 0;
img(:,end,:) = 0;
img(:,end-1,:) = 0;
img(:,:,1) = 0;
img(:,:,2) = 0;
img(:,:,end) = 0;
img(:,:,end-1) = 0;