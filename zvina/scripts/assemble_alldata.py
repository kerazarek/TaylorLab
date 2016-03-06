#!/usr/bin/env python

### Putting together all parsed data from processed vina results
#		Outputs a pickled python dictionary will all the data for all the poses
# (c) Zarek Siegel
# v1 3/5/16

import sys, csv, re
import cPickle as pickle
from parse_pdbqt import *

script, dock = sys.argv

class Docking():
	def load_parameters(self):
		parameters_csv = "{b_d}parameters_csvs/{d}_parameters.csv".format(b_d=base_dir, d=dock)
		parameters_csv_open = open(parameters_csv, 'r')
		parameters_csv_read = csv.reader(parameters_csv_open)

		parameters_dic = {}
		parameters_list = []

		for row in parameters_csv_read:
			parameters_dic[row[0]] = row[1]

		self.parameters = parameters_dic

	def get_ligset_list(self):
		ligset_list_txt = "{b_d}ligsets/{ls}/{ls}_list.txt".format(
			b_d=base_dir,ls=self.parameters['ligset'])
		ligset_list_txt_open = open(ligset_list_txt, 'r')
		with ligset_list_txt_open as f:
			self.ligset_list = f.read().splitlines()

	def assemble_dic(self):
		self.data_dic = {}
		for lig in self.ligset_list:
			for m in range(1, int(self.parameters['n_models'])+1):
				processed_pdbqt = "{b_d}{p}/{d}/processed_pdbqts/{d}_{lig}_m{m}.pdbqt".format(
					b_d=base_dir, p=self.parameters['prot'], d=dock, lig=lig, m=m)
				pose = Pdb(processed_pdbqt)
				key = "{}_{}_m{}".format(dock, lig, m)
				pose_dic = {
					'key' : key,
					'E' : pose.E,
					'rmsd_ub' : pose.rmsd_ub,
					'rmsd_lb' : pose.rmsd_lb,
					'pvr_resis' : pose.pvr_resis,
					'pvr_resis_atoms' : pose.pvr_resis_atoms,
					'pvr_resis_objs' : pose.pvr_resis_objs,
					'torsdof' : pose.torsdof,
					'macro_close_ats' : pose.macro_close_ats,
					'pvr_model' : pose.pvr_model,
					'coords' : pose.coords
				}
				self.data_dic[key] = pose_dic

	def save_pickled_data_dic(self):
		self.pickled_data_dic = "{b_d}{p}/{d}/{d}_data_dic.p".format(
					b_d=base_dir, p=self.parameters['prot'], d=dock)
		pickle.dump(self.data_dic, open(self.pickled_data_dic, 'wb'))

	def __init__(self, dock):
		self.dock = dock
		self.load_parameters()
		self.get_ligset_list()
		self.assemble_dic()

def main():
	global base_dir
	base_dir = "/Users/zarek/GitHub/TaylorLab/zvina/"

	d = Docking(dock)
	d.save_pickled_data_dic()

if __name__ == "__main__": main()



