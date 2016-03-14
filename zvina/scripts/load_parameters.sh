#!/bin/bash

### Print parameters (originally load_parameters.sh)
# (c) Zarek Siegel
# v1 3/4/16
# v1.1 3/5/16
# v2 3/5/16
# v3 3/11/16

# Docking ID as required argument
# dock=$1

# Set scripts directory to the directory containing this script
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Set base directory to the one containing scripts_dir
base_dir="$( cd $scripts_dir && cd .. )"
# Source # AutoDockTools Directory and MGLTools Python binary paths from constants.py
source $scripts_dir/constants.py
# CSV file with docking parameters
dockings_csv=$base_dir/Dockings.csv

# Define a function for looking
function look_up {
	parameter=$1 # argument taken is the column header
	cat $dockings_csv | # look in Dockings.csv
	# AWK script to look up parameter for docking in the CSV
	awk -v dock="$dock" -v parameter="$parameter" \
		'BEGIN{
			FS=","; # CSV
			dock_row=""; # declare global variables
			parameter_field="";
		}
		{
			if ($1 == dock) {
				dock_row=NR; # determine which row to look in
			}
		}
		NR==1{
				for (f=1; f<=NF; f++) {
					{
						if ($f == parameter) {
							parameter_field=f; # determine which row to look in
						}
					}
				}
		}
		NR==dock_row{print $parameter_field} # output the intersection
	'
}

# Source all relevant parameters
dock=$( look_up "Docking ID" )
date=$( look_up "Date" )
prot=$( look_up "Protein" )
ligset=$( look_up "Ligset" )
box=$( look_up "Gridbox" )
exhaust=$( look_up "Exhaustiveness" )
n_models=$( look_up "Number of Models" )
n_cpus=$( look_up "Number of CPUs" )

# Print all parameters
export dock=$dock
export date=$date
export prot=$prot
export ligset=$ligset
export box=$box
export exhaust=$exhaust
export n_models=$n_models
export n_cpus=$n_cpus


