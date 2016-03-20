#!/bin/bash

dock=$1

adt="/home/apps/CENTOS6/mgltools/1.5.6/bin/pythonsh"
u24="/home/apps/CENTOS6/mgltools/1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24"
pvr="$u24/process_VinaResult.py"

function range {
	low=$1
	high=$2
	i=$low
	while test $i -le $high; do
	  	echo $i
		((i++))
	done
}
function cr { echo ""; }
function pvr_test {
	for m in {1..20}; do
		touch $1"$m".pdbqt
		touch $1\2.pdbqt
		echo $1\$m\.pdbqt
	done
}


# dock="p32	"
d=$dock

source /home/zsiegel/$d/$d\_params.txt

n_subdocks=$(bc <<< "$n_models / 20" )
ns=$(range 1 $n_subdocks)

#***
ligset_list=$ligset_list_sh

mkdir /home/zsiegel/$d/pvrd_pdbqts
mkdir /home/zsiegel/$d/logs

echo "" > /home/zsiegel/$d/logs/failed_poses.txt
echo "" > /home/zsiegel/$d/logs/pvr_out_log.txt
echo "" > /home/zsiegel/$d/logs/pvr_err_log.txt

for n in $ns; do
	echo "processing $d.$n"
	mkdir /home/zsiegel/$d/$d.$n/pvrd_pdbqts
	prot_pdbqt=/home/zsiegel/$prot/$specprot.pdbqt
	for l in $ligset_list; do
		res_pdbqt=/home/zsiegel/$d/$d.$n/results/$d.$n\_$l\_results.pdbqt
		pvrd_pdbqt_stem=/home/zsiegel/$d/$d.$n/pvrd_pdbqts/$d.$n\_$l\_m
# 		$adt $pvr -f $res_pdbqt -r $prot_pdbqt -o $pvrd_pdbqt_stem \
# 			1>>/home/zsiegel/$d/logs/pvr_out_log.txt \
# 			2>>/home/zsiegel/$d/logs/pvr_err_log.txt
		pvr_test $pvrd_pdbqt_stem $n_models \
			1>>/home/zsiegel/$d/logs/pvr_out_log.txt \
			2>>/home/zsiegel/$d/logs/pvr_err_log.txt
		echo "    processed $res_pdbqt"
	done
	cr
done

######

if test $n_models -gt 20; then
	for n in $ns; do
		for oldm in {1..20}; do
			for l in $ligset_list; do
				newm=$(bc <<< "$oldm + (($n - 1) * 20)")
				old_pvrd_pdbqt=/home/zsiegel/$d/$d.$n/pvrd_pdbqts/$d.$n\_$l\_m$oldm.pdbqt
				new_pvrd_pdbqt=/home/zsiegel/$d/pvrd_pdbqts/$d\_$l\_m$newm.pdbqt

				if [ -e $old_pvrd_pdbqt ]; then
					cp $old_pvrd_pdbqt $new_pvrd_pdbqt
					echo copied $d\_$l\_m$newm
				else
					echo $d\_$l\_m$newm.pdbqt >> /home/zsiegel/$d/logs/failed_poses.txt
					echo failed $d\_$l\_m$newm
				fi
# 				echo $new_pvrd_pdbqt
			done
		done
	done
fi

# mkdir /home/zsiegel/$d/subdocks
mkdir /home/zsiegel/misc_docking_files/subdocks/$d\_subdocks

for n in $ns; do
# 	mv /home/zsiegel/$d/$d.$n /home/zsiegel/$d/subdocks/
	mv /home/zsiegel/$d/$d.$n /home/zsiegel/misc_docking_files/subdocks/$d\_subdocks
	cp /home/zsiegel/dock_logs/$d.$n\_log_out.txt /home/zsiegel/$d/logs/$d.$n\_log_out.txt
	cp /home/zsiegel/dock_logs/$d.$n\_log_err.txt /home/zsiegel/$d/logs/$d.$n\_log_err.txt
done

failed_poses=$(cat /home/zsiegel/$d/logs/failed_poses.txt)
echo "" > /home/zsiegel/$d/logs/failed_poses.txt
for f in $failed_poses; do
	echo $f >> /home/zsiegel/$d/logs/failed_poses.txt
done
n_failed_poses=$(echo $failed_poses | wc | awk '{print $2}')
echo "" >> /home/zsiegel/$d/$d\_params.txt
echo "n_failed_poses=\"$n_failed_poses\"" >> /home/zsiegel/$d/$d\_params.txt
echo "$n_failed_poses failed poses"
