#!/usr/bin/env python

import csv
from itertools import chain, repeat
from sys import argv
from math import sqrt

########## GOOOOODDD TTIIIIMMMMEEEEES
# 				created 1507191735

# ftr i use 'dic' for the specific dictionaries i make,
# 		whereas 'dict' is the specific kind of python data structure



script, lig1_csv, lig2_csv, out = argv

### SPECIFY LIG CSVs (from pdbqts)
# lig1_csv = "/Users/zarek/mr/nce.csv"
# lig2_csv = "/Users/zarek/mr/s4.csv"
#
#		*NOTE: csvs are of form:
# 			num,atom,x,y,z
# 			1,C,-14.757,24.548,2.379


### OPEN LIG CSVs
lig1_csv_open = open(lig1_csv, 'r')
lig2_csv_open = open(lig2_csv, 'r')

### READ LIG CSVs AS DICTs
lig1_csv_dic = csv.DictReader(lig1_csv_open, delimiter=',', quotechar='"')
lig2_csv_dic = csv.DictReader(lig2_csv_open, delimiter=',', quotechar='"')
#		*NOTE: this are really lists of dictionaries, so need next step

###  CREATE LIG DI"#770096"CTs (which are basically lists of dicts,
#					   although they are technically dicts of dicts)
lig1_dic = {}
lig2_dic = {}

for row in lig1_csv_dic:
	lig1_dic[int(row['num'])] = {
		'x' : float(row['x']),
		'y' : float(row['y']),
		'z' : float(row['z']),
		'atom' : row['atom'],
		'index' : row['num']
	}

for row in lig2_csv_dic:
	lig2_dic[int(row['num'])] = {
		'x' : float(row['x']),
		'y' : float(row['y']),
		'z' : float(row['z']),
		'atom' : row['atom'],
		'index' : row['num']
	}

### 3D DISTANCES
# dist bet 2 pts in 3d space:
# 	with A = (x1,y1,z1), B = (x2,y2,z2)
# 	dist_AB = sqrt( (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2 )

x = """hi"""


def dist( pt11, pt12 ):
	x1 = pt11['x']
	y1 = pt11['y']
	z1 = pt11['z']
	x2 = pt12['x']
	y2 = pt12['y']
	z2 = pt12['z']
	return sqrt( ((x2 - x1) ** 2) + ((y2 - y1) ** 2) + ((z2 - z1) ** 2) )

def dic_dist(i1, i2):
	return dist( lig1_dic[i1], lig2_dic[i2] )

### CREATE LIST OF ALL DISTANCES
dist_list = []

for i1 in lig1_dic:
	for i2 in lig2_dic:
		dist_list.append( dic_dist(i1, i2) )

### STATS (yes i know i am dumb)
def mean(L):
	return sum(L) / len(L)
def variance(L):
	meandiffssquared = []
	for a in L:
		meandiffssquared.append( ( a - mean(L) ) ** 2 )
	return mean(meandiffssquared)
def stdev(L):
	return sqrt(variance(L))

# print min(dist_list)
# print max(dist_list)
# print mean(dist_list)
# print variance(dist_list)
# print stdev(dist_list)

### AVERAGE INTERATOMIC DISTANCE (AIAD)
aiad = mean(dist_list)
# print aiad

### MOLECULAR CENTERPOINTS
def center(dict):
	x_pts = []
	y_pts = []
	z_pts = []
	for i in dict:
		x_pts.append(dict[i]['x'])
		y_pts.append(dict[i]['y'])
		z_pts.append(dict[i]['z'])
	x_cent = mean(x_pts)
	y_cent = mean(y_pts)
	z_cent = mean(z_pts)
	return {'x':x_cent, 'y':y_cent, 'z':z_cent}

lig1_cp = center(lig1_dic)
lig2_cp = center(lig2_dic)

### INTERCENTERPOINT DISTANCE (ICPD)
icpd = dist(center(lig1_dic), center(lig2_dic))

### RESULTS
if out == 'aiadv' or out == 'av':
	print "Average Inter-Atomic Distance (AIAD) is:", aiad
elif out == 'icpdv' or out == 'iv':
	print "Inter-Centerpoint Distance (ICPD) is:", icpd
elif out == 'aiad' or out == 'a':
	print aiad
elif out == 'icpd' or out == 'i':
	print icpd
elif out == 'both' or out == 'b':
	print "Average Inter-Atomic Distance (AIAD) is:", aiad
	print "Inter-Centerpoint Distance (ICPD) is:", icpd
else:
	print """
	yo stupid! <<%s>> is invalid.
	u must specify [aiad/icpd/aiadv/icpdv/both] (or a/i/av/iv/b) as arg3.
	""" % out




