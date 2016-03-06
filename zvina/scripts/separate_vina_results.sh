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

# Import docking parameters
source $base_dir/scripts/load_parameters.sh h11
# base_dir="/Users/zarek/GitHub/TaylorLab/zvina/"

# Create a directory for processed files
mkdir $base_dir/$prot/processed_pdbqts/