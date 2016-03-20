
function execute_old {

	echo ">>checking files"
# 	check_stuff

	ls_len
	LSCOUNT=0

# 	if [ ! -d $docking/ligsets/$LIGSET/props ]; then
# 		mkdir $docking/ligsets/$LIGSET/props
# 	fi

	LIGSET_LIST="as ap" ###############################

	for l in $LIGSET_LIST; do
		((LSCOUNT++))

		echo -n ">>>ligand $l ($LSCOUNT/$LSLEN):"
# 		echo "" ###############################

		log_txt=$b/logs/$d\_$l\_log.txt
		res_pdbqt=$b/results/$d\_$l\_results.pdbqt
		log_csv=$b/log_csvs/$d\_$l\_log.csv

		if [ ! -f $res_pdbqt ]; then
			echo ""
			echo ">>>>>!!! ligand res_pdbqt does not exist !!!"
		else
# 			if [ ! -f $docking/ligsets/$LIGSET/props/$l.txt ]; then
# 				lig_props > $docking/ligsets/$LIGSET/props/$l.txt
# 			fi
# 			cat $docking/ligsets/$LIGSET/props/$l.txt > $b/lig_props.tmp
			echo -n " [lig_propsded]"

	# 		log_txt_extract ###############################
	# 		echo -n " [log_txt_extracted]" ###############################

			echo -n " [pvring....."
# 			pvr_the_thing
			echo "pvrd]"

			for m in {1..9}; do # !!
				echo -n ">>>>>model $m:"
	# 			echo "" ##############################

				res_data_txt=$b/res_data/$d\_$l\_m$m.txt
				pvrd_pdbqt=$b/pvrd_pdbqts/$d\_$l\_m$m.pdbqt
				pvrd_csv=$b/pvrd_csvs/$d\_$l\_m$m.csv
				aiad_icpd_csv=$b/aiad_icpd_csvs/$d\_$l\_m$m\_aiad.csv

	# 			cat $pvrd_csv

# 				echo "" > $res_data_txt

# 				echo_params >> $res_data_txt
				echo -n " [params echoed]"

# 				cat $b/lig_props.tmp >> $res_data_txt
				echo -n " [lig_props data'd]"

	# 			log_csv_extract >> $res_data_txt ##############################
	# 			echo -n " [log_csv_extracted]" ##############################

# 				pvrd_pdbqt_extract >> $res_data_txt
				echo -n " [pvrd data'd]"

# 				pvr_to_csv
				echo -n " [pvr->csvified]"

				echo -n " [aiad+icpd gettin'..."
# 				aiad_icpd_analysis >> $res_data_txt
				echo -n "got]"

# 				bs_scorez >> $res_data_txt
				echo " [bs_scored]"

			done
		fi
	done

# 	rm -f $b/lig_props.tmp

}