#!/usr/bin/env python

import parse_pdb
from math import sqrt

def threeD_distance(triple1, triple2):
	x1 = triple1[0]
	y1 = triple1[1]
	z1 = triple1[2]
	x2 = triple2[0]
	y2 = triple2[1]
	z2 = triple2[2]
	distance = sqrt( ((x2 - x1)**2) + ((y2 - y1)**2) + ((z2 - z1)**2) )
	return distance

def dist_to_closest_atom(first_triple, second_triple_list):
	dists = []
	for second_triple in second_triple_list:
		dists.append(threeD_distance(first_triple, second_triple))
	return min(dists)

def rmsd(list):
	squared_list = [x ** 2 for x in list]
	return sqrt(
		(1 / len(list)) * sum(squared_list)
	)

def get_rmsd(pdb_obj1, pdb_obj2):
	if len(pdb_obj1.coord_triples) > len(pdb_obj2.coord_triples):
		bigger_molc = pdb_obj1
		smaller_molc = pdb_obj2
	elif len(pdb_obj1.coord_triples) < len(pdb_obj2.coord_triples):
		bigger_molc = pdb_obj2
		smaller_molc = pdb_obj1

	distances = []
	for sm_triple in smaller_molc.coord_triples:
		distances.append(
			dist_to_closest_atom(sm_triple, bigger_molc.coord_triples)
		)

	return rmsd(distances)

def main():
	molc1_address = "/Users/zarek/lab/zvina/hepi/h33/processed_pdbs/h33_aa8_m3.pdb"
	molc2_address = "/Users/zarek/lab/zvina/hepi/h33/processed_pdbs/h33_aa10_m1.pdb"

	molc1 = parse_pdb.Pdb(molc1_address)
	molc2 = parse_pdb.Pdb(molc2_address)

	rmsd = get_rmsd(molc1, molc2)
	print(rmsd)

if __name__ == "__main__": main()