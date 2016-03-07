#!/bin/bash

### process_VinaResult and a bit of organization
# (c) Zarek Siegel
# v1 3/5/16
# v1.2 3/6/16
# v2 3/6/16 (batch separation)

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
source $base_dir\scripts/load_parameters.sh $dock

# Exit it already done
if [ -d $base_dir$prot/$dock/processed_pdbqts/ ]; then
	echo "	! Results already separated (processed_pdbqts exists), exiting this step"
	exit 1
fi

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
# No batches
if [[ $n_models -le 20 ]]; then
	for lig in $ligset_list; do
		result_pdbqt=$result_pdbqts_dir$dock\_$lig\_results.pdbqt
		processed_pdbqt_stem=$processed_pdbqts_dir$dock\_$lig\_m
		$MGL_py_bin $pvr_py -r $receptor_pdbqt \
							-f $result_pdbqt \
							-o $processed_pdbqt_stem
		echo "	processed ligand $lig"
	done
# Batches
elif [[ $n_models -gt 20 ]]; then
	for lig in $ligset_list; do

else
	print("! ! ! Error in batch processing (n_models is weird)")
fi

# *** check for results, prot.pdb, params
# *** check if already pvr'd