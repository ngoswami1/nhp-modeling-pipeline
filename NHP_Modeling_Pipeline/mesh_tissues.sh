#!/bin/bash

# -----------------------------------------------------------------------------------
# Author: Neerav Goswami (Sommer Lab), 2023
#
# Takes the 5 (or 6 if implant is included) tissue masks and creates surfaces and
# a SimNIBS-compatible volumetric mesh out of them. All tissues are presumed to
# be named "WM.nii.gz", "GM.nii.gz", "CSF.nii.gz", "Skull.nii.gz", and "Scalp.nii.gz"
# for white matter, gray matter, CSF, skull, and scalp, respectively. These names
# can be edited in this file. Requires FSL, Freesurfer, SimNIBS, and Gmsh installed.
#
# input flags:
#
# -p: Path to directory that has the tissue masks. Default is the directory that
# this script is saved in.
#
# -l: Flag to run volumetric layer python script. Is either 0 or 1. Default is 0.
#
# -i: Flag to indicate if an implant mask is included. Is either 0 or 1. Default is 0.
#
# Example: ./mesh_tissues.sh -p ./NHP_Subject_T -l 1 -i 1
#
# output:
#
# The script outputs surfaces for each tissue mask and a volumetric mesh combining
# them. Optionally, it also creates a continuous layer probability out of the
# gray matter mask.
# -----------------------------------------------------------------------------------

# Process flags
implant=0
layer=0
path="."
while getopts i:l:p: flag
do
  case "${flag}" in
    i) implant=${OPTARG};;
    l) layer=${OPTARG};;
    p) path=${OPTARG};;
  esac
done

# Collect tissue names and assign number of vertices for each surface
tissues=("WM" "GM" "CSF" "Skull" "Scalp" "Implant")
vertices=(40000 40000 10000 5000 5000 1000)

# Run layer generation if layer flag is 1
if [ $layer -eq 1 ]
then
  echo "Running volume preserving method for layer generation..."
  python3 layer_test.py $path/${tissues[0]}.nii.gz $path/${tissues[1]}.nii.gz
else
  echo "Skipping layer generation."
fi

mkdir -p ./monkey/
mkdir -p ./res/

if [ $implant -eq 0 ]
then
  nr=5
else
  nr=6
fi

# Create surfaces. Uncomment the "fslorient" line if masks need to be translated and/or rotated in space.
echo "Creating surfaces from tissue masks..."
nr=${#tissues[@]}
for(( i=0; i<${nr}; i++ ));
do
  tissue=${tissues[$i]}
  vertex=${vertices[$i]}
  cp $path/$tissue.nii.gz ./monkey/$tissue.nii.gz
  #fslorient -setqform 0 0 1 -40 -0.5 -0.866 0 100 0.866 -0.5 0 0 0 0 0 1 ./monkey/$tissue.nii.gz
  mri_convert  -odt uchar ./monkey/$tissue.nii.gz ./res/$tissue.nii.gz
  mri_tessellate -n ./res/$tissue.nii.gz 255 ./res/$tissue.fsmesh
  mris_smooth -n 5 ./res/$tissue.fsmesh ./res/$tissue.fsmesh
  mris_convert ./res/$tissue.fsmesh ./res/$tissue.stl
  meshfix ./res/$tissue.stl -a 1.0 -u 5 --vertices $vertex -q -s -o ./res/$tissue
  meshfix ./res/$tissue.stl -a 1.0 -q -s -o ./res/$tissue 
  meshfix ./res/$tissue.stl -a 1.0 -u 1 -q -s -o ./res/$tissue
  meshfix ./res/$tissue.stl -a 1.0 -q -s -o ./res/$tissue
   
echo "Processing tissue surfaces..."
if [ $i -gt 0 ] && [ $i -lt 5]
then
 ind=`expr $i - 1`
 last_tissue=${tissues[ind]}
  while meshfix ./res/$tissue.stl ./res/$last_tissue.stl --shells 2 --no-clean --intersect; do
   meshfix ./res/$tissue.stl ./res/$last_tissue.stl -a 1.0 --shells 2 --decouple-outout 0 -s -o ./res/$tissue
   meshfix ./res/$tissue.stl ./res/$last_tissue.stl -a 1.0 --shells 2 --cut-inner 0 -s -o ./res/$tissue
   meshfix ./res/$tissue.stl -a 1.0 -u 1 -s -o ./res/$tissue
  done
fi
  gmsh ./res/$tissue.stl -1 -o ./res/$tissue.stl -bin

# Create volumetric mesh from surfaces
done
echo "Creating volumeric mesh from surfaces..."
gmsh ./res/${tissues[0]}.stl -merge ./res/${tissues[1]}.stl -merge ./res/${tissues[2]}.stl -merge ./res/${tissues[3]}.stl -merge ./res/${tissues[4]}.stl -3 -bin -o NHP_Subject.msh mesh_tissues.geo
echo "done."

