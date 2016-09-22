#!/usr/bin/env python

### Mine data from processed vina results, add to data dictionary
# (c) Zarek Siegel

from __future__ import print_function
import re
from constants import *
from operator import itemgetter
from create_docking_object import * # Docking
# from parse_pdb import * # Pdb
from pdb_obj_types import *
from aiad_icpd import *


# Create a list of the binding sites previously prepared for the protein
def get_binding_sites_list(self):
	if not self.vina_data_mined: self.mine_vina_data()

	binding_sites_dir = "{b_d}/binding_sites/{p_f}".format(
		b_d=base_dir, p_f=self.prot_file)

	self.binding_sites_list = []
	self.binding_sites_objs = {}
	for root, dirs, files in os.walk(binding_sites_dir):
		for file in files:
			if re.match(r'^(\w+).pdb$', file):
				bs = re.sub('.pdb', '', file)
				self.binding_sites_list.append(bs)
				# try: self.binding_sites_objs[re.sub('.pdb', '', file)] = Pdb("{}/{}".format(root, file))
				try:
					self.binding_sites_objs[bs] = BindingSite(self, bs)
				except:
					print("! ! ! Error while trying to read PDB for {}".format(file))

	self.bs_resis_lists = {}
	self.bs_resis_atoms_lists = {}

	for bs, bso in self.binding_sites_objs.items():
		bs_resis = []
		if self.evaluate_resis_atoms:
			bs_resis_atoms = []
		for atom in bso.coords:
			bs_resis.append("{}{}".format(atom['resn'], atom['resi']))
			if self.evaluate_resis_atoms:
				bs_resis_atoms.append("{}{}_{}".format(atom['resn'], atom['resi'], atom['atomn']))
		self.bs_resis_lists[bs] = list(set(bs_resis))
		if self.evaluate_resis_atoms:
			self.bs_resis_atoms_lists[bs] = list(set(bs_resis_atoms))

	# print(self.bs_resis_lists)

	self.binding_sites_list_gotten = True
	print("   > Retrieved binding sites")

Docking.get_binding_sites_list = get_binding_sites_list

# Score the binding sites in terms of the residues they contact
#	relative to those contained in the reference PDB
def score_binding_sites(self):
	if not self.vina_data_mined: self.mine_vina_data()
	print("---> Scoring poses against binding sites by ratio of residues contacted...")
	if not self.binding_sites_list_gotten: self.get_binding_sites_list()

	print("   > Scoring binding sites for pose ", end="")
	char_count = 31

# 	for pose in self.keys:
# 		if char_count <= 76:
# 			print(pose, end=" ")
# 			char_count = char_count + len(pose) + 1
# 		else:
# 			print("\n\t{}".format(pose), end = " ")
# 			char_count = len(pose) + 1
#
# 		### Score binding sites using residues detected by process_VinaResult.py
#
# 		# Create a list of binding sites contacted by each pose (see bindsin_ below)
# 		bindsin_list = []
# 		for bs in self.binding_sites_list:
# 			# The intersection between the residues contacted by the ligand
# 			#	and the residues that constitue the binding site
# 			bs_resis_intersection = (
# 				set(self.bs_resis_lists[bs]) & set(self.data_dic[pose]['pvr_resis'])
# 			)
# 			# Fraction of binding site residues contacted
# 			bs_resis_fraction = float(len(bs_resis_intersection)) / float(len(self.bs_resis_lists[bs]))
# 			# Append the fraction to the data dictionary
# 			self.data_dic[pose]["fraction_{}".format(bs)] = bs_resis_fraction
# 			# Append a bindsin_SITE residue based on whether the fraction
# 			#	is at/above a certain threshold (specified in constants.py)
# 			if bs_resis_fraction >= resis_scoring_threshold:
# 				self.data_dic[pose]["bindsin_{}".format(bs)] = 1
# 				bindsin_list.append(bs)
# 			else:
# 				self.data_dic[pose]["bindsin_{}".format(bs)] = 0
# 			# Same can be done for atoms, but not sure if it's all that useful
# 			if self.evaluate_resis_atoms:
# 				bs_resis_atoms_intersection = (
# 					set(self.bs_resis_atoms_lists[bs]) & set(self.data_dic[pose]['pvr_resis_atoms'])
# 				)
# 				bs_resis_atoms_fraction = float(len(bs_resis_atoms_intersection)) / float(len(self.bs_resis_atoms_lists[bs]))
# 				self.data_dic[pose]["fraction_atoms_{}".format(bs)] = bs_resis_atoms_fraction
# 				if bs_resis_atom_fraction >= resis_atoms_scoring_threshold:
# 					self.data_dic[pose]["bindsin_atoms_{}".format(bs)] = 1
# 				else:
# 					self.data_dic[pose]["bindsin_atoms_{}".format(bs)] = 0
# 		self.data_dic[pose]["bindsin_list"] = bindsin_list
# 		bindsin_list_str = str(bindsin_list)
# 		bindsin_list_str = re.sub('[\'|\[|\]|,]', '', bindsin_list_str)
# 		bindsin_list_str = re.sub(' ', ' + ', bindsin_list_str)
# 		self.data_dic[pose]["bindsin_allsites"] = bindsin_list_str

	for pose in self.poses:
		if char_count <= 76:
			print(pose.key, end=" ")
			char_count = char_count + len(pose.key) + 1
		else:
			print("\n\t{}".format(pose.key), end = " ")
			char_count = len(pose.key) + 1

		### Score binding sites using residues detected by process_VinaResult.py

		# Create a list of binding sites contacted by each pose.key (see bindsin_ below)
		bindsin_list = []
		pose.binding_sites = []
		pose.binding_site_fractions = {}
		pose.binds_in = {}
		# (atoms)
		bindsin_atoms_list = []
		pose.binding_sites_atoms = []
		pose.binding_site_atoms_fractions = {}
		pose.binds_in_atoms = {}
		for bs in self.binding_sites_list:
			# The intersection between the residues contacted by the ligand
			#	and the residues that constitue the binding site
			bs_resis_intersection = (
				set(self.bs_resis_lists[bs]) & set(pose.pvr_resis)
			)
			# Fraction of binding site residues contacted
			bs_resis_fraction = float(len(bs_resis_intersection)) / float(len(self.bs_resis_lists[bs]))
			pose.binding_site_fractions[bs] = bs_resis_fraction
			# Append the fraction to the data dictionary
			self.data_dic[pose.key]["fraction_{}".format(bs)] = bs_resis_fraction
			# Append a bindsin_SITE residue based on whether the fraction
			#	is at/above a certain threshold (specified in constants.py)
			if bs_resis_fraction >= resis_scoring_threshold:
				self.data_dic[pose.key]["bindsin_{}".format(bs)] = 1
				pose.binds_in[bs] = True
				bindsin_list.append(bs)
				pose.binding_sites.append(bs)
			else:
				self.data_dic[pose.key]["bindsin_{}".format(bs)] = 0
				pose.binds_in[bs] = False
			# Same can be done for atoms, but not sure if it's all that useful
			if self.evaluate_resis_atoms:
				bs_resis_atoms_intersection = (
					set(self.bs_resis_atoms_lists[bs]) & set(pose.pvr_resis_atoms)
				)
				bs_resis_atoms_fraction = float(len(bs_resis_atoms_intersection)) / float(len(self.bs_resis_atoms_lists[bs]))
				pose.binding_site_atoms_fractions[bs] = bs_resis_atoms_fraction
				self.data_dic[pose.key]["fraction_atoms_{}".format(bs)] = bs_resis_atoms_fraction
				if bs_resis_atom_fraction >= resis_atoms_scoring_threshold:
					self.data_dic[pose.key]["bindsin_atoms_{}".format(bs)] = 1
					pose.binds_in_atoms[bs] = True
					bindsin_atoms_list.append(bs)
					pose.binding_sites_atoms.append(bs)
				else:
					self.data_dic[pose.key]["bindsin_atoms_{}".format(bs)] = 0
					pose.binds_in_atoms.append(bs)
		self.data_dic[pose.key]["bindsin_list"] = bindsin_list
		bindsin_list_str = str(bindsin_list)
		bindsin_list_str = re.sub('[\'|\[|\]|,]', '', bindsin_list_str)
		bindsin_list_str = re.sub(' ', ' + ', bindsin_list_str)
		self.data_dic[pose.key]["bindsin_allsites"] = bindsin_list_str


	self.binding_sites_scored = True
	print("\n   > Done scoring binding sites\n")

Docking.score_binding_sites = score_binding_sites

# Score binding sites by average inter-atomic distance
#	and inter-centerpoint difference
#	Acting via aiad_icpd.py
def aiad_icpd_binding_sites(self):
	if not self.binding_sites_list_gotten: self.get_binding_sites_list()

	print("---> Scoring poses against binding sites by AIAD and ICPD...")
	print("   > Scoring AIAD and ICPD for pose")
	char_count = 31
	for pose in self.poses:
		if pose.model == 1: message = "\n\t> {} #1 ".format(pose.lig)
		else: message = str(pose.model)
		# if char_count <= 76:
		# 	print(pose.key, end=" ")
		# 	char_count = char_count + len(pose.key) + 1
		# else:
		# 	print("\n\t{}".format(pose.key), end = " ")
		# 	char_count = len(pose.key) + 1
		if char_count <= 76:
			print(message, end=" ")
			char_count = 0
		else:
			print("\n\t{}".format(message), end = " ")
		char_count += len(message) + 1

		for bs, bso in self.binding_sites_objs.items():
			aiad = caclulate_aiad(pose, bso)
			self.data_dic[pose.key]["aiad_{}".format(bs)] = aiad
			icpd = calculate_icpd(pose, bso)
			self.data_dic[pose.key]["icpd_{}".format(bs)] = icpd

	self.aiad_icpd_calcd = True
	print("\n   > Done calculating AIAD and ICPD for binding sites\n")

Docking.aiad_icpd_binding_sites = aiad_icpd_binding_sites

# Add attributes for whether the ligand contacts each residue of the protein
def assess_all_resis(self):
	if not self.vina_data_mined: self.mine_vina_data()

	print("---> Evaluating residues contacted for each pose")
	self.prot_pdbqt = "{p_d}/{p_f}.pdbqt".format(p_d=self.prot_dir, p_f=self.prot_file)
	try: self.prot_obj = Pdb(self.prot_pdbqt)
	except: print("! ! ! Error while trying to read PDB for {}".format(file))
	self.prot_resis_list = []
	if self.evaluate_resis_atoms:
		self.prot_resis_atoms_list = []
	for atom in self.prot_obj.coords:
		self.prot_resis_list.append((atom['resn'], atom['resi']))
		if self.evaluate_resis_atoms:
			self.prot_resis_atoms_list.append((atom['resn'], atom['resi'], atom['atomn']))
		# self.prot_resis_list.append("{}{}".format(atom['resn'], atom['resi']))
		# self.prot_resis_atoms_list.append("{}{}_{}".format(atom['resn'], atom['resi'], atom['atomn']))
	self.prot_resis_list = list(set(self.prot_resis_list))
	self.prot_resis_list = sorted(self.prot_resis_list, key=itemgetter(1))
	self.prot_resis_list = ["{}{}".format(r[0], r[1]) for r in self.prot_resis_list]
	if self.evaluate_resis_atoms:
		self.prot_resis_atoms_list = list(set(self.prot_resis_atoms_list))
		self.prot_resis_atoms_list = sorted(self.prot_resis_atoms_list, key=itemgetter(1,2))
		self.prot_resis_atoms_list = ["{}{}_{}".format(r[0], r[1], r[2]) for r in self.prot_resis_atoms_list]
		# self.prot_resis_atoms_list = list(set(self.prot_resis_atoms_list))

	for pose in self.data_dic:
		for res in self.prot_resis_list:
			if res in self.data_dic[pose]['pvr_resis']:
				self.data_dic[pose][res] = 1
			else:
				self.data_dic[pose][res] = 0
		if self.evaluate_resis_atoms:
			for atom in self.prot_resis_atoms_list:
				if atom in self.data_dic[pose]['pvr_resis_atoms']:
					self.data_dic[pose][atom] = 1
				else:
					self.data_dic[pose][atom] = 0

	self.all_resis_assessed = True
	print("   > Residues contacted added to data dictionary\n")

Docking.assess_all_resis = assess_all_resis

