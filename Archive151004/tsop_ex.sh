#!/bin/bash

tsop_time=$(date "+%y%m%d%H%M")
start_time=$(date "+%y%m%d%H%M%S")

DOCK=$1

function get_info {
	PROT_LETTER=$( echo $DOCK | sed -E 's/(.)(.+)/\1/' )

	if test $PROT_LETTER == "p"; then
		PROT="p300"
	elif test $PROT_LETTER == "h"; then
		PROT="hepi"
	# elif test $PROT_LETTER == "c"; then
	# 	PROT="cbp"
	else
		echo "bad dock id"
		exit
	fi

	d=$DOCK
	p=$PROT


	#base path
	lab="/Users/zarek/lab"
	docking="$lab/Docking"
	scriptz="$lab/scriptz"
	b="$docking/$PROT/$DOCK"

	source $b/params.txt
}


get_info

log=$b/$d\_tsop_log_$tsop_time.txtw
echo "# $log" > $log
echo "" >> $log
open $log

echo "### tsop log for docking $d" >> $log
echo "started $start_time" >> $log
echo "" >> $log

open $log

echo "output from tsop.sh" >> $log
echo "" >> $log


###
###
###
source $scriptz/tsop.sh $d >> $log
# source $scriptz/tsop_justsource.sh $d >> $log
###
###
###


echo ""
echo " /END tsop.sh execution" >> $log
echo "" >> $log


end_tsop_time=$(date "+%y%m%d%H%M%S")
echo "tsop.sh ended $end_tsop_time" >> $log
tsop_calc_time=$(bc <<< $end_tsop_time-$start_time)
echo "tsop.sh took $tsop_calc_time sec" >> $log
echo "" >> $log

# keys=$( echo $__keys | sed -E 's/__//g' )
# 
# dollarsign_keys=$( echo $__keys | sed -E 's/__/$/g' )
# eval_values="echo $dollarsign_keys"


function get_keys {
	res_data_txt=$b/res_data/$d\_*_m*.txt
	source $res_data_txt	

	keys_list=$(cat $res_data_txt | grep -E '^(.+)=(.+)' | sed -E 's/^([A-Za-z0-9_]+)=(.+)/\1/')	
	__keys=$(for k in $keys_list; do echo -n "__$k,"; done | sed -E 's/(.+),$/\1/')
	keys=$( echo $__keys | sed -E 's/__//g' )
	
	echo $keys
}

function append_one {
	res_data_txt=$b/res_data/$d\_$l\_m$m.txt
	source $res_data_txt

	keys_list=$(cat $res_data_txt | grep -E '^(.+)=(.+)' | sed -E 's/^([A-Za-z0-9_]+)=(.+)/\1/')	
	__keys=$(for k in $keys_list; do echo -n "__$k,"; done | sed -E 's/(.+),$/\1/')
	
	dollarsign_keys=$( echo $__keys | sed -E 's/__/$/g' )
	eval_values="echo $dollarsign_keys"
	values=$(eval $eval_values)
	echo $values
# 	echo $eval_values
}


function append_all {
	echo ">>makin tha big ol csv"
	echo ">>>appending keys"
	get_keys > $dock_data_csv
	for l in $LSLIST; do
		echo -n ">>>>>appending $l model "
		for m in {1..9}; do
			echo -n "$m "
			append_one >> $dock_data_csv
		done
		echo ""
	done
}



dock_data_csv=$b/$d\_data.csv
append_all >> $log


end_end_time=$(date "+%y%m%d%H%M%S")


echo "DONNNEEEEEEE" >> $log
echo "totally ended $end_end_time" >> $log


echo "GOOOOOO TEEEEEAAAAMMM!!!!"
# echo "finished docking $d"




open $log
open $b
open $dock_data_csv
