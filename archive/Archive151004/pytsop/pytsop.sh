#!/bin/bash

home_dir="/Users/zarek/lab"
pytsop="$home_dir/scriptz/pytsop"
source $home_dir/scriptz/basic_funcs.sh


params_vars_sh=$1
source $params_vars_sh






#
# function now {
# 	date "+%y%m%s"
# }
#
#
# ###########
# function start {
# 	start_time=$(now)
# 	echo "
# 	--------------->PYTSOP<---------------
# 	----->start: $start_time
# 	"
# }
# ###########
#
#
# # echo "params gotted"
# # echo "Stuff!"
#
#
# ##########
# function end {
# 	end_time=$(now)
# 	calc_time=$(bc <<< $end_time-$start_time)
# 	echo "
# 	----->end pytsop: $end_time
# 	----->calc time: $calc_time sec
# 	--------------->/pytsop<--------------
# 	"
# }
# ##########
#

# made
res_pdbqt_dir=$b/results
# 	res_pdbqt

# make
res_pdbqt_cleaned_dir=$b/res_pdbqts_cleaned
# 	res_pdbqt_cleaned
pvrd_pdbqt_dir=$b/pvrd_pdbqts
# 	pvrd_pdbqt
pvrd_pdb_dir=$b/pvrd_pdbs
# 	pvrd_pdb
pvrd_pdbqt_csv_dir=$b/pvrd_pdbqts_csvs
# 	pvrd_pdbqt_csv
data_zsv_dir=$b/data_zsvs
# 	data_zsv
data_py_dir=$b/data_pys
# 	data_py
data_sh_dir=$b/data_shs
# 	data_sh

dirs_to_make="$res_pdbqt_cleaned_dir $pvrd_pdbqt_dir $pvrd_pdb_dir \
	$pvrd_pdbqt_csv_dir $data_zsv_dir $data_py_dir $data_sh_dir"

all_data_csv=$b/$d\_alldata.csv

### LOCAL FUNCTIONS
##############################
function ls_len {
	i=0
	for x in $LIGSET_LIST; do
		((i++))
	done
	LSLEN=$i
}

function mkdirifnone {
	dir=$1
	if [ -d $dir ]; then
		echo "dir $1 already exists"
		exit
	elif [ ! -d $dir ]; then
		mkdir $dir
		echo "made dir $dir"
	else
		echo "error making dir $dir"
		exit
	fi
}

function data_zsv_append {
	var=$1
	eval_echo="echo $var !FS! \$$var"
	eval $eval_echo
}
##############################






### EXTRACTION/WRITING FUNCTIONS
##############################

function generate_lig_props {
	lig_mol=$LIGSET_dir/mols/$l.mol

	obprop $lig_mol 1>$LIG_props_txt.raw 2>$LIG_props_txt.err
	cat $LIG_props_txt.raw | tr -s ' ' ',' > $LIG_props_txt.tmp
# 	props_error=$(cat $LIG_props_txt.err)
	rm -f $LIG_props_txt.raw


	lig_form=$( cat $LIG_props_txt.tmp | grep -E '^formula' | sed -E 's/.+,(.+)/\1/' )
	lig_mw=$( cat $LIG_props_txt.tmp | grep -E '^mol_weight' | sed -E 's/.+,(.+)/\1/' )
	lig_smiles=$( cat $LIG_props_txt.tmp | grep -E '^canonical_SMILES' | sed -E 's/.+,(.+)(	)(.+)/\1/' )
	lig_n_atoms=$( cat $LIG_props_txt.tmp | grep -E '^num_atoms' | sed -E 's/.+,(.+)/\1/' )
	lig_n_bonds=$( cat $LIG_props_txt.tmp | grep -E '^num_bonds' | sed -E 's/.+,(.+)/\1/' )
	lig_n_rings=$( cat $LIG_props_txt.tmp | grep -E '^num_rings' | sed -E 's/.+,(.+)/\1/' )
	lig_logp=$( cat $LIG_props_txt.tmp | grep -E '^logP' | sed -E 's/.+,(.+)/\1/' )
	lig_psa=$( cat $LIG_props_txt.tmp | grep -E '^PSA' | sed -E 's/.+,(.+)/\1/' )
	lig_mr=$( cat $LIG_props_txt.tmp | grep -E '^MR' | sed -E 's/.+,(.+)/\1/' )
	rm -f $LIG_props_txt.tmp

# 	if [ -f LIG_props_zsv ]; then rm -f $LIG_props_zsv; fi
	props_list="lig_form lig_mw lig_smiles lig_n_atoms \
			lig_n_bonds lig_n_rings lig_logp lig_psa lig_mr"
	for prop in $props_list; do data_zsv_append $prop >> $LIG_props_zsv.tmp; done
	cat $LIG_props_zsv.tmp | awk 'BEGIN{FS=" !FS! ";OFS=" !FS! "} \
 								   {if ($2 !~ /^[-]?[[:digit:]]*[\.]?[[:digit:]]*$/) \
 								   		$2="\""$2"\""} \
								   {print $1, $2}' > $LIG_props_zsv
	rm -f $LIG_props_zsv.tmp

	cat $LIG_props_zsv | awk 'BEGIN{FS=" !FS! ";OFS="="} \
								   {print $1, $2}' > $LIG_props_txt
}

function clean_up_res_pdbqt {
	cat $res_pdbqt |
	sed -e 's/^\(HETATM\)\(.\{11\}\)\(.\{9\}\)\(.\{1,\}\)/HETATM\2LIG L   1\4/' \
		-e 's/^\(ATOM  \)\(.\{11\}\)\(.\{9\}\)\(.\{1,\}\)/HETATM\2LIG L   1\4/' \
	> $res_pdbqt_cleaned
}

#****
function pvr_the_thing {
	/Library/MGLTools/latest/bin/pythonsh \
	/Library/MGLTools/latest/MGLToolsPckgs/AutoDockTools/Utilities24/process_VinaResult.py \
	-f $res_pdbqt_cleaned \
	-r $specprot_pdbqt \
	-o $pvrd_base
}

function pvrd_pdbqt_to_pdb {
	/Library/MGLTools/latest/bin/pythonsh \
	/Library/MGLTools/latest/MGLToolsPckgs/AutoDockTools/Utilities24/pdbqt_to_pdb.py \
	-f $pvrd_pdbqt \
	-o $pvrd_pdb
}

function pvrd_pdbqt_to_csv {
	$pytsop/pdbqt_to_csv.sh $pvrd_pdbqt > $pvrd_pdbqt_csv
}

function append_params {
	params_to_append="DOCK DATE PROT SPECPROT LIG LIGSET BOX EXHAUST n_MODELS n_CPUS DOCK_ENERGY_RANGE MODEL"
	MODEL=$m

	for param in $params_to_append; do data_zsv_append $param; done

}

function pvrd_pdbqt_extract {
	E=$(
		grep -E 'USER  AD> (.+), (.+), (.+)' $pvrd_pdbqt |
		sed 's/USER  AD> \{1,\}\(.\{1,\}\), \{1,\}\(.\{1,\}\), \{1,\}\(.\{1,\}\)/\1/'
	)
	rmsd_lb=$(
		grep -E 'USER  AD> (.+), (.+), (.+)' $pvrd_pdbqt |
		sed 's/USER  AD> \{1,\}\(.\{1,\}\), \{1,\}\(.\{1,\}\), \{1,\}\(.\{1,\}\)/\2/'
	)
	rmsd_ub=$(
		grep -E 'USER  AD> (.+), (.+), (.+)' $pvrd_pdbqt |
		sed 's/USER  AD> \{1,\}\(.\{1,\}\), \{1,\}\(.\{1,\}\), \{1,\}\(.\{1,\}\)/\3/'
	)
	pvr_effic=$(
		grep "ligand efficiency" $pvrd_pdbqt |
		sed 's/USER  AD> \{1,\}ligand efficiency \{1,\}\(.\{1,\}\)/\1/'
	)
	pvr_n_contacts=$(
		grep "macro_close_ats" $pvrd_pdbqt |
		sed 's/USER  AD> \{1,\}macro_close_ats: \{1,\}\(.\{1,\}\)/\1/'
	)
	pvr_resis=$(
		grep -E 'USER  AD> (.+):(\S+):(\S+):([^,]+)$' $pvrd_pdbqt |
		sed 's/USER  AD> \(.\{1,\}\):\(.\{1,\}\):\(.\{1,\}\):\(.\{1,\}\)/\3/' |
		sort -u
	)
	pvr_resis=$(echo \"$pvr_resis\")
	pvr_resis_atoms=$(
		grep -E 'USER  AD> (.+):(\S+):(\S+):([A-Za-z0-9]+)$' $pvrd_pdbqt |
		sed 's/USER  AD> \(.\{1,\}\):\(.\{1,\}\):\(.\{1,\}\):\(.\{1,\}\)/\3_\4/' |
		sort -u
	)
	pvr_resis_py=$(
		echo $pvr_resis |
		sed 's/^\"\(.*\)\"$/\[\"\1\"\]/' |
		sed 's/ /\", \"/g'
	)
	pvr_resis_atoms=$(echo \"$pvr_resis_atoms\")
	pvr_resis_atoms_py=$(
		echo $pvr_resis_atoms |
		sed 's/^\"\(.*\)\"$/\[\"\1\"\]/' |
		sed 's/ /\", \"/g'
	)
	torsdof=$(
		grep 'TORSDOF' $pvrd_pdbqt |
		sed 's/^\(TORSDOF \)\([0-9]\{1,\}\)/\2/'
	)

	pvr_out_vars="E rmsd_lb rmsd_ub pvr_effic pvr_n_contacts torsdof \
				pvr_resis pvr_resis_py pvr_resis_atoms pvr_resis_atoms_py"

	for var in $pvr_out_vars; do data_zsv_append $var; done
}

function data_zsv_to_py {
	cat $data_zsv |
	awk 'BEGIN{FS=" !FS! ";OFS=" = "} \
			{if ($2 !~ /^[-]?[[:digit:]]*[\.]?[[:digit:]]*$/ && \
				 $2 !~ /^\".*\"$/ && \
				 $2 !~ /^\[.*\]$/ ) \
				$2="\""$2"\""} \
			{print $1, $2}'

# 		{if ($1 !~ /^pvr_resis$/ && $1 !~ /^pvr_resis_atoms$/ ) \
# 				print $1, $2}' |
# 	sed 's/\(.\{1,\}\)_py/\1/'
}

function data_zsv_to_sh {
	cat $data_zsv |
	awk 'BEGIN{FS=" !FS! ";OFS="="} \
			{if ($1 !~ /_py$/) print $1, $2}'
}

function bs_scorez_sh { ## SH VERSION
	$pytsop/bs_scorez.sh $params_vars_sh $data_sh
}


function add_var_lists_to_zsv {
	var_list=$(
		cat $data_zsv |
		awk 'BEGIN {FS=" !FS! "; ORS=" "} \
			{if ($1 !~ /^$/) print $1}'|
		sed 's/^ *\([^ ].*[^ ]\) *$/\"\1\"/'
	)
	var_list_py=$(
		echo $var_list |
		sed 's/^\"\(.*\)\"$/\[\"\1\"\]/' |
		sed 's/ /\", \"/g'
	)

	data_zsv_append var_list
	data_zsv_append var_list_py
}

function append_all_data_to_csv {
	firstlig=$(echo $LIGSET_LIST | awk 'BEGIN{FS=" "} {print $1}')
	l=$firstlig
	data_zsv=$data_zsv_dir/$d\_$l\_m1.data.zsv

	master_var_list=$(
		cat $data_zsv |
		awk 'BEGIN {FS=" !FS! ";ORS=" "} \
			{if ($1 !~ /var_list|_py/) \
				print $1}'
	)
	csv_keys=$(
		echo $master_var_list |
		awk 'BEGIN{RS=" ";ORS=","} \
			{print $1}'
	)
	ds_master_var_list=$(
		echo $master_var_list |
		awk 'BEGIN{RS=" ";ORS=","} \
			{print "\$" $1}'
	)

	echo $csv_keys > $all_data_csv
	echo "     >created all_data.csv"

	echo "     >appending ligand data to all_data.csv"
	for l in $LIGSET_LIST; do
		echo -n "      ->ligand $l: "
		for m in $MODEL_LIST; do
			data_sh=$data_sh_dir/$d\_$l\_m$m.data.sh
			source $data_sh
			eval_echo_ds_mvl=$(echo "echo $ds_master_var_list")
			eval $eval_echo_ds_mvl >> $all_data_csv
			echo -n "[$m]"
		done
		cr
	done

# 	open $all_data_csv
}

##############################









### EXECUTION
##############################

# LIGSET_LIST="ap as" #####################

function check_files {
	####
####BLOCKED 150930
# 	if [ ! -d $b ]; then echo "!!!error: $b doesn't exist"; exit
# 		else echo "     >base dock dir is good"; fi
# 	if [ ! -d $b/results/ ]; then echo "!!!error: $b/results/ doesn't exist"; exit
# 		else echo "     >dock results dir is good"; fi
# 	for l in $LIGSET_LIST; do
# 		res_pdbqt=$res_pdbqt_dir/$d\_$l\_results.pdbqt
# 		if [ ! -f $res_pdbqt ]; then echo "!!!error: $res_pdbqt doesn't exist" #; exit
# 			else echo "     >$l res.pdbqt is good"
# 		fi
# 	done
	###
	null=""
}

function create_dirs {
	for dir in $dirs_to_make; do
		if [ -d $dir ]; then echo "     >$dir already exists...";
			if [[ $(ls -A "$dir" | wc -l) -ne 0 ]]; then echo \
										"!!!error: $dir not empty; untsop!!"; # exit
			else rmdir $dir; echo "       -->it was empty, so I rmd it"
			fi
		elif [ ! -d $dir ]; then mkdir $dir; echo "     >created $dir"
		fi
	done
}

function extract_data_modelloop {
	echo -n "      -> model $m of $n_MODELS: "
	#####

	##########
	pvrd_pdbqt=$pvrd_pdbqt_dir/$d\_$l\_m$m.pdbqt
	pvrd_pdb=$pvrd_pdb_dir/$d\_$l\_m$m.pdb
	pvrd_pdbqt_csv=$pvrd_pdbqt_csv_dir/$d\_$l\_m$m.pdbqt.csv
	data_zsv=$data_zsv_dir/$d\_$l\_m$m.data.zsv
	data_py=$data_py_dir/$d\_$l\_m$m.data.py
	data_sh=$data_sh_dir/$d\_$l\_m$m.data.sh
	##########

####BLOCKED 150930
#
# ### CONVERT PVRD PDBQT TO PDB
# # 	<pdbqt2pdb>
# 	echo -n "[q2bing..."
# 	if [ -f $pvrd_pdb ]; then echo -n "already q2bd] "
# 	else pvrd_pdbqt_to_pdb; echo -n "q2bd] "
# 	fi
# # 	</pdbqt2pdb>
#

### CONVERT PVRD PDBQT TO CSV
# 	<pdbqt2csv>
	pvrd_pdbqt_to_csv
	if [ -f $pvrd_pdbqt_csv ]; then echo -n "[pvrd.pdbqt -> .csv] "
	else echo "!!!error converting $l pvrd.pdbqt to .csv"
	fi
# 	</pdbqt2csv>

### CREATE DATA ZSV FILE FOR THIS MODEL
# 	<createdatazsv>
	key=$d\_$l\_m$m
	data_zsv_append key > $data_zsv
	echo -n "[created new data.zsv] "
# 	</createdatazsv>

	###
	cr; echo -n "                       "
	###

### ADD DOCKING PARAMETERS TO DATA ZSV
# 	<paramstodatazsv>
	append_params >> $data_zsv
	echo -n "[params >> data.zsv] "
# 	</paramstodatazsv>

### APPEND LIG PROPS TO DATA ZSV
# 	<ligpropstodatazsv>
	cat $LIG_props_zsv >> $data_zsv
	echo -n "[ligprops >> data.zsv] "
# 	</ligpropstodatazsv>

### EXTRACT DATA FROM PVRDs
# 	<pvrdatatodatazsv>
	pvrd_pdbqt_extract >> $data_zsv
	echo -n "[vinaout >> data.zsv] "
# 	</pvrdatatodatazsv>

	###
	cr; echo -n "                       "
	###
#
# ### GENERATE DATA PY FROM ZSV
# # 	<pvrdatazsvtopy>
# 	data_zsv_to_py > $data_py
# 	echo -n "[data.zsv -> .py] "
# # 	</pvrdatazsvtopy>

### GENERATE DATA SH FROM ZSV
# 	<pvrdatazsvtosh>
	data_zsv_to_sh > $data_sh
	echo -n "[data.zsv -> .sh] "
# 	</pvrdatazsvtosh>

### BINDING SITE SCORING (using .sh data file)
# 	<bsscorezsh>
	bs_scorez_sh |
	awk 'BEGIN {FS="=";OFS=" !FS! "} \
	{ if ($2 !~ /^$/) print $1, $2}' >> $data_zsv

	echo -n "[bs_scorez_sh >> data.zsv] "
# 	</bsscorezsh>

	add_var_lists_to_zsv >> $data_zsv

### GENERATE DATA PY FROM ZSV
# 	<pvrdatazsvtopy>
	data_zsv_to_py > $data_py
	echo -n "[data.zsv -> .py] "
# 	</pvrdatazsvtopy>

### UPDATE DATA SH FROM ZSV
# 	<pvrdatazsvtosh>
	data_zsv_to_sh > $data_sh
	echo -n "[data.zsv -> .sh] "
# 	</pvrdatazsvtosh>

# 	#<
# 	echo -n "[aiad+icpd....."
# 	#
# 	echo -n " >> data.zsv]"
# 	#/>
#
# 	###
# 	cr
# 	echo -n "                    "
# 	###
#
# 	#<
# 	echo -n "[bs scores....."
# 	#
# 	echo -n " >> data.zsv]"
# 	#/>

	cr
}

function extract_data_ligloop {
	((LSCOUNT++))
	printf "    ->ligand %-14s %-14s " "<$l>" "($LSCOUNT/$LSLEN)"
	#####

	##########
	res_pdbqt=$res_pdbqt_dir/$d\_$l\_results.pdbqt
	res_pdbqt_cleaned=$res_pdbqt_cleaned_dir/$d\_$l\_cleaned.pdbqt
	pvrd_base=$pvrd_pdbqt_dir/$d\_$l\_m
	##########

### LIGAND PROPERTIES
# 	<props>
	LIG_props_txt=$LIGSET_dir/props/$l.txt
	LIG_props_zsv=$LIGSET_dir/props/$l.zsv
	source $LIG_props_txt
# 	</props>

#
# ### CLEAN UP RES.pdbqt
# # 	<cleanup>
# 	clean_up_res_pdbqt
# 	if [ -f $res_pdbqt_cleaned ]; then echo -n "[cleaned up pvr] "
# 	else echo "!!!error cleaning up $l res.pdbqt"
# 	fi
# # 	</cleanup>
#

###	PROCESS VINA RESULTS (split, get E+contacts)>
# 	<pvr>
	echo -n "[pvring....."
	if [ -f $pvrd_pdbqt_dir/$d\_$l\_m1.pdbqt ]; then echo -n "already pvrd] "
	else pvr_the_thing; echo -n "pvrd] "
	fi
# 	</pvr>

	cr

### DATA EXTRACTION/PROCESSING FOR EACH MODEL (of each lig)
# 	<modelloop>
for m in $MODEL_LIST; do
		extract_data_modelloop
		continue
	done
# 	</modelloop>

}

##############################


### DO IT
##############################
function execute {
	echo "--->checking files"
	check_files

	echo "--->creating new directories"
	create_dirs

	echo "--->checking lig props files..."
	LIGSET_dir=$home_dir/Docking/ligsets/$LIGSET
	if [ ! -d $LIGSET_dir/props ]; then
		echo "     >no lig props, making them now"
		mkdir $LIGSET_dir/props
		for l in $LIGSET_LIST; do
			echo -n "      ->generating props for ligand $l....."
			#
			LIG_props_txt=$LIGSET_dir/props/$l.txt
			LIG_props_zsv=$LIGSET_dir/props/$l.zsv
			#
			generate_lig_props
			echo "wrote props.txt"
			#
			if cat $LIG_props_txt.err | grep -vq '^$'; then
				echo "        ->obprop error: "
				cat $LIG_props_txt.err | awk '{print "\t\t", $0}'
			fi
			rm -f $LIG_props_txt.err
		done
	else echo "     >props files already made"
	fi

						# 	echo -n "[lig props..."
					# 	if [ -f $LIG_props_txt ]; then echo -n "found] "
					# 	else echo -n "generating now..."; generate_lig_props; echo -n "done] "

	echo "--->extracting data"
	ls_len;	LSCOUNT=0
	for l in $LIGSET_LIST; do
		LIG=$l
		extract_data_ligloop
		continue
	done

	echo "--->writing output csv"
	append_all_data_to_csv

	echo "--->all set"
	echo "     >docking directory is at:"
	echo "		$b"
	echo "     >output all_data.csv is at:"
	echo "		$all_data_csv"

	echo "----------->kbai"

}
##############################

execute
# open $b


