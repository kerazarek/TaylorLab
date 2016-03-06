#!/bin/bash

### Converting and cleaning up processed vina result pdbqts
# (c) Zarek Siegel
# v1 3/5/16


### Required input
dock=$1
base_dir="/Users/zarek/GitHub/TaylorLab/zvina/"
# AutoDockTools Directory
ADT_dir="/Library/MGLTools/latest/MGLToolsPckgs/AutoDockTools/"
# MGLTools Python binary
MGL_py_bin="/Library/MGLTools/latest/bin/pythonsh"

# Location of pdbqt_to_pdb
q2b_py="$ADT_dir/Utilities24/pdbqt_to_pdb.py"

# Retrieve docking parameters
source $base_dir\scripts/load_parameters.sh $dock

# Retrieve ligset list
ligset_list_txt=$base_dir\ligsets/$ligset/$ligset\_list.txt
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Create a directory for cleaned up files and pdb converts
mkdir $base_dir$prot/$dock/cleanedup_processed_pdbqts/
mkdir $base_dir$prot/$dock/processed_pdbs/

# Relevant directories
processed_pdbqts_dir=$base_dir$prot/$dock/processed_pdbqts/
cleanedup_processed_pdbqts_dir=$base_dir$prot/$dock/cleanedup_processed_pdbqts/
processed_pdbs_dir=$base_dir$prot/$dock/processed_pdbs/

# The clean-up step
for lig in $ligset_list;
do
	for ((m=1;m<=$n_models;m++))
	do
		processed_pdbqt=$processed_pdbqts_dir$dock\_$lig\_m$m.pdbqt
		cleanedup_processed_pdbqt=$cleanedup_processed_pdbqts_dir$dock\_$lig\_m$m.pdbqt
		processed_pdb=$processed_pdbs_dir$dock\_$lig\_m$m.pdb

		# The clean-up step
		cat $processed_pdbqt | \
			sed 's/^\(HETATM...........\)...../\1LIG L/g' \
			> $cleanedup_processed_pdbqt

		# The PDBQT > PDB Conversion step
		$MGL_py_bin $q2b_py -f $cleanedup_processed_pdbqt \
							-o $processed_pdb

		echo "---> processed ligand $lig model $m"

	done
done

# Overwrite pre-clean-up pvr'd pdbqts with cleaned up ones
rm -rf $processed_pdbqts_dir
mv $cleanedup_processed_pdbqts_dir $processed_pdbqts_dir