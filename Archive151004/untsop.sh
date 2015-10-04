#!/bin/bash

DOCK=$1

PROT_LETTER=$( echo $DOCK | sed -E 's/(.)(.+)/\1/' )

if test $PROT_LETTER == "p"; then
	PROT="p300"
elif test $PROT_LETTER == "h"; then
	PROT="hepi"
# elif test $PROT_LETTER == "c"; then
# 	PROT="cbp"
else
	echo "bad dock id"
	exit
fi

d=$DOCK
p=$PROT


#base path
lab="/Users/zarek/lab"
docking="$lab/Docking"
scriptz="$lab/scriptz"
b="$docking/$PROT/$DOCK"

source $b/params.txt

date=$(date "+%y%m%d%H%M")




saves="params.txt results logs archive old txtw"



b_list=$(ls $b)

b_saves=$(
	for b in $b_list; do
		for s in $saves; do
			if echo $b | grep -q $s; then
				echo $b
			fi
		done
	done
)

b_moves=$(
	for bl in $b_list; do
		if echo $b_saves | grep -qv $bl; then
			echo $bl
		fi
	done
)

b_moves_long=$(
	for bm in $b_moves; do
		echo $b/$bm
	done
)

# echo $b_moves_long

cd $b
echo "here in $PWD we have:"
ls

	
echo "are you suuuuuuuure you wanna archive the tsop results for $d (y or n)"
read answer
echo "the files you're gonna move are:"
for bm in $b_moves; do
	echo $bm
done
echo "absolutely sure you wanna move em?"
read answer


if test $answer = "y"; then
	mkdir archive_$date
	for bm in $b_moves; do
		mv $bm archive_$date/
		echo "moved $bm into archive_$date/"
	done
else
	echo "alrighty then, bye!"
	exit
fi