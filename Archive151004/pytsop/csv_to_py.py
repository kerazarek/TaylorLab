#!/usr/bin/env python

import csv, itertools
from sys import argv

script, csv_in, r, c = argv
# script, row, column = argv

# csv_in = "/Users/zarek/lab/Docking/docks_csvs/docks_p300.csv"

### OPEN CSVs
csv_open = open(csv_in, 'r')


### READ CSVs AS LISTS
csv_read = csv.reader(csv_open, delimiter=',', quotechar='"')
csv_list = []
for row in csv_read:
	csv_list.append(row)


### DICTIFY!
keys = csv_list[0]

csv_dic = {}
for row in csv_list:
	dic_entry = {}
	for i in range(0,len(keys)):
		dic_entry[keys[i]] = row[i]
	csv_dic[row[1]] = dic_entry
	
### REPORT
print csv_dic[r][c]
