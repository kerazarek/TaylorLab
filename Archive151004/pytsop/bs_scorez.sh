#!/usr/local/bin/bash


home_dir="/Users/zarek/lab"
pytsop="$home_dir/scriptz/pytsop"
source $home_dir/scriptz/basic_funcs.sh


params_vars_sh=$1
source $params_vars_sh

data_sh=$2
source $data_sh

# d=$1
# p=$2
# l=$3
# m=$4

# # echo $pvr_resis
#
# lab="/Users/zarek/lab"
# docking="/Users/zarek/lab/Docking"
# b="$docking/$p/$d"

# source $b/params.txt
# source $b/res_data/$d\_$l\_m$m.txt


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

SPECPROT=$s





declare -A PROT_site_resis
declare -A PROT_site_resis_atoms

declare -A PROT_site_resis_score_totals
declare -A PROT_site_resis_atoms_score_totals


for site in $PROT_sites; do
# 	echo "# $site a5resis"
	resis=$(cat $docking/binding_sites/$SPECPROT/a5res_lists/$SPECPROT\_bs_$site\_a5resis.txt)
	PROT_site_resis[$site]=$resis
	resis_atoms=$(cat $docking/binding_sites/$SPECPROT/a5res_atom_lists/$SPECPROT\_bs_$site\_a5resis_atoms.txt)
	PROT_site_resis_atoms[$site]=$resis_atoms
# 	echo ${PROT_site_resis[$site]}

	total=0
	for resi in $resis; do
		((total++))
	done
	PROT_site_resis_score_totals[$site]=$total
# 	echo ${PROT_site_resis_score_totals[$site]}

	total=0
	for resi_atom in $resis_atoms; do
		((total++))
	done
	PROT_site_resis_atoms_score_totals[$site]=$total
# 	echo ${PROT_site_resis_atoms_score_totals[$site]}

# 	for pvr_resi in $pvr_resis; do
# 		echo $pvr_resi
# 	done
done


declare -A PROT_site_resis_scores
declare -A PROT_site_resis_atoms_scores

declare -A PROT_site_resis_score_fractions
declare -A PROT_site_resis_atoms_score_fractions

for site in $PROT_sites; do
# 	echo $site

	score=0
	for site_resi in ${PROT_site_resis[$site]}; do
	# 	PROT_site_resis_scores[$site]=0
		for pvr_resi in $pvr_resis; do
			if test $pvr_resi = $site_resi; then
	# 			echo $pvr_resi
				((score++))
			fi
		done
	done
	PROT_site_resis_scores[$site]=$score

	fraction=$(bc <<< "scale=10;${PROT_site_resis_scores[$site]}/${PROT_site_resis_score_totals[$site]}")
	PROT_site_resis_score_fractions[$site]=$fraction

	score=0
	for site_resi_atom in ${PROT_site_resis_atoms[$site]}; do
		for pvr_resi_atom in $pvr_resis_atoms; do
			if test $pvr_resi_atom = $site_resi_atom; then
				((score++))
			fi
		done
	done
	PROT_site_resis_atoms_scores[$site]=$score

	fraction=$(bc <<< "scale=20;${PROT_site_resis_atoms_scores[$site]}/${PROT_site_resis_atoms_score_totals[$site]}")
	PROT_site_resis_atoms_score_fractions[$site]=$fraction
# 	echo $fraction
done




function output {
	echo "# $p binding_site analysis"
	for site in $PROT_sites; do
		echo resis_score_$site=${PROT_site_resis_scores[$site]}
		echo resis_score_fraction_$site=${PROT_site_resis_score_fractions[$site]}
		echo resis_atoms_score_$site=${PROT_site_resis_atoms_scores[$site]}
		echo resis_atoms_score_fraction_$site=${PROT_site_resis_atoms_score_fractions[$site]}
	done
	echo ""
}

output
