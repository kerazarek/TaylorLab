#BSUB -q hp12
#BSUB -n 1
#BSUB -J vina_test_309

# Text file with list of ligands (one on each line)
ligset_list_txt=/home/zsiegel/ligsets/hls1/hls1_list.txt

# Create the docking and output directories
mkdir /home/zsiegel/hepi/test_309/
mkdir /home/zsiegel/hepi/test_309/result_pdbqts

# Generate the list of ligands
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Vina command
for lig in $ligset_list; do
	/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \
	--receptor /home/zsiegel/hepi/hepi.pdbqt \
	--ligand /home/zsiegel/ligsets/hls1/pdbqts/$lig.pdbqt \
	--out /home/zsiegel/hepi/test_309/result_pdbqts/$lig\_results.pdbqt \
	--center_x 41.89 \
	--center_y 2.69 \
	--center_z -1.85 \
	--size_x 60 \
	--size_y 72 \
	--size_z 88 \
	--cpu 1 \
	--num_modes 20 \
	--exhaustiveness 8
done

echo "---> Finished docking $ligset_list"