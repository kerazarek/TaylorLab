#!/bin/bash

pdb_file=$1

cat $pdb_file |
sed -e 's/^\(HETATM\)\(.\{11\}\)\(.\{9\}\)\(.\{1,\}\)/HETATM\2LIG L   1\4/' \
	-e 's/^\(ATOM  \)\(.\{11\}\)\(.\{9\}\)\(.\{1,\}\)/HETATM\2LIG L   1\4/'
