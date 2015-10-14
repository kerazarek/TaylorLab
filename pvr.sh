#!/bin/bash

##################################################
###	PVR (process Vina results)
##################################################
# (c) Zarek Siegel
# created 10/12/15 22:23
#
#
# 		ready results for post_vina.py
#
#
# updated 10/12/15 22:23
#
#

dock=$1

gtl="/Users/zarek/GitHub/TaylorLab"

function get_params {
	python $gtl/get_params.py $dock sh
}


function execute {
	get_params
}

execute
# python $gtl/get_params.py "$dock" "sh"
