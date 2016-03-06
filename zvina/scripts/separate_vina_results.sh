#!/bin/bash

### process_VinaResult and a bit organization
# (c) Zarek Siegel
# v1 3/5/16

### Required input
dock=$1
base_dir="/Users/zarek/GitHub/TaylorLab/zvina/"
# AutoDockTools Directory
ADT_dir="/Library/MGLTools/latest/MGLToolsPckgs/AutoDockTools/"
# MGLTools Python binary
MGL_py_bin="/Library/MGLTools/latest/bin/pythonsh"

# Location of process_VinaResult
pvr_py="$ADT_dir/Utilities24/process_VinaResult.py"

# Retrieve docking parameters
source $base_dir\scripts/load_parameters.sh h11

# Retrieve ligset list
ligset_list_txt=$base_dir\ligsets/$ligset/$ligset\_list.txt
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Create a directory for processed files
mkdir $base_dir$prot/$dock/processed_pdbqts/

# Relevant directories
result_pdbqts_dir=$base_dir$prot/$dock/result_pdbqts/
processed_pdbqts_dir=$base_dir$prot/$dock/processed_pdbqts/

# The actual process_VinaResult step
receptor_pdbqt=$base_dir$prot/$prot.pdbqt
for lig in $ligset_list;
do
	result_pdbqt=$result_pdbqts_dir$dock\_$lig\_results.pdbqt
	processed_pdbqt_stem=$processed_pdbqts_dir$dock\_$lig\_m
	$MGL_py_bin $pvr_py -v -r $receptor_pdbqt \
						   -f $result_pdbqt \
						   -o $processed_pdbqt_stem
done

# *** check for results, prot.pdb, params
# *** check if already pvr'd