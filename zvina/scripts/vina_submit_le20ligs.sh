#BSUB -q hp12
#BSUB -n 2
#BSUB -J JOB_NAME

### This will dock one ligand
#   Put this file in your home directory (/home/jdoe)
#	All other files (receptor, ligand, and out) are relative to that directory
#	num_modes must be 20 or less
#	size_x/y/z must be 126 or less
#	If you change cpu (# of cpu cores), you must also change it above in #BSUB -n 2
#	exhaustiveness is between 8 and 100, the bigger the number the longer it will run
#	ligands must be in a folder (you specify)

# Base directory
base_dir=/home/JDOE/ # don't leave off final /
# Text file with list of ligands (one on each line)
ligset_list_txt=LIGSET_LIST_TXT
# Input directory
in_dir=IN_DIR
# Output directory
out_dir=OUT_DIR

# Generate the list of ligands
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Vina command
for lig in $ligset_list; do
	/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \
	--receptor PROT.pdbqt \
	--ligand $in_dir/$lig.pdbqt \
	--out $out_dir/$lig\_results.pdbqt \
	--center_x XXX \
	--center_y XXX \
	--center_z XXX \
	--size_x XXX \
	--size_y XXX \
	--size_z XXX \
	--cpu XXX \
	--num_modes XXX \
	--exhaustiveness XXX
done

echo "---> Finished docking $ligset_list"

# Zarek Siegel 3/6/16