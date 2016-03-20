#!/bin/bash



home_dir="/Users/zarek/lab"
pytsop="$home_dir/scriptz/pytsop"
source $home_dir/scriptz/basic_funcs.sh


function end {
	bigline
	echo ">>>>>DONE<<<<<"
	cr
	exit
}

###DEFUNCT?

# retrieve parameters
function dockid_to_params {
	$pytsop/dockid_to_params.sh $d
}

# apply those params now
function eval_params {
	params=$( dockid_to_params )
	eval $params
}

# store params in params.txt
function write_params {
	echo $params > $b/pytsop_params.txt
}


# get functions used in all scripts
function basic_funcs {
# 	echo basic funcs
	null=""
}

function basics {
# 	eval_params
# 	write_params
# 	basic_funcs
	dockid_to_params $d
}

function basics {
	source $home_dir/scriptz/basic_funcs.sh

	cr
	echo ">>>COMMENCE<<<"
	bigline

	echo "<BASICS>"
	source $pytsop/basics.sh $d
	echo "</BASICS>"
	cr
}




# for option -t: new tsops
function tsop {
# 	echo ""
	echo "<TSOP> (starting post-processing for docking $d)"
	$pytsop/pytsop.sh $b/$d\_params.vars.sh

	echo "</TSOP>"
# 	echo ""

# 	open $b
}

# for option -u: archiving old tsops
function untsop {
	echo "gonna untsop (archive) $d"
	$pytsop/pyuntsop.sh $d

	echo "finished untsopping (archiving) docking $d"
}

# for option -d: deleting old tsops
function detsop {
	echo "gonna detsop (delete) $d"
	$pytsop/pydetsop.sh $d

	echo "finished detsopping (deleting) docking $d"
}

# for option -h: help
function help {
	echo "
	pytsop/ex.sh executes the pytsop scripts

	Options (all but -h require dockid as argument):
		-p only lists parameters
		-b only does basics (evaluates parameters)
		-u archives the the old tsop files
		-d deletes the old tsop files
		-t executes tsop
		-h gets you this help message
		"
}



while getopts p:b:u:d:t:he option; do
        case $option in
        	p) d=$OPTARG; dockid_to_params; end;;
        	b) d=$OPTARG; basics; end;;
        	u) d=$OPTARG; basics; untsop; end;;
        	d) d=$OPTARG; basics; detsop; end;;
        	t) d=$OPTARG; basics; tsop; end;;
        	e) echo "
        		OMGOMGOMGOMG EAASTER eeEEEGggGGGggg!!!¡¡¡¡!!!!
        		";;
        	h) help; end
        esac
done

help

