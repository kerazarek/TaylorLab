#!/bin/bash

### Load filesystem constants
# (c) Zarek Siegel
# v1 3/4/16

### The one required thing
fs_constants_csv="/Users/zarek/GitHub/TaylorLab/zvina/scripts/filesystem_constants.csv"

while read line
do
	constant_exec=$(echo $line | sed 's/^\([^,]\{1,\}\),\([^,]\{1,\}\),/\1=\"\2\"/')
	eval $constant_exec
done <$fs_constants_csv

