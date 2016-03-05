#!/bin/bash

### Load parameter file
# (c) Zarek Siegel
# v1 3/4/16

# Docking ID as required argument
dock=$1

# Required for all other system directories and such
fs_constants_csv="/Users/zarek/GitHub/TaylorLab/zvina/scripts/filesystem_constants.csv"

# Load basic filesystem constants
# (docking_dir, ligsets_dir, scripts_dir, docks_csv, gridboxes_csv)
while read line
do
	constant_exec=$(echo $line | sed 's/^\([^,]\{1,\}\),\([^,]\{1,\}\),/\1=\"\2\"/')
	eval $constant_exec
done <$fs_constants_csv

#
#** params in dock folder or docking folder or prot??
parameters_csv=$docking_dir # with params.csv in docking dir
echo $parameters_csv $1