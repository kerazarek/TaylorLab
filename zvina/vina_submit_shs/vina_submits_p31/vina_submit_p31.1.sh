#BSUB -q hp12
#BSUB -n 2
#BSUB -J vina_p31.1

# Text file with list of ligands (one on each line)
ligset_list_txt=/home/zsiegel/ligsets/pls1a/pls1a_list.txt

# Create the docking and output directories
mkdir /home/zsiegel/p300/p31.1/
mkdir /home/zsiegel/p300/p31.1/result_pdbqts

# Generate the list of ligands
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Vina command
for lig in $ligset_list; do
	/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \
	--receptor /home/zsiegel/p300/p300.pdbqt \
	--ligand /home/zsiegel/ligsets/pls1a/pdbqts/$lig.pdbqt \
	--out /home/zsiegel/p300/p31.1/result_pdbqts/p31.1_$lig\_results.pdbqt \
	--center_x -8.38 \
	--center_y 25.49 \
	--center_z 1.43 \
	--size_x 126 \
	--size_y 126 \
	--size_z 126 \
	--cpu 2 \
	--num_modes 400 \
	--exhaustiveness 50
done