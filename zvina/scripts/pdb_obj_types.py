#!/usr/bin/env python

### P
# (c) Zarek Siegel
# v1 3/22/16

from parse_pdb import * # Pdb, Residue
from constants import *

class DockingPdb(Pdb):
	def get_docking_properties(self):
		self.dock = self.docking_obj.dock
		self.prot = self.docking_obj.prot
		self.prot_file = self.docking_obj.prot_file
		self.ligset = self.docking_obj.ligset
		self.box = self.docking_obj.box
		self.exhaust = self.docking_obj.exhaust
		self.n_models = self.docking_obj.n_models
		self.n_cpus = self.docking_obj.n_cpus
		self.box_center_x = self.docking_obj.box_center_x
		self.box_center_y = self.docking_obj.box_center_y
		self.box_center_z = self.docking_obj.box_center_z
		self.box_size_x = self.docking_obj.box_size_x
		self.box_size_y = self.docking_obj.box_size_y
		self.box_size_z = self.docking_obj.box_size_z
		self.ligset_list_str = self.docking_obj.ligset_list_str
		self.notes = self.docking_obj.notes
		self.date = self.docking_obj.date
		self.box_notes = self.docking_obj.box_notes
		self.dock_dir = self.docking_obj.dock_dir
		self.prot_dir = self.docking_obj.prot_dir

# Pose.get_docking_properties = get_docking_properties
# BindingSite.get_docking_properties = get_docking_properties
# Protein.get_docking_properties = get_docking_properties

class Pose(DockingPdb):
	def __init__(self, docking_obj, lig, model):
		self.docking_obj = docking_obj
		self.lig = lig
		self.model = model

		self.get_docking_properties()

		self.key = "{}_{}_m{}".format(self.dock, self.lig, self.model)
		self.processed_pdbqt = "{d_d}/processed_pdbqts/{key}.pdbqt".format(
			d_d=self.dock_dir, key=self.key)

		# print("{:<20}: {}".format("docking_obj", self.docking_obj))
		# print("{:<20}: {}".format("lig", self.lig))
		# print("{:<20}: {}".format("model", self.model))
		# print("{:<20}: {}".format("key", self.key))
		# print("{:<20}: {}".format("processed_pdbqt", self.processed_pdbqt))

		Pdb.__init__(self, self.processed_pdbqt)


class BindingSite(DockingPdb):
	def __init__(self, docking_obj, binding_site):
		self.docking_obj = docking_obj
		self.binding_site = binding_site
		self.name = binding_site

		self.get_docking_properties()

		self.binding_sites_dir = "{}/binding_sites".format(base_dir)
		self.binding_site_pdb = "{}/{}/{}.pdb".format(
			self.binding_sites_dir, self.prot_file, self.name
		)

# 		print(self.binding_site_pdb)
		Pdb.__init__(self, self.binding_site_pdb)



# class Protein(Pdb):