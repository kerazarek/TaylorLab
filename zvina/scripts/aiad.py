#!/usr/bin/env python

### Calculating average inter-atomic distance
# (c) Zarek Siegel
# v1 3/6/16

from parse_pdbqt import *
from math import sqrt
from numpy import mean

class Molecule():
	def list_coords(self):
		self.coord_triples = []
		for atom in self.pdb.coords:
			self.coord_triples.append(atom['xyz'])

	def __init__(self, pdb):
		self.pdb = pdb
		self.list_coords()

def threeD_distance(triple1, triple2):
	x1 = triple1[0]
	y1 = triple1[1]
	z1 = triple1[2]
	x2 = triple2[0]
	y2 = triple2[1]
	z2 = triple2[2]
	distance = sqrt( ((x2 - x1)**2) + ((y2 - y1)**2) + ((z2 - z1)**2) )
	return distance

def caclulate_aiad(molc1, molc2):
	dist_list = []
	for triple1 in molc1.coord_triples:
		dists_from_t1 = []
		for triple2 in molc2.coord_triples:
			dist = threeD_distance(triple1, triple2)
			dists_from_t1.append(dist)
		dist_list.append(min(dists_from_t1))
	return mean(dist_list)


def main():
	# m1_p = Pdb("/Users/zarek/lab/Docking/p300/p27/res_pdbqts_cleaned/p27_s3_m4.pdbqt")
# 	m2_p = Pdb("/Users/zarek/lab/Docking/p300/p27/res_pdbqts_cleaned/p27_s2_m142.pdbqt")
# 	m1 = Molecule(m1_p)
# 	m2 = Molecule(m2_p)
# 	caclulate_aiad(m1, m2)
	pass

if __name__ == "__main__": main()
