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

/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \
--receptor PROTEIN.pdbqt \
--ligand LIGAND.pdbqt \
--out OUT_FILE.pdbqt \
--center_x 43.5 \
--center_y 8 \
--center_z -0.5 \
--size_x 60 \
--size_y 60 \
--size_z 60 \
--cpu 2 \
--num_modes 20 \
--exhaustiveness 8

# Zarek Siegel 2-8-15