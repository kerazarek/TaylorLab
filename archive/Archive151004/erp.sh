#!/bin/bash

DOCK=$1

home_dir="/Users/zarek/lab"
pytsop="$home_dir/scriptz/pytsop"

function source_params {
	params=$($pytsop/dockid_to_params.sh $1)
	eval $params
}

source_params $DOCK

vsub_dest=$home_dir/Docking/$PROT/vs$DOCK

function generate_vsub {
	outlog=dock_logs/$DOCK\_log_out.txt
	errlog=dock_logs/$DOCK\_log_err.txt
	jobname=dock_$DOCK
	SPECPROT_pdbqt=$PROT/$SPECPROT.pdbqt
	LIG_pdbqt=ligsets/$LIGSET/\$LIG.pdbqt
	res_pdbqt=$DOCK/results/$DOCK\_\$LIG\\_results.pdbqt

	echo "#BSUB -q hp12
#BSUB -n $n_CPUS
#BSUB -x
#BSUB -o $outlog
#BSUB -o $errlog
#BSUB -J $jobname

command mkdir $DOCK
command mkdir $DOCK/results

for LIG in $LIGSET_LIST
do
	/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \
	--receptor $SPECPROT_pdbqt \
	--ligand $LIG_pdbqt \
	--out $res_pdbqt \
	--center_x $BOX_center_x \
	--center_y $BOX_center_y \
	--center_z $BOX_center_z \
	--size_x $BOX_size_x \
	--size_y $BOX_size_x \
	--size_z $BOX_size_x \
	--cpu $n_CPUS \
	--num_modes $n_MODELS \
	--exhaustiveness $EXHAUST

	echo finished docking $LIG of docking $DOCK
done"
}

generate_vsub > $vsub_dest

echo "vsub script is at"
echo $vsub_dest

##################
# 	--flex #arg#
# 	--seed #arg# \
# 	--log $DOCK/logs/$DOCK\_$LIG\_log.txt \