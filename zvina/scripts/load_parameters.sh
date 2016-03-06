#!/bin/bash

### Load parameter file
# (c) Zarek Siegel
# v1 3/4/16
# v1.1 3/5/16

# Docking ID as required argument
dock=$1

# Required for all other system directories and such
fs_constants_csv="/Users/zarek/GitHub/TaylorLab/zvina/scripts/filesystem_constants.csv"

# Load basic filesystem constants
# (base_dir, ligsets_dir, scripts_dir, docks_csv, gridboxes_csv)
# fsc_temp=~/fsc_temp_$(date "+%Y%m%d%H%M%S").txt
# fsc_temp2=~/fsc_temp2_$(date "+%Y%m%d%H%M%S").txt
# convert from csv, store in temp filesystem_constants.csv
# while read line
# do
# 	constant=$(echo $line | sed 's/^\([^,]\{1,\}\),\([^,]\{1,\}\),/\1=\"\2\"/')
# 	echo "$constant" >> $fsc_temp
# done <$fs_constants_csv
# # cat $fsc_temp | sed $'s/\r$//' > $fsc_temp2
# # fsc_temp2=$(cat $fsc_temp)
# # fsc_temp2=$(for x in $(cat $fsc_temp); do echo $x; done)
# # echo $fsc_temp2
# # cat $fsc_temp
# # source the temp file, then remove it
# source $fsc_temp
# # rm -f $fsc_temp
# base_dir=
# echo $base_dir/ff

# Source parameters_csvs

# parameters_csvs=$(echo $base_dir | sed 's/.$/parameters_csvs\//')
# cd $parameters_csvs
# par_temp=~/par_temp_$(date "+%Y%m%d%H%M%S").txt
# while read line
# do
# 	param=$(echo $line | sed 's/^\([^,]\{1,\}\),\([^,]\{1,\}\)/\1=\2/')
# 	echo "$param" >> $par_temp
# done <$dock\_parameters.csv
# source $par_temp
# rm -f $par_temp

base_dir="/Users/zarek/GitHub/TaylorLab/zvina/"
parameters_csv=$base_dir\parameters_csvs/$dock\_parameters.csv

params_temp=~/params_temp_$(date "+%Y%m%d%H%M%S").txt
cat $parameters_csv | sed 's/,/=/' > $params_temp
source $params_temp
rm -f $params_temp
