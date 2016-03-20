#!/bin/bash

d=$1

date=$(date "+%y%m%d%H%M")

log=$hepi/$d/$d\_tsoplog_$date.txtw

echo "# $log" > $log 

open $log

$scriptz/tsop.sh $d &>>$log