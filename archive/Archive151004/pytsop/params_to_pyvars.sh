#!/bin/bash

### CONVERT (sh) PARAMS INTO PYTHON VARS

DOCK=$1

source $pytsop/basic_funcs.sh

source_params $DOCK

params_file="$b/params.txt"

while read line; do
	if echo $line | grep -q 'LIST'; then
		echo $line |
		sed -e 's/ /\", \"/g' \
			-e 's/\(^[A-Za-z0-9_]*\)=\"\(.*\)\"/\1 = \[\"\2\"\]/'
	elif echo $line | grep -q 'DATE="....-..-..'; then
		echo $line |
		sed 's/\(^[A-Za-z0-9_]*\)=\"\(..\)\(..\)-\(..\)-\(..\)\"/\1 = \"\3\4\5\"/'
	else
		echo $line | sed 's/\(^[A-Za-z0-9_]*\)=\(.*\)/\1 = \2/'
	fi
done < $params_file