#BSUB -q hp12
#BSUB -n 1
#BSUB -N
#BSUB -o /home/YOU/OUTPUT_LOG.txt
#BSUB -J JOB_NAME

### This will dock one ligand
#   Put this file in your home directory (/home/jdoe)
#	All other files (receptor, ligand, and out) are relative to that directory
#	num_modes must be 20 or less (number of poses generated)
#	size_x/y/z must be 126 or less
#	exhaustiveness is between 8 and 100, the bigger the number the longer it will run

# In BSUBs, change the output log (-o) and job name (-J)
#		Dont change anything else

# Below, don't change first line
# 	Change everything but cpu

/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \
--receptor /home/YOU/PROTEIN.pdbqt \
--ligand /home/YOU/LIGAND.pdbqt \
--out /home/YOU/OUT_FILE.pdbqt \
--center_x 43.5 \
--center_y 8 \
--center_z -0.5 \
--size_x 60 \
--size_y 60 \
--size_z 60 \
--cpu 1 \
--num_modes 20 \
--exhaustiveness 8

# Zarek Siegel 3/18/16