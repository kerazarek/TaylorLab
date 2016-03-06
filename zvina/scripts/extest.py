#!/usr/bin/env python

# from __future__ import print_function
# import csv, re, os
# import cPickle as pickle
# from parse_pdb import *
# from aiad_icpd import *
import postvina_data_mining

print("hi")

def main():
	global base_dir
	base_dir = "/Users/zarek/GitHub/TaylorLab/zvina/"
	global dock
	dock = "h11"

	d = postvina_data_mining.Docking(dock, base_dir)
	d.write_alldata_csv()
	d.cluster_poses()
	d.save_pickled_docking_obj()

if __name__ == "__main__": main()