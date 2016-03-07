#!/bin/bash

### process_VinaResult and a bit of organization
# (c) Zarek Siegel
# v1 3/5/16
# v1.2 3/6/16
# v2 3/6/16 (batch separation)

### Required input
dock=$1
# base_dir="/Users/zarek/GitHub/TaylorLab/zvina/"
base_dir=$2
# AutoDockTools Directory
ADT_dir=$3
# MGLTools Python binary
MGL_py_bin=$4

# Location of process_VinaResult
pvr_py="$ADT_dir/Utilities24/process_VinaResult.py"

# Retrieve docking parameters
source $base_dir\scripts/load_parameters.sh $dock $base_dir

# Exit if already done
if [ -d $base_dir$prot/$dock/processed_pdbqts/ ]; then
	echo "	! Results already separated (processed_pdbqts exists), exiting this step"
	exit 1
fi

# Retrieve ligset list
ligset_list_txt=$base_dir\ligsets/$ligset/$ligset\_list.txt
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Relevant directories
result_pdbqts_dir=$base_dir$prot/$dock/result_pdbqts/
processed_pdbqts_dir=$base_dir$prot/$dock/processed_pdbqts/

# Create a directory for processed files
mkdir $processed_pdbqts_dir

# The actual process_VinaResult step
receptor_pdbqt=$base_dir$prot/$prot.pdbqt
batch_size=20
# No batches
n_models=$(echo $n_models | sed 's/[^0-9]//')
if [[ "n_models" -le "$batch_size" ]]; then
	for lig in $ligset_list; do
		result_pdbqt=$result_pdbqts_dir$dock\_$lig\_results.pdbqt
		processed_pdbqt_stem=$processed_pdbqts_dir$dock\_$lig\_m
		$MGL_py_bin $pvr_py -r $receptor_pdbqt \
							-f $result_pdbqt \
							-o $processed_pdbqt_stem
		echo "	processed ligand $lig"
	done
# Batches
elif [[ "n_models" -gt "$batch_size" ]]; then
	n_batches=$(bc <<< "$n_models / $batch_size")
	for ((b=1;b<=$n_batches;b++)); do
		echo "	processing batch $b"
		for lig in $ligset_list; do
			result_pdbqt=$result_pdbqts_dir$dock\_$lig\_results_b$b.pdbqt
			processed_pdbqt_stem=$processed_pdbqts_dir$dock\_$lig\_b$b\_m
			$MGL_py_bin $pvr_py -r $receptor_pdbqt \
								-f $result_pdbqt \
								-o $processed_pdbqt_stem
			# Rename the processed pdbqts
			for ((m=1;m<=$batch_size;m++)); do
				old_processed_pdbqt=$processed_pdbqts_dir$dock\_$lig\_b$b\_m$m.pdbqt
				new_m=$(bc <<< "(( $b - 1 ) * $batch_size ) + $m")
				new_processed_pdbqt=$processed_pdbqts_dir$dock\_$lig\_m$new_m.pdbqt
				mv $old_processed_pdbqt $new_processed_pdbqt
			done
			echo "		processed ligand $lig"
		done
	done
else
	echo "! ! ! Error in batch processing (n_models is weird)"
fi

# *** check for results, prot.pdb, params
# *** check if already pvr'd