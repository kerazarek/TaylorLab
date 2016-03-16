#!/bin/bash

### process_VinaResult and a bit of organization
# (c) Zarek Siegel
# v1 3/5/16
# v1.2 3/6/16
# v2 3/6/16 (batch separation)
# v3 3/11/16

### Required input
dock=$1
# Set scripts directory to the directory containing this script
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set base directory to the one containing scripts_dir
base_dir="$( cd $scripts_dir && cd .. )"
# Source # AutoDockTools Directory and MGLTools Python binary paths from constants.py
source $scripts_dir/constants.py
# Location of process_VinaResult.py
pvr_py="$AutoDockTools_dir/Utilities24/process_VinaResult.py"

# Retrieve the parameters for this docking
source $base_dir/scripts/load_parameters.sh $dock

# Exit if already done
if [ -e $base_dir/$prot/$dock/processed_pdbqts/ ]; then
	echo "	! Results already separated"
	echo "		($prot/$dock/processed_pdbqts/ exists),"
	echo "	-> exiting this step"
	exit 1
fi

# Retrieve ligset list
ligset_list_txt=$base_dir/ligsets/$ligset/$ligset\_list.txt
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Relevant directories
result_pdbqts_dir=$base_dir/$prot/$dock/result_pdbqts
processed_pdbqts_dir=$base_dir/$prot/$dock/processed_pdbqts

# Create a directory for processed files
mkdir $processed_pdbqts_dir

# The actual process_VinaResult step
receptor_pdbqt=$base_dir/$prot/$prot_file.pdbqt
batch_size=20
# No batches
n_models=$(echo $n_models | sed 's/[^0-9]//')
if [[ "n_models" -le "$batch_size" ]]; then
	for lig in $ligset_list; do
		result_pdbqt=$result_pdbqts_dir/$dock\_$lig\_results.pdbqt
		processed_pdbqt_stem=$processed_pdbqts_dir/$dock\_$lig\_m
		$AutoDockTools_pythonsh_binary $pvr_py -r $receptor_pdbqt \
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
			result_pdbqt=$result_pdbqts_dir/$dock\.$b\_$lig\_results.pdbqt
			processed_pdbqt_stem=$processed_pdbqts_dir/$dock\.$b\_$lig\_m
			$AutoDockTools_pythonsh_binary $pvr_py -r $receptor_pdbqt \
												   -f $result_pdbqt \
												   -o $processed_pdbqt_stem
			# Rename the processed pdbqts
			for ((m=1;m<=$batch_size;m++)); do
				old_processed_pdbqt=$processed_pdbqts_dir/$dock\.$b\_$lig\_m$m.pdbqt
				new_m=$(bc <<< "(( $b - 1 ) * $batch_size ) + $m")
				new_processed_pdbqt=$processed_pdbqts_dir/$dock\_$lig\_m$new_m.pdbqt
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