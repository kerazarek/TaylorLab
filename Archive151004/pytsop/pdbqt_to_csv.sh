#!/bin/bash

#####
file_in=$1
#####



### IF PDB
###############
pdb_keys="heading,\
atomi,\
atomn,\
alt_loc_indicator,\
resn,\
chain,\
resi,\
res_insertion_code,\
x_coord,\
y_coord,\
z_coord,\
occupancy,\
temp_factor,\
conversion_artifact,\
element,\
atom_charge"

function pdb_to_csv {
	echo $pdb_keys

	cat $file_in |
	grep -E '^HETATM|^ATOM' |
	sed -e 's/./&,/6' \
		-e 's/./&,/12' \
		-e 's/./&,/18' \
		-e 's/./&,/20' \
		-e 's/./&,/24' \
		-e 's/./&,/27' \
		-e 's/./&,/32' \
		-e 's/./&,/34' \
		-e 's/./&,/46' \
		-e 's/./&,/55' \
		-e 's/./&,/64' \
		-e 's/./&,/71' \
		-e 's/./&,/78' \
		-e 's/./&,/89' \
		-e 's/./&,/92' \
		-e 's/./&,/95' |
		tr -d ' '
}
###############

### IF PDBQT
###############
pdbqt_keys="heading,\
atomi,\
atomn,\
alt_loc_indicator,\
resn,\
chain,\
resi,\
res_insertion_code,\
x_coord,\
y_coord,\
z_coord,\
occupancy,\
temp_factor,\
partial_charge,\
atom_type"

function pdbqt_to_csv {
	echo $pdbqt_keys

	cat $file_in |
	grep -E '^HETATM|^ATOM' |
	sed -e 's/./&,/6' \
		-e 's/./&,/12' \
		-e 's/./&,/18' \
		-e 's/./&,/20' \
		-e 's/./&,/24' \
		-e 's/./&,/27' \
		-e 's/./&,/32' \
		-e 's/./&,/34' \
		-e 's/./&,/46' \
		-e 's/./&,/55' \
		-e 's/./&,/64' \
		-e 's/./&,/71' \
		-e 's/./&,/78' \
		-e 's/./&,/89' \
		-e 's/./&,/93' |
		tr -d ' '
}
###############





### DOOOOO IT
###############
if echo $file_in | grep -q 'pdb$'; then pdb_to_csv
elif echo $file_in | grep -q 'pdbqt$'; then pdbqt_to_csv
else echo "!!!error: bad in-file (not pdb or pdbqt)"
fi
###############








###########################################################################

### NOTES/CLIPBOARD

# markers="6 11 16 17 20 22 26 27 38 46 54 60 66 78 80"
# ticked_markers=$(counter=0; for m in $markers; do echo "$m + $counter" | bc; ((counter++)); done)
# ticked_markers="6 12 18 20 24 27 32 34 46 55 64 71 78 91 94"

# orig pdb
# 6 11 16 17 20 22 26 27 38 46 54 60 66 78 80
# 6 12 18 20 24 27 32 34 46 55 64 71 78 91 94
#
# pdb w artifact
# 6 11 16 17 20 22 26 27 38 46 54 60 66 76 78 80
# 6 12 18 20 24 27 32 34 46 55 64 71 78 89 92 95
#
# pdbqt
# 6 11 16 17 20 22 26 27 38 46 54 60 66 76 79
# 6 12 18 20 24 27 32 34 46 55 64 71 78 89 93


