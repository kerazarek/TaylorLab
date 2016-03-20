#!/usr/bin/env python

### Mine data from processed vina results, add to data dictionary
# (c) Zarek Siegel

from __future__ import print_function
import re
from operator import itemgetter
from create_docking_object import * # Docking
from parse_pdb import * # Pdb
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
			self.binding_sites_list.append(re.sub('.pdb', '', file))
			try: self.binding_sites_objs[re.sub('.pdb', '', file)] = Pdb("{}/{}".format(root, file))
			except: print("! ! ! Error while trying to read PDB for {}".format(file))

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
	for pose in self.keys:
		if char_count <= 76:
			print(pose, end=" ")
			char_count = char_count + len(pose) + 1
		else:
			print("\n\t{}".format(pose), end = " ")
			char_count = len(pose) + 1
		for bs in self.binding_sites_list:
			resis_union = ( set(self.bs_resis_lists[bs]) & set(self.data_dic[pose]['pvr_resis']) )
			self.data_dic[pose]["{}_fraction".format(bs)] = float(len(resis_union)) / float(len(self.bs_resis_lists[bs]))
			if self.evaluate_resis_atoms:
				resis_atoms_union = ( set(self.bs_resis_atoms_lists[bs]) & set(self.data_dic[pose]['pvr_resis_atoms']) )
				self.data_dic[pose]["{}_atoms_fraction".format(bs)] = float(len(resis_atoms_union)) / float(len(self.bs_resis_atoms_lists[bs]))

	self.binding_sites_scored = True
	print("\n   > Done scoring binding sites\n")

Docking.score_binding_sites = score_binding_sites

# Score binding sites by average inter-atomic distance
#	and inter-centerpoint difference
#	Acting via aiad_icpd.py
def aiad_icpd_binding_sites(self):
	if not self.binding_sites_list_gotten: self.get_binding_sites_list()

	print("---> Scoring poses against binding sites by AIAD and ICPD...")
	print("   > Scoring AIAD and ICPD for pose ", end="")
	char_count = 31
	for pose in self.keys:
		if char_count <= 76:
			print(pose, end=" ")
			char_count = char_count + len(pose) + 1
		else:
			print("\n\t{}".format(pose), end = " ")
			char_count = len(pose) + 1
		for bs, bso in self.binding_sites_objs.items():
			aiad = caclulate_aiad(self.data_dic[pose]['pvr_obj'], bso)
			self.data_dic[pose]["{}_aiad".format(bs)] = aiad
			icpd = calculate_icpd(self.data_dic[pose]['pvr_obj'], bso)
			self.data_dic[pose]["{}_icpd".format(bs)] = icpd

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

