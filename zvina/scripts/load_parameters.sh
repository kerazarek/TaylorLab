#!/bin/bash

### Load parameter file
# (c) Zarek Siegel
# v1 3/4/16
# v1.1 3/5/16
# v2 3/5/16

# Docking ID as required argument
dock=$1

# Required for all other system directories and such
base_dir=$2

# CSV file with docking parameters
parameters_csv=$base_dir\parameters_csvs/$dock\_parameters.csv
# Convert to shell variables and load into a temp file
params_temp=~/params_temp_$(date "+%Y%m%d%H%M%S").txt
cat $parameters_csv | sed 's/,/=/' > $params_temp
# Apply the parameters
source $params_temp
# Ditch the temp file
rm -f $params_temp
