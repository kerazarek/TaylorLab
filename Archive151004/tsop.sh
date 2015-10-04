#!/usr/local/bin/bash

# practice for grand_post



# DOCK="p0"
DOCK=$1

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









#parameters
function generate_params {
	RScript ~/codez/docks_extract.R

	dockkey_p300=$docking/docks_csvs/docks_p300.csv
	dockkey_hepi=$docking/docks_csvs/docks_hepi.csv

	dockkey_pdbs=$docking/docks_csvs/docks_pdbs.csv
	dockkey_ligsets=$docking/docks_csvs/docks_ligsets.csv
	dockkey_gridboxes=$docking/docks_csvs/docks_gridboxes.csv

	if test $PROT_LETTER == "p"; then
		dockkey_prot=$dockkey_p300
	elif test $PROT_LETTER == "h"; then
		dockkey_prot=$dockkey_hepi
	fi

	SPECPROT=$( python /Users/zarek/codez/csv_to_py.py $dockkey_prot $d "SPECPROT" )
	LIGSET=$( python /Users/zarek/codez/csv_to_py.py $dockkey_prot $d "LIGSET" )
	BOX=$( python /Users/zarek/codez/csv_to_py.py $dockkey_prot $d "BOX" )
	EXHAUST=$( python /Users/zarek/codez/csv_to_py.py $dockkey_prot $d "EXHAUST" )

	echo "# parameters for docking $d"
	echo "DOCK=$DOCK"
	echo "PROT=$PROT"
	echo "SPECPROT=$SPECPROT"
	echo "LIGSET=$LIGSET"
	echo "BOX=$BOX"
	echo "EXHAUST=$EXHAUST"
	echo ""
}


function get_params {
	if [ -f $b/params.txt ]; then
		source $b/params.txt
	else
		generate_params > $b/params.txt
	fi

	LSLIST=$(cat $docking/ligsets/$LIGSET/$LIGSET.txt)
	BOXTEXT=$(cat $docking/gridboxes/$BOX.txt)

	s=$SPECPROT
	specprot_pdbqt="$docking/$PROT/$SPECPROT.pdbqt"
}



# get_params > $b/params.txt
# source $b/params.txt
# open $b/params.txt
















#check stuff
function check_stuff {
	for dir in pvrd_pdbqts pvrd_csvs res_data aiad_icpd_csvs # log_csvs
	do
		if [ ! -d $b/$dir ]; then
			mkdir $b/$dir
		fi
	done

	if [ ! -d $b/results ]; then
		echo "results directory does not exist"
	fi
	for l in $LSLIST; do
		if [ !  -f $b/results/$d\_$l\_results.pdbqt ]; then
			echo "no $l res.pdbqt in results dir (or it's improperly named)"
		fi
	done

# 	if [ ! -d $b/logs ]; then
# 		echo "logs directory does not exist"
# 	fi
# 	for l in $LSLIST; do
# 		if [ ! -f $b/logs/$d\_$l\_log.txt ]; then
# 			echo "no $l log.txt in logs dir (or it's improperly named)"
# 		fi
# 	done
}


#NOT USING THIS
#lig propzz!!!!
function lig_props {
	lig_mol=$docking/ligsets/$LIGSET/mols/$l.mol

	obprop $lig_mol |
	tr -s ' ' ',' > $b/props.tmp
# 	cat $b/props.tmp

	lig_form=$( cat $b/props.tmp | grep -E '^formula' | sed -E 's/.+,(.+)/\1/' )
	lig_mw=$( cat $b/props.tmp | grep -E '^mol_weight' | sed -E 's/.+,(.+)/\1/' )
	lig_smiles=$( cat $b/props.tmp | grep -E '^canonical_SMILES' | sed -E 's/.+,(.+)(	)(.+)/\1/' )
	lig_n_atoms=$( cat $b/props.tmp | grep -E '^num_atoms' | sed -E 's/.+,(.+)/\1/' )
	lig_n_bonds=$( cat $b/props.tmp | grep -E '^num_bonds' | sed -E 's/.+,(.+)/\1/' )
	lig_n_rings=$( cat $b/props.tmp | grep -E '^num_rings' | sed -E 's/.+,(.+)/\1/' )
	lig_logp=$( cat $b/props.tmp | grep -E '^logP' | sed -E 's/.+,(.+)/\1/' )
	lig_psa=$( cat $b/props.tmp | grep -E '^PSA' | sed -E 's/.+,(.+)/\1/' )
	lig_mr=$( cat $b/props.tmp | grep -E '^MR' | sed -E 's/.+,(.+)/\1/' )

	echo "# lig_props"
	echo "lig_form=$lig_form"
	echo "lig_mw=$lig_mw"
	echo lig_smiles=\"$lig_smiles\"
	echo "lig_n_atoms=$lig_n_atoms"
	echo "lig_n_bonds=$lig_n_bonds"
	echo "lig_n_rings=$lig_n_rings"
	echo "lig_logp=$lig_logp"
	echo "lig_psa=$lig_psa"
	echo "lig_mr=$lig_mr"
	echo ""

	rm -f $b/props.tmp
}



#log_txt -> log_csv
function log_txt_extract {
	echo "model,E,rmsd_lb,rmsd_ub" > $log_csv
	cat $log_txt |
	grep -E '^...[1234567890] +' |
	tr -s ' ' ',' |
	sed -E 's/,(.+),(.+),(.+),(.+)/\1,\2,\3,\4/' >> $log_csv
}



#params into res_data.txts
function echo_params {
	echo "# dock_params"
	echo KEY=$d\_$l\_m$m
	echo "DOCK=$d"
	echo "PROT=$p"
	echo "SPECPROT=$s"
	echo "LIG=$l"
	echo "LIGSET=$LIGSET"
	echo "BOX=$BOX"
	echo "EXHAUST=$EXHAUST"
	echo "MODEL=$m"
# 	echo 'd=$DOCK'
# 	echo 'p=$PROT'
# 	echo 's=$SPECTPROT'
# 	echo 'l=$LIG'
# 	echo 'm=$MODEL'
# 	echo 'b=$BASE_PATH'
	echo ""
	echo "# file_paths"
	echo "BASE_PATH=$b"
	echo "log_txt=$log_txt"
	echo "log_csv=$log_csv"
	echo "res_pdbqt=$res_pdbqt"
	echo "pvrd_pdbqt=$pvrd_pdbqt"
	echo "specprot_pdbqt=$specprot_pdbqt"
	echo "res_data_txt=$res_data_txt"
	echo ""
}





### (NOT ACTUALLY NEEDED)
#extract into res_data.txts
function log_csv_extract {
	cat $log_csv |
	grep -E $m,.+,.+,.+ > $b/modgrep.tmp
	cat $b/modgrep.tmp | sed -E 's/'${m}',(.+),(.+),(.+)/\1/' > $b/E.tmp
	cat $b/modgrep.tmp | sed -E 's/'${m}',(.+),(.+),(.+)/\2/' > $b/rmsd_lb.tmp
	cat $b/modgrep.tmp | sed -E 's/'${m}',(.+),(.+),(.+)/\3/' > $b/rmsd_ub.tmp
	E=$(cat $b/E.tmp)
	rmsd_lb=$(cat $b/rmsd_lb.tmp)
	rmsd_ub=$(cat $b/rmsd_ub.tmp)
	rm -f $b/modgrep.tmp $b/E.tmp $b/rmsd_lb.tmp $b/rmsd_ub.tmp
	echo "# vina_out"
	echo "E=$E"
	echo "rmsd_lb=$rmsd_lb"
	echo "rmsd_ub=$rmsd_ub"
	echo ""
}



#pvr
function pvr_the_thing {
	pvrd_name=$b/pvrd_pdbqts/$d\_$l\_m

	/Library/MGLTools/latest/bin/pythonsh \
	/Library/MGLTools/latest/MGLToolsPckgs/AutoDockTools/Utilities24/process_VinaResult.py \
	-f $res_pdbqt \
	-r $specprot_pdbqt \
	-o $pvrd_name
}



#csvification of pvrs
function pvrd_pdbqt_extract {
	model=$(grep "MODELS" $pvrd_pdbqt | sed -E 's/USER  AD>  (.+) of (.+) MODELS/\1/')
	E=$(grep -E 'USER  AD> (.+), (.+), (.+)' $pvrd_pdbqt | sed -E 's/(USER  AD>)( +)(.+)(, +)(.+)(, +)(.+)/\3/')
	rmsd_lb=$(grep -E 'USER  AD> (.+), (.+), (.+)' $pvrd_pdbqt | sed -E 's/(USER  AD>)( +)(.+)(, +)(.+)(, +)(.+)/\5/')
	rmsd_ub=$(grep -E 'USER  AD> (.+), (.+), (.+)' $pvrd_pdbqt | sed -E 's/(USER  AD>)( +)(.+)(, +)(.+)(, +)(.+)/\7/')

	pvr_effic=$(grep "ligand efficiency" $pvrd_pdbqt | sed -E 's/USER  AD>  ligand efficiency  (.+)/\1/')
	pvr_n_contacts=$(grep "macro_close_ats" $pvrd_pdbqt | sed -E 's/USER  AD> macro_close_ats: (.+)/\1/')
	pvr_resis=$(cat $pvrd_pdbqt | grep -E 'USER  AD> (.+):(\S+):(\S+):([^,]+)$' | sed -E 's/USER  AD> (.+):(.+):(.+):(.+)/\3/' | sort -u)
	pvr_resis_atoms=$(cat $pvrd_pdbqt | grep -E 'USER  AD> (.+):(\S+):(\S+):([A-Za-z0-9]+)$' | sed -E 's/USER  AD> (.+):(.+):(.+):([A-Za-z0-9]+)$/\3_\4/' | sort -u)

# 	pvr_resis_list=\"$pvr_resis\"
# 	pvr_resis_atoms_list=\"$pvr_resis_atoms\"

	echo "# pvr_data"
	echo "E=$E"
	echo "rmsd_lb=$rmsd_lb"
	echo "rmsd_ub=$rmsd_ub"
	echo "pvr_effic=$pvr_effic"
	echo "pvr_n_contacts=$pvr_n_contacts"
	echo pvr_resis=\"$pvr_resis\"
	echo pvr_resis_atoms=\"$pvr_resis_atoms\"

	echo ""

}



#csvification of pvr coords
# function pvr_to_csv {
# 	echo "num,atom,x,y,z" > $pvrd_csv
#
# 	cat $pvrd_pdbqt |
# 	grep -E 'HETATM|ATOM  ' |
# 	sed -e 's/./&,/6' \
# 		-e 's/./&,/12' \
# 		-e 's/./&,/19' \
# 		-e 's/./&,/33' \
# 		-e 's/./&,/42' \
# 		-e 's/./&,/51' \
# 		-e 's/./&,/60' |
# 	sed -E 's/(ATOM  |HETATM),(.+),(.+),(.+),(.+),(.+),(.+),(.+)/\2,\3,\5,\6,\7/' |
# 	tr -d ' ' >> $pvrd_csv
# }

function pvr_to_csv {
	/Users/zarek/codez/pdb_to_csv.sh $pvrd_pdbqt > $pvrd_csv
}

#binding site analysis"#26282E"
# function aiad {
# 	$scriptz/aiad_icpd.sh $pvrd_csv $site_lig_csv a"#000000"
# }"#0F1011"
#
# function icpd {
# 	$scriptz/aiad_icpd.sh $pvrd_csv $site_lig_csv i
# }"#16171A"

function aiad {
# 	option=$1 # a or i

# 	if [ ! -f $aiad_icpd_csv ]; then
# 		echo "num,atom,x,y,z" > $aiad_icpd_csv
# 		cat $pvrd_csv |
# 		grep -E 'HETATM|ATOM' |
# 		sed -E 's/^[^,]*,([^,]*),([^,]*),[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,([^,]*),([^,]*),([^,]*).+/\1,\2,\3,\4,\5/' |
# 		tr -d ' ' \
# 		>> $aiad_icpd_csv
# 	fi
#
# 	if [ ! -f $site_lig_aiad_icpd_csv ]; then
# 		echo "num,atom,x,y,z" > $site_lig_aiad_icpd_csv"#101012"
# 		cat $site_lig_csv |
# 		grep -E 'HETA"#000000"TM|ATOM' |
# 		sed -E 's/^[^,]*,([^,]*),([^,]*),[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,([^,]*),([^,]*),([^,]*).+/\1,\2,\3,\4,\5/' |
# 		tr -d ' ' \
# 		>> $site_lig_aiad_icpd_csv
# 	fi

	python $scriptz/aiad_icpd.py $aiad_icpd_csv $site_lig_aiad_icpd_csv a
}

function icpd {
	python $scriptz/aiad_icpd.py $aiad_icpd_csv $site_lig_aiad_icpd_csv i
}



function aiad_icpd_analysis {

# 	echo $bs_dir

	p300_sites="lys coa coa_adpp coa_ado coa_pant side allo1 allo2"
	h1_sites="adph fdla"
	h1c_sites="adph fdla allo"

	if test $SPECPROT = "p300"; then
		PROT_sites=$p300_sites
		s=p300
	elif test $SPECPROT = "h1"; then
		PROT_sites=$h1_sites
		s=h1
	elif test $SPECPROT = "h1a"; then
		PROT_sites=$h1_sites
		s=h1
	elif test $SPECPROT = "h1f"; then
		PROT_sites=$h1_sites
		s=h1
	elif test $SPECPROT = "h1af"; then
		PROT_sites=$h1_sites
		s=h1
	elif test $SPECPROT = "h1c"; then
		PROT_sites=$h1c_sites
		s=h1c
	elif test $SPECPROT = "h1ca"; then
		PROT_sites=$h1c_sites
		s=h1c
	elif test $SPECPROT = "h1cf"; then
		PROT_sites=$h1c_sites
		s=h1c
	elif test $SPECPROT = "h1caf"; then
		PROT_sites=$h1c_sites
		s=h1c
	else
		echo "bad specprot"
	fi

	bs_dir=$docking/binding_sites/$s

	echo "# aiad_icpd_analysis"
	for site in $PROT_sites; do

# 		echo $site
		site_lig_pdb=$bs_dir/lig_pdbs/$s\_bs_$site.pdb
		site_lig_csv=$bs_dir/lig_csvs/$s\_bs_$site.csv
		site_lig_aiad_icpd_csv=$bs_dir/lig_csvs/$s\_bs_$site\_aiad_icpd.csv

		if [ ! -f $aiad_icpd_csv ]; then
			echo "num,atom,x,y,z" > $aiad_icpd_csv
			cat $pvrd_csv |
			grep -E 'HETATM|ATOM' |
			sed -E 's/^[^,]*,([^,]*),([^,]*),[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,([^,]*),([^,]*),([^,]*).+/\1,\2,\3,\4,\5/' |
			tr -d ' ' \
# 			>> $aiad_icpd_csv
		fi

		if [ ! -f $site_lig_aiad_icpd_csv ]; then
			echo "num,atom,x,y,z" > $site_lig_aiad_icpd_csv
			cat $site_lig_csv |
			grep -E 'HETATM|ATOM' |
			sed -E 's/^[^,]*,([^,]*),([^,]*),[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,([^,]*),([^,]*),([^,]*).+/\1,\2,\3,\4,\5/' |
			tr -d ' ' \
			>> $site_lig_aiad_icpd_csv
		fi

		bs_aiad=$( aiad )
		bs_icpd=$( icpd )

		eval_aiad_assign='aiad_'$site'=$( aiad )'
		eval $eval_aiad_assign

		eval_icpd_assign='icpd_'$site'=$( icpd )'
		eval $eval_icpd_assign

		echo "aiad_$site=$bs_aiad"
		echo "icpd_$site=$bs_icpd"
# 		echo "aiad is $bs_aiad, icpd is $bs_icpd"
	done
	echo ""

	s=$SPECPROT

# 	p300_sites="lys coa coa_adpp coa_ado coa_pant side allo1 allo2"
#
# 	declare -A sites_p300_aiads
# 	sites_p300_aiads=(
# 		["lys"]=$aiad_lys \
# 		["coa"]=$aiad_coa \
# 		["coa_adpp"]=$aiad_coa_adpp \
# 		["coa_ado"]=$aiad_coa_ado \
# 		["coa_pant"]=$aiad_coa_pant \
# 		["allo1"]=$aiad_coa_allo1 \
# 		["allo2"]=$aiad_coa_allo2 \
# 		["side"]=$aiad_coa_side
# 		)

# 	echo sites_p300_aiads["lys"]
}



function bs_scorez {
	$scriptz/bs_scorez.sh $d $p $l $m
}



function ls_len {
	i=0
	for x in $LSLIST; do
		((i++))
	done
	LSLEN=$i
}





#execuuuttttteee!!
function execute {

# 	echo "
# 	~~~~~~~~~~commence~~~excecute~~~~~~~~~~
# 	"

	echo ">performing post- on docking $d"

	echo ">>getting parameters"
	get_params

	echo ">>checking files"
	check_stuff

	ls_len
	LSCOUNT=0

	if [ ! -d $docking/ligsets/$LIGSET/props ]; then
		mkdir $docking/ligsets/$LIGSET/props
	fi

	for l in $LSLIST; do
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
			if [ ! -f $docking/ligsets/$LIGSET/props/$l.txt ]; then
				lig_props > $docking/ligsets/$LIGSET/props/$l.txt
			fi
			cat $docking/ligsets/$LIGSET/props/$l.txt > $b/lig_props.tmp
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

				echo "" > $res_data_txt

				echo_params >> $res_data_txt
				echo -n " [params echoed]"

				cat $b/lig_props.tmp >> $res_data_txt
				echo -n " [lig_props data'd]"

	# 			log_csv_extract >> $res_data_txt ##############################
	# 			echo -n " [log_csv_extracted]" ##############################

				pvrd_pdbqt_extract >> $res_data_txt
				echo -n " [pvrd data'd]"

				pvr_to_csv
				echo -n " [pvr->csvified]"

				echo -n " [aiad+icpd gettin'..."
				aiad_icpd_analysis >> $res_data_txt
				echo -n "got]"

				bs_scorez >> $res_data_txt
				echo " [bs_scored]"

			done
		fi
	done

	rm -f $b/lig_props.tmp

# 	echo "
# 	~~~~~~~~~~terminate~~~excecute~~~~~~~~~~
# 	"
}














# keys=$( echo $__keys | sed -E 's/__//g' )
#
# dollarsign_keys=$( echo $__keys | sed -E 's/__/$/g' )
# eval_values="echo $dollarsign_keys"
#
#
#
#
#
# # LSLIST="s1 s2 s4"
#
#
# function get_keys {
# 	res_data_txt=$b/res_data/$d\_*_m*.txt
# 	source $res_data_txt
#
# 	keys_list=$(cat $res_data_txt | grep -E '^(.+)=(.+)' | sed -E 's/^([A-Za-z0-9_]+)=(.+)/\1/')
# 	__keys=$(for k in $keys_list; do echo -n "__$k,"; done | sed -E 's/(.+),$/\1/')
# 	keys=$( echo $__keys | sed -E 's/__//g' )
#
# 	echo $keys
# }
#
# function append_one {
# 	res_data_txt=$b/res_data/$d\_$l\_m$m.txt
# 	source $res_data_txt
#
# 	keys_list=$(cat $res_data_txt | grep -E '^(.+)=(.+)' | sed -E 's/^([A-Za-z0-9_]+)=(.+)/\1/')
# 	__keys=$(for k in $keys_list; do echo -n "__$k,"; done | sed -E 's/(.+),$/\1/')
#
# 	dollarsign_keys=$( echo $__keys | sed -E 's/__/$/g' )
# 	eval_values="echo $dollarsign_keys"
# 	eval $eval_values
# 	echo -n $values
# # 	echo $eval_values
# }
#
#
# function append_all {
# 	echo ">>makin tha big ol csv"
# 	get_keys > $dock_data_csv
# 	for l in $LSLIST; do
# 		for m in {1..9}; do
# 			echo ">>>appending $l model $m"
# 			append_one >> $dock_data_csv
# 		done
# 	done
# }















# get_params





#DOOOOOIT
execute



#MAKEA THA CSV WITH ALL THE STUFF
# dock_data_csv=$b/$d\_data.csv
# append_all
#
# # open $dock_data_csv
#
#
#
#
# echo "GOOOOOO TEEEEEAAAAMMM!!!!"

