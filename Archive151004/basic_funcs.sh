#!/bin/bash

### BASIC FUNCTIONS FOR DOCKING STUFF

function source_params {
	params=$($pytsop/dockid_to_params.sh $1)
	eval $params
}

function que_hora {
# 	date "+%y%m%d%H%M%S"
	yyyy=$(date "+%Y")
	yy=$(date "+%y")
	dd=$(date "+%d")
	mm=$(date "+%m")
	Mth=$(date "+%b")
	Month=$(date "+%B")
	DayofWeek=$(date "+%A")
	Daywk=$(date "+%a")
	HH=$(date "+%H")			# 24hr
	HH_12h=$(date "+%I")		# 12hr
	MM=$(date "+%M")
	SS=$(date "+%S")
	nanoSS=$(date "+%N")
	zone=$(date "+%z")
	zone_name=$(date "+%Z")

	reg_time=$(date "+%X")
	reg_date=$(date "+%X")

	yymmdd=$(echo $yy$mm$dd)
	HHMMSS=$(echo $HH$MM$SS)
	HHMMSSnano=$(echo $HH$MM$SS)
	yymmddHHMMSS=$(echo $yymmdd$HHMMSS)

# 	yymmdd=$(date "+%y%m%d")
# 	HHMMSS=$(date "+%H%M%S")
# 	yymmddHHMMSS=$(date "+%y%m%d%H%M%S")
}

function tell_time {
	que_hora
	label=$1
	echo yyyy_$label=\"$yyyy\"
	echo yy_$label=\"$yy\"
	echo dd_$label=\"$dd\"
	echo mm_$label=\"$mm\"
	echo Mth_$label=\"$Mth\"
	echo Month_$label=\"$Month\"
	echo DayofWeek_$label=\"$DayofWeek\"
	echo Daywk_$label=\"$Daywk\"
	echo HH_$label=\"$HH\"
	echo MM_$label=\"$MM\"
	echo SS_$label=\"$SS\"
	echo zone_$label=\"$zone\"
	echo zone_name_$label=\"$zone_name\"

	echo yymmdd_$label=\"$yymmdd\"
	echo HHMMSS_$label=\"$HHMMSS\"
	echo yymmddHHMMSS_$label=\"$yymmddHHMMSS\"

# 	find: (\t)(.+)(=)(.+); replace: \techo \2_$label=\\"$\2\\"
}

function store_time {
	label=$1
	time_info=$(tell_time $label)
	eval $time_info
	HH_label="echo HH_$label"
	echo $HH_label
}

function last_access {
	stat -Ft "%y%m%d%H%M%S" $1 | awk '{print $6}'
}

function cr {
	echo ""
}

function bigline {
	cr
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	cr
}

function line {
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}

# function time_diff {
#
# }


# function day {
# 	date "+%y%m%d"
# }
# function now_read {
# 	date "+%D %H:%M:%S"
# }
# function time_long {
# 	date "+%H:%M:%S %Z (%z)"
# }
# function day_long {
# 	date "+%A %B %d, %Y"
# }
# function now_long {
# 	day_long
# 	time_long
# }




