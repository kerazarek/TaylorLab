#!/usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16

import sys, csv, re, os
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
					'pvr_n_contacts' : pose.macro_close_ats,
					'pvr_model' : pose.pvr_model,
					'pvr_effic' : pose.pvr_effic,
					'coords' : pose.coords
				}
				self.data_dic[key] = pose_dic
				self.data_dic[key]['lig'] = lig
				self.data_dic[key]['model'] = m

	def get_binding_sites_list(self):
		binding_sites_dir = "{b_d}{p}/binding_sites/".format(
					b_d=base_dir, p=self.parameters['prot'])
		self.binding_sites_list = []
		self.binding_sites_objs = {}
		for root, dirs, files in os.walk(binding_sites_dir):
			for file in files:
				self.binding_sites_list.append(re.sub('.pdb', '', file))
				self.binding_sites_objs[re.sub('.pdb', '', file)] = (Pdb("{}{}".format(root, file)))

		self.bs_resis_lists = {}
		self.bs_resis_atoms_lists = {}

		for bs, bso in self.binding_sites_objs.items():
			bs_resis = []
			bs_resis_atoms = []

			for atom in bso.coords:
				bs_resis.append("{}{}".format(atom['resn'], atom['resi']))
				bs_resis_atoms.append("{}{}_{}".format(atom['resn'], atom['resi'], atom['atomn']))
			self.bs_resis_lists[bs] = list(set(bs_resis))
			self.bs_resis_atoms_lists[bs] = list(set(bs_resis_atoms))

	def score_binding_sites(self):
		self.bs_resis_fractions = {}
		self.bs_resis_atoms_fractions = {}

		for pose, data in self.data_dic.items():
			for bs in self.binding_sites_list:
				resis_union = ( set(self.bs_resis_lists[bs]) & set(data['pvr_resis']) )
				self.data_dic[pose]["{}_fraction".format(bs)] = float(len(resis_union)) / float(len(self.bs_resis_lists[bs]))
				resis_atoms_union = ( set(self.bs_resis_atoms_lists[bs]) & set(data['pvr_resis_atoms']) )
				self.data_dic[pose]["{}_atoms_fraction".format(bs)] = float(len(resis_atoms_union)) / float(len(self.bs_resis_atoms_lists[bs]))

	def write_alldata_csv(self):
		fieldnames = ['key', 'lig', 'model', 'E', 'rmsd_lb', 'rmsd_ub', 'pvr_effic', 'pvr_n_contacts', 'torsdof']
		for bs in self.binding_sites_list:
			fieldnames.append("{}_fraction".format(bs))
			fieldnames.append("{}_atoms_fraction".format(bs))

		alldata_csv = "{b_d}{p}/{d}/{d}_alldata.csv".format(
					b_d=base_dir, p=self.parameters['prot'], d=dock)
		with open(alldata_csv, 'w') as csvfile:
			writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
			writer.writeheader()
			for pose, data in self.data_dic.items():
				row = {}
				for f in fieldnames:
					row[f] = data[f]
				writer.writerow(row)

	def save_pickled_data_dic(self):
		self.pickled_data_dic = "{b_d}{p}/{d}/{d}_data_dic.p".format(
					b_d=base_dir, p=self.parameters['prot'], d=dock)
		pickle.dump(self.data_dic, open(self.pickled_data_dic, 'wb'))

	def __init__(self, dock):
		self.dock = dock
		self.load_parameters()
		self.get_ligset_list()
		self.assemble_dic()
		self.get_binding_sites_list()
		self.score_binding_sites()
		self.write_alldata_csv()

def main():
	global base_dir
	base_dir = "/Users/zarek/GitHub/TaylorLab/zvina/"

	d = Docking(dock)
	d.save_pickled_data_dic()

if __name__ == "__main__": main()



