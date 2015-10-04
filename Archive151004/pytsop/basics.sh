#!/bin/bash

home_dir="/Users/zarek/lab"
pytsop="$home_dir/scriptz/pytsop"
source $home_dir/scriptz/basic_funcs.sh

d=$1

function basics {

	function get_params {
		params=$($pytsop/dockid_to_params.sh $d)
		eval $params
	}

	function params_to_sh {
		echo $params | awk 'BEGIN{RS="; "} { print $0 }'
	}

	function params_to_zsv {
		echo "var !FS! \"value\" !FS! type"
		while read line; do
			var=$(echo $line | sed 's/\([A-Za-z0-9_]*\)=\(\".*\"\)/\1/')
			value=$(echo $line | sed 's/\([A-Za-z0-9_]*\)=\(\".*\"\)/\2/')
			if echo $var | grep -vq '^$'; then
				if echo $var | grep -Eiq 'list_py'; then
					type="pylist"
					value=$(echo $value | sed 's/\(\"\)\(.*\)\(\"\)/\2/')
				elif echo $var | grep -Eiq 'list'; then
					type="list"
				elif echo $value | grep -Eq '^\"[\(].*[\)]\"$'; then
					type="tuple"
					value=$(echo $value | sed 's/\(\"\)\(.*\)\(\"\)/\2/')
				elif echo $value | grep -Eq '^\"NA\"$'; then
					type="null"
# 				elif echo $value | grep -Eq '^$'; then
# 					type="null"
# 					value=NA
				elif echo $value | grep -Eq '^\"\/(Users|home).*\..+'; then
					type="file"
				elif echo $value | grep -Eq '^\"\/(Users|home).*'; then
					type="dir"
# 				elif echo $value | grep -Eq '^\"[0-9.-]*\"$'; then
# 					type="num"
# 					value=$(echo $value | tr -d '"')
				elif echo $var | grep -Eq 'EXHAUST|n_CPUS|n_MODELS'; then
					type="int"
					value=$(echo $value | sed 's/\(\"\)\(.*\)\(\"\)/\2/')
				elif echo $var | grep -Eq 'BOX_center|BOX_size'; then
					type="float"
					value=$(echo $value | tr -d '"')
				elif echo $value | grep -Eq '^\"[A-Za-z0-9_]*\"$'; then
					type="str"
				elif [ $var == 'DATE' ]; then
					type="date"
					if echo $value | grep -Eq '....-..-..'; then
						value=$(echo $value | sed \
									's/\(..\)\(..\)-\(..\)-\(..\)/\2\3\4/')
					fi
				else
					type="comment/error"
				fi
				echo $var !FS! $value !FS! $type
			fi
		done < $b/$d\_params.vars.sh
	}

	function params_to_sh_again {
		while read line; do
			echo $line | awk 'BEGIN{FS=" !FS! ";OFS="="} \
							  { if ($1 !~ /LIST_py/ && \
							  		$1 !~ /triple/) \
							  print $1, $2}'
		done < $b/$d\_params.vars.zsv
	}

	function params_to_csv {
		while read line; do
			echo $line | awk 'BEGIN{FS=" !FS! ";OFS=","} \
							  { if ($1 !~ /LIST_py/ && \
							  		$1 !~ /triple/) \
							  print $1, $2, $3 }'
		done < $b/$d\_params.vars.zsv
	}

	function params_to_py {
		while read line; do
			echo $line | awk 'BEGIN{FS=" !FS! ";OFS=" = "} \
							  { print $1, $2 }'
		done < $b/$d\_params.vars.zsv
	}


	get_params
	echo "----->retrieved params"

	params_to_sh > $b/$d\_params.vars.sh ###NORMALLYDO ALL BELLOW
	echo "----->created params.sh file"

	params_to_zsv > $b/$d\_params.vars.zsv
	echo "----->created params.zsv file"

	params_to_sh_again > $b/$d\_params.vars.sh
	echo "----->updated params.sh file"

	params_to_csv > $b/$d\_params.vars.csv
	echo "----->created params.csv file"

	params_to_py > $b/$d\_params.vars.py
	echo "----->created params.py file"


#   	open $b


}

basics