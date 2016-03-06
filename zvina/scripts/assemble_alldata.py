#!/usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16

import sys, csv, re, os
import cPickle as pickle
from parse_pdbqt import *
from aiad_icpd import *

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
		self.keys = []
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
					'coords' : pose.coords,
					'lig' : lig,
					'model' : m,
					'pvr_obj' : pose,
					'pdb_address' : re.sub('pdbqt', 'pdb', processed_pdbqt)
				}
				self.data_dic[key] = pose_dic
				self.keys.append(key)

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
		for pose in self.data_dic:
			for bs in self.binding_sites_list:
				resis_union = ( set(self.bs_resis_lists[bs]) & set(self.data_dic[pose]['pvr_resis']) )
				self.data_dic[pose]["{}_fraction".format(bs)] = float(len(resis_union)) / float(len(self.bs_resis_lists[bs]))
				resis_atoms_union = ( set(self.bs_resis_atoms_lists[bs]) & set(self.data_dic[pose]['pvr_resis_atoms']) )
				self.data_dic[pose]["{}_atoms_fraction".format(bs)] = float(len(resis_atoms_union)) / float(len(self.bs_resis_atoms_lists[bs]))

	def aiad_icpd_binding_sites(self):
		for pose in self.data_dic:
			for bs, bso in self.binding_sites_objs.items():
				aiad = caclulate_aiad(self.data_dic[pose]['pvr_obj'], bso)
				self.data_dic[pose]["{}_aiad".format(bs)] = aiad
				icpd = calculate_icpd(self.data_dic[pose]['pvr_obj'], bso)
				self.data_dic[pose]["{}_icpd".format(bs)] = icpd

	def assess_all_resis(self):
		prot_pdbqt = "{b_d}{p}/{p}.pdbqt".format(
					b_d=base_dir, p=self.parameters['prot'])
		self.prot_obj = Pdb(prot_pdbqt)
		self.prot_resis_list = []
# 		self.prot_resis_atoms_list = []
		for atom in self.prot_obj.coords:
			self.prot_resis_list.append("{}{}".format(atom['resn'], atom['resi']))
# 			self.prot_resis_atoms_list.append("{}{}_{}".format(atom['resn'], atom['resi'], atom['atomn']))
		self.prot_resis_list = list(set(self.prot_resis_list))
# 		self.prot_resis_atoms_list = list(set(self.prot_resis_atoms_list))

		for pose in self.data_dic:
			for res in self.prot_resis_list:
				if res in self.data_dic[pose]['pvr_resis']:
					self.data_dic[pose][res] = 1
				else:
					self.data_dic[pose][res] = 0
# 			for atom in self.prot_resis_atoms_list:
# 				if atom in self.data_dic[pose]['pvr_resis_atoms']:
# 					self.data_dic[pose][atom] = 1
# 				else:
# 					self.data_dic[pose][atom] = 0

	def write_alldata_csv(self):
		fieldnames = ['key', 'lig', 'model', 'E', 'rmsd_lb', 'rmsd_ub',
			'pvr_effic', 'pvr_n_contacts', 'torsdof', 'pdb_address']
		for bs in self.binding_sites_list:
			fieldnames.append("{}_fraction".format(bs))
			fieldnames.append("{}_atoms_fraction".format(bs))
			fieldnames.append("{}_aiad".format(bs))
			fieldnames.append("{}_icpd".format(bs))
		for res in self.prot_resis_list: fieldnames.append(res)
# 		for atom in self.prot_resis_atoms_list: fieldnames.append(atom)

		alldata_csv = "{b_d}{p}/{d}/{d}_alldata.csv".format(
					b_d=base_dir, p=self.parameters['prot'], d=dock)
		with open(alldata_csv, 'w') as csvfile:
			writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
			writer.writeheader()
			for pose in self.data_dic:
				row = {}
				for f in fieldnames:
					row[f] = self.data_dic[pose][f]
				writer.writerow(row)
		print("---> Completed alldata.csv is located at:\n{}".format(alldata_csv))

	def cluster_poses(self):
		self.clustering_dic = {}
		for key1 in self.data_dic:
			self.clustering_dic[key1] = {}
			for key2 in self.data_dic:
				aiad12 = caclulate_aiad(self.data_dic[key1]['pvr_obj'], self.data_dic[key2]['pvr_obj'])
				print(key1, key2, aiad12)
				self.clustering_dic[key1][key2] = aiad12

		clustering_csv = "{b_d}{p}/{d}/{d}_clustering.csv".format(
					b_d=base_dir, p=self.parameters['prot'], d=dock)
		with open(clustering_csv, 'w') as csvfile:
			writer = csv.DictWriter(csvfile, fieldnames=self.keys)
			writer.writeheader()
			for key in self.keys:
				row = self.clustering_dic[key]
				writer.writerow(row)
		print("---> Completed clustering.csv is located at:\n{}".format(clustering_csv))

	def save_pickled_docking_obj(self):
		self.pickled_docking_obj = "{b_d}{p}/{d}/{d}.p".format(
					b_d=base_dir, p=self.parameters['prot'], d=dock)
		pickle.dump(self, open(self.pickled_docking_obj, 'wb'))

	def __init__(self, dock):
		self.dock = dock
		self.load_parameters()
		self.get_ligset_list()
		self.assemble_dic()
		self.get_binding_sites_list()
		self.score_binding_sites()
		self.aiad_icpd_binding_sites()
		self.assess_all_resis()

def main():
	global base_dir
	base_dir = "/Users/zarek/GitHub/TaylorLab/zvina/"

	d = Docking(dock)
	d.write_alldata_csv()
	d.cluster_poses()
	d.save_pickled_docking_obj()

if __name__ == "__main__": main()



