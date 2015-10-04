#!/bin/bash

DOCK=$1

function get_prot {
	PROT_LETTER=$( echo $DOCK | sed -E 's/(.)(.+)/\1/' )

	if test $PROT_LETTER == "p"; then
		PROT="p300"
	elif test $PROT_LETTER == "h"; then
		PROT="hepi"
	else
		echo "bad dock id"
		exit
	fi
}

function base_dirs {
	home_dir="/Users/zarek/lab"
	docking="$home_dir/Docking"
	scriptz="$home_dir/scriptz"
	tsop="$scriptz/pytsop"
}

function last_access {
	stat -Ft "%y%m%d%H%M%S" $1 | awk '{print $6}'
}

function load_docks_xlsx {
	tx=$( last_access /Users/zarek/lab/Docking/docks.xlsx )
	tc=$( last_access /Users/zarek/lab/Docking/docks_csvs/docks_hepi.csv )

	if (( $tx > $tc )); then
		RScript $tsop/docks_csvs_refresh.R $home_dir
	fi
}

function read_dockkey_csv {
	dockkey_p300=$docking/docks_csvs/docks_p300.csv
	dockkey_hepi=$docking/docks_csvs/docks_hepi.csv
# 	dockkey_pdbs=$docking/docks_csvs/docks_pdbs.csv

	if test $PROT_LETTER == "p"; then
		dockkey_PROT=$dockkey_p300
	elif test $PROT_LETTER == "h"; then
		dockkey_PROT=$dockkey_hepi
	fi

	DATE=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "DATE" )
	SPECPROT=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "SPECPROT" )
	LIGSET=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "LIGSET" )
	BOX=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "BOX" )
	EXHAUST=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "EXHAUST" )
	n_MODELS=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "n_MODELS" )
	n_CPUS=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "n_CPUS" )
	DOCK_ENERGY_RANGE=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "ENERGY_RANGE" )
	DOCK_NOTES=$( python $tsop/csv_to_py.py $dockkey_PROT $DOCK "notes" )
}

function get_baseprot {
	if echo $SPECPROT | grep -Eq 'p300'; then
		BASEPROT="p300"
	elif echo $SPECPROT | grep -Eq 'h1$'; then
		BASEPROT="h1"
	elif echo $SPECPROT | grep -Eq 'h1[^c].*'; then
		BASEPROT="h1"
	elif echo $SPECPROT | grep -Eq 'h1c.*'; then
		BASEPROT="h1c"
	else
		echo "!!!bad specprot cant get baseprot!!!"
		exit
	fi
}

function read_ligsets_csv {
	dockkey_ligsets=$docking/docks_csvs/docks_ligsets.csv
	LIGSET_LIST=$( python $tsop/csv_to_py.py $dockkey_ligsets $LIGSET "lig_list" )
	LIGSET_LIST_py=$(
		echo $LIGSET_LIST |
		sed 's/^\(.*\)$/\[\"&\"\]/' |
		sed 's/ /\", \"/g'
	)
}

function read_gridboxes_csv {
	dockkey_gridboxes=$docking/docks_csvs/docks_gridboxes.csv
	BOX_description=$( python $tsop/csv_to_py.py $dockkey_gridboxes $BOX "description" )
	BOX_size_x=$( python $tsop/csv_to_py.py $dockkey_gridboxes $BOX "size_x" )
	BOX_size_y=$( python $tsop/csv_to_py.py $dockkey_gridboxes $BOX "size_y" )
	BOX_size_z=$( python $tsop/csv_to_py.py $dockkey_gridboxes $BOX "size_z" )
	BOX_center_x=$( python $tsop/csv_to_py.py $dockkey_gridboxes $BOX "center_x" )
	BOX_center_y=$( python $tsop/csv_to_py.py $dockkey_gridboxes $BOX "center_y" )
	BOX_center_z=$( python $tsop/csv_to_py.py $dockkey_gridboxes $BOX "center_z" )

	BOX_center_triple="($BOX_center_x, $BOX_center_y, $BOX_center_z)"
	BOX_size_triple="($BOX_size_x, $BOX_size_y, $BOX_size_z)"
}

function shorthand_vars {
	d=$DOCK
	p=$PROT
	s=$SPECPROT
}

function misc_dock_vars {
	b="$docking/$PROT/$DOCK"
	res_pdbqt_dir="$b/results"
	specprot_pdbqt="$docking/$PROT/$SPECPROT.pdbqt"
	MODEL_LIST=$( m=1; while [[ $m -le $n_MODELS ]]; do echo $m; ((m++)); done )
	MODEL_LIST_py=$(
		echo $MODEL_LIST |
		sed 's/^\(.*\)$/\[\"&\"\]/' |
		sed 's/ /\", \"/g'
	)
}

function list_vars {
	bare_vars=$(
		cat $0 | grep -v -e '^#' -e 'bare_vars' | grep '[A-Za-z0-9_]=' |
		sed -e 's/\([^=]*\)=\(.*\)/\1/' -e 's/[[:space:]]//g' | sort -u
	)

# 	__vars=$(for bv in $bare_vars; do echo __$bv; done)

# 	ds_vars=$(for uv in $__vars; do echo $uv | sed 's/__/$/'; done)

# 	for bv in $bare_vars; do echo $bv; done
	for bv in $bare_vars; do echo -n $bv=\"; eval "echo -n \$$bv"; echo "\";"; done

}





############################################################
function execute {
	get_prot
	base_dirs
	load_docks_xlsx ###NORMALLYDO
	read_dockkey_csv
	get_baseprot
	read_ligsets_csv
	read_gridboxes_csv
	shorthand_vars
	misc_dock_vars

	list_vars
}

execute
