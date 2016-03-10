#!/usr/bin/env python

from __future__ import print_function
import csv
# from igraph import *

source_csv = "/Users/zarek/GitHub/TaylorLab/zvina/hepi/h11/h11_clustering.csv"

data = []

with open(source_csv) as csvfile:
	reader = csv.DictReader(csvfile)
	for row in reader:
# 		data[row['compared']] = row
		data.append(row)

groups = {}
groups[data[0]['compared']] = []

# for x, y in data.items():
# 	del data[x]['compared']

pairs = []
all_keys = []
not_outliers = []

threshold = 1
for row in data:
	all_keys.append(row['compared'])
	for colkey, colvalue in row.items():
		try:
			if (float(colvalue) < threshold) and ((colkey, row['compared'], colvalue) not in set(pairs)) and (row['compared'] != colkey):
				pairs.append((row['compared'], colkey, colvalue))
				not_outliers.append(colkey)
		except ValueError:
			pass

pairs12 = []
pairs3 = []

csv_out = "/Users/zarek/Desktop/h11_cluster_test.csv"
fieldnames = ["pose1", "pose2", "aiad"]
with open(csv_out, 'w') as csvfile:
	writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
	writer.writeheader()
	for pair in pairs:
		row = {}
		row['pose1'] = pair[0]
		row['pose2'] = pair[1]
		row['aiad'] = pair[2]
		writer.writerow(row)
		pairs12.append((pair[0], pair[1]))
		pairs12.append((pair[2]))

print("Total keys in set: {}".format(len(all_keys)))
print("Threshold (angstroms): {}".format(threshold))
print("Number of edges under threshold: {}".format(len(pairs)))
print("{} keys not in output CSV: ".format(len(all_keys) - len(set(not_outliers))), end = '')
for key in all_keys:
	if key not in set(not_outliers):
		print(key, end = ' ')
print("")

# g = Graph()
# g.add_vertices(pairs12)
# g.add_edges(pairs12)
# # g = Graph(pairs12)\
# print(g.get_edgelist())