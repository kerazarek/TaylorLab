#!/bin/bash

### Converting and cleaning up processed vina result pdbqts
# (c) Zarek Siegel
# v1 3/5/16
# v1.2 3/6/16

### Required input
dock=$1
# Set scripts directory to the directory containing this script
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set base directory to the one containing scripts_dir
base_dir="$( cd $scripts_dir && cd .. )"
# Source # AutoDockTools Directory and MGLTools Python binary paths from constants.py
source $scripts_dir/constants.py
# Location of pdbqt_to_pdb
q2b_py="$AutoDockTools_dir/Utilities24/pdbqt_to_pdb.py"

# Retrieve the parameters for this docking
# source $base_dir/scripts/load_parameters.sh $dock

# Relevant directories
processed_pdbqts_dir=$base_dir/$prot/$dock/processed_pdbqts
cleanedup_processed_pdbqts_dir=$base_dir/$prot/$dock/cleanedup_processed_pdbqts
processed_pdbs_dir=$base_dir/$prot/$dock/processed_pdbs

# Check if already done
if [ -d $processed_pdbs_dir ]; then
	echo "	! Results already cleaned up (processed_pdbs exists), exiting this step"
	exit 1
fi

# Create a directory for cleaned up files and pdb converts
mkdir $cleanedup_processed_pdbqts_dir
mkdir $processed_pdbs_dir

# Retrieve ligset list
ligset_list_txt=$base_dir/ligsets/$ligset/$ligset\_list.txt
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# The clean-up step
for lig in $ligset_list; do
	for ((m=1;m<=$n_models;m++)); do
		processed_pdbqt=$processed_pdbqts_dir/$dock\_$lig\_m$m.pdbqt
		cleanedup_processed_pdbqt=$cleanedup_processed_pdbqts_dir/$dock\_$lig\_m$m.pdbqt
		processed_pdb=$processed_pdbs_dir/$dock\_$lig\_m$m.pdb

		# The clean-up step
		cat $processed_pdbqt | \
			sed 's/^\(HETATM...........\)...../\1LIG L/g' \
			> $cleanedup_processed_pdbqt

		# The PDBQT > PDB Conversion step
		$AutoDockTools_pythonsh_binary $q2b_py -f $cleanedup_processed_pdbqt \
											   -o $processed_pdb \
											   1 > /dev/null

		echo "---> processed ligand $lig model $m"
	done
done

# Overwrite pre-clean-up pvr'd pdbqts with cleaned up ones
rm -rf $processed_pdbqts_dir
mv $cleanedup_processed_pdbqts_dir $processed_pdbqts_dir

