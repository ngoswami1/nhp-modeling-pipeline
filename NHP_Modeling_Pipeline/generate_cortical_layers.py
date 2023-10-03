# -----------------------------------------------------------------------------------
# Author: Neerav Goswami (Sommer Lab), 2023
# 
# Generates a continuous depth map from 0 (outer surface of white matter) to 1
# (outer surface of gray matter). Layers can be defined as proportions from 0 to 1.
#
# Takes the path to the white matter mask and the gray matter mask (in that order)
# as input from the command line. Requires the nighres python library.
#
# The continuous depth map is saved as NHP_Subject_layer-depth.nii.gz.
# 
# -----------------------------------------------------------------------------------

import argparse
import nighres

parser = argparse.ArgumentParser(description='Generate a continuous depth map of the gray matter.')
parser.add_argument('wm_path', metavar='WM_FILE')
parser.add_argument('gm_path', metavar='GM_FILE')

args = parser.parse_args()
print(args)

wm = args.wm_path
gm = args.gm_path

save_dir = '.'
save_name = 'NHP_Subject'
n_layers = 6

nighres.surface.probability_to_levelset(gm,save_data=True,output_dir=save_dir,file_name='gm_levelset')
nighres.surface.probability_to_levelset(wm,save_data=True,output_dir=save_dir,file_name='wm_levelset')

gm_ls = 'gm_levelset_p2l-surf.nii.gz'
wm_ls = 'wm_levelset_p2l-surf.nii.gz'

cont_layers = nighres.laminar.volumetric_layering(wm_ls,gm_ls,n_layers,save_data=True,output_dir=save_dir,file_name=save_name)
