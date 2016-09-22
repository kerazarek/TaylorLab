#!/usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16 (as assemble_alldata.py)
# v2 3/6/16

from __future__ import print_function
import csv, re, os, subprocess
from constants import *

### A class for docking data, for sourcing, reading, and analyzing
class Docking():
	# Basic docking parameters are contained in CSV file in .../base/parameters_csvs/
	def load_parameters(self):
		# Basic docking parameters are stored in base_dir/Dockings.csv
		dockings_csv = "{}/Dockings.csv".format(base_dir)
		with open(dockings_csv) as f:
			reader = csv.DictReader(f)
			for row in reader:
				if row['Docking ID'] == self.dock:
					self.dockings_csv_row = row
		# Source the parameters as class attributes
		self.prot = self.dockings_csv_row['Protein']
		self.prot_file = self.dockings_csv_row['Protein File']
		self.ligset = self.dockings_csv_row['Ligset']
		self.box = self.dockings_csv_row['Gridbox']
		self.exhaust = self.dockings_csv_row['Exhaustiveness']
		self.n_models = int(self.dockings_csv_row['Number of Models'])
		self.n_cpus = self.dockings_csv_row['Number of CPUs']
		self.notes = self.dockings_csv_row['Notes']
		self.date = self.dockings_csv_row['Date']

		# Grid box parameters are stored in base_dir/Gridboxes.csv
		gridboxes_csv = "{}/Gridboxes.csv".format(base_dir)
		with open(gridboxes_csv) as f:
			reader = csv.DictReader(f)
			for row in reader:
				if row['Gridbox Name'] == self.box and row['Protein File'] == self.prot_file:
					self.gridboxes_csv_row = row

		# Source the grid box parameters as class attributes
		self.box_center_x = self.gridboxes_csv_row['Center in x-dimension']
		self.box_center_y = self.gridboxes_csv_row['Center in y-dimension']
		self.box_center_z = self.gridboxes_csv_row['Center in z-dimension']
		self.box_size_x = self.gridboxes_csv_row['Size in x-dimension']
		self.box_size_y = self.gridboxes_csv_row['Size in y-dimension']
		self.box_size_z = self.gridboxes_csv_row['Size in z-dimension']
		self.box_notes = self.gridboxes_csv_row['Notes']

		# Some useful directories
		self.prot_dir = "{b_d}/{p}".format(b_d=base_dir, p=self.prot)
		self.dock_dir = "{b_d}/{p}/{d}".format(b_d=base_dir, p=self.prot, d=self.dock)

		self.parameters_loaded = True
		print("   > Loaded docking parameters")

	# Retrieve the list of ligands in the set
	def get_ligset_list(self):
		# If there is a ligset text file; source it;
		#	else write it by looking at the files in LIGSET/pdbqts
		self.ligset_list_txt = "{b_d}/ligsets/{ls}/{ls}_list.txt".format(
			b_d=base_dir,ls=self.ligset)
		if os.path.isfile(self.ligset_list_txt):
			with open(self.ligset_list_txt, 'r') as f:
				self.ligset_list = f.read().splitlines()
			print("   > Ligset list sourced from .../{ls}/{ls}_list.txt".format(
				ls=self.ligset))
		else:
			self.ligset_dir = "{b_d}/ligsets/{ls}/pdbqts".format(
				b_d=base_dir,ls=self.ligset)
			self.ligset_list = subprocess.Popen(["ls", self.ligset_dir], stdout=subprocess.PIPE)
			self.ligset_list = self.ligset_list.communicate()[0]
			self.ligset_list = re.sub('.pdbqt', '', self.ligset_list)
			self.ligset_list = re.split('\n', self.ligset_list)
			for l in self.ligset_list:
				if l == '' or l == ' ':
					self.ligset_list.remove(l)
			print(("   > Ligset list sourced by looking at files in .../{ls}/pdbqts\n"
				   "         and saved as .../{ls}/{ls}_list.txt".format(ls=self.ligset)))
			with open(self.ligset_list_txt, 'w') as f:
				for l in self.ligset_list:
					f.write("{}\n".format(l))
		self.ligset_list_str = str(self.ligset_list)
		self.ligset_list_str = re.sub('[\'|\[|\]|,]', '', self.ligset_list_str)

		self.ligset_list_gotten = True
		print("   > Retrieved ligset list")

	#Create blank alldata dictionary
	def create_data_dic(self):
		self.data_dic = {}
		# self.keys = []
		for lig in self.ligset_list:
			for m in range(1, self.n_models + 1):
				key = "{}_{}_m{}".format(self.dock, lig, m)
				self.data_dic[key] = {
					'key' : key,
					'lig' : lig,
					'model' : m
				}
				# self.keys.append(key)

		self.is_data_dic_created = True
		print("   > Created empty data dictionary")

	def print_parameters(self):
		print("dock=\'{}\'".format(self.dock))
		print("prot=\'{}\'".format(self.prot))
		print("prot_file=\'{}\'".format(self.prot_file))
		print("ligset=\'{}\'".format(self.ligset))
		print("box=\'{}\'".format(self.box))
		print("exhaust={}".format(self.exhaust))
		print("n_models={}".format(self.n_models))
		print("n_cpus={}".format(self.n_cpus))
		print("box_center_x={}".format(self.box_center_x))
		print("box_center_y={}".format(self.box_center_y))
		print("box_center_z={}".format(self.box_center_z))
		print("box_size_x={}".format(self.box_size_x))
		print("box_size_y={}".format(self.box_size_y))
		print("box_size_z={}".format(self.box_size_z))
		print("ligset_list=\'{}\'".format(self.ligset_list_str))
		print("notes=\'{}\'".format(self.notes))
		print("date={}".format(self.date))
		print("box_notes=\'{}\'".format(self.box_notes))

	def export_parameters_to_environment(self):
		os.environ['dock'] = "{}".format(self.dock)
		os.environ['prot'] = "{}".format(self.prot)
		os.environ['prot_file'] = "{}".format(self.prot_file)
		os.environ['ligset'] = "{}".format(self.ligset)
		os.environ['box'] = "{}".format(self.box)
		os.environ['exhaust'] = "{}".format(self.exhaust)
		os.environ['n_models'] = "{}".format(self.n_models)
		os.environ['n_cpus'] = "{}".format(self.n_cpus)
		os.environ['box_center_x'] = "{}".format(self.box_center_x)
		os.environ['box_center_y'] = "{}".format(self.box_center_y)
		os.environ['box_center_z'] = "{}".format(self.box_center_z)
		os.environ['box_size_x'] = "{}".format(self.box_size_x)
		os.environ['box_size_y'] = "{}".format(self.box_size_y)
		os.environ['box_size_z'] = "{}".format(self.box_size_z)
		os.environ['ligset_list'] = "{}".format(self.ligset_list_str)
		os.environ['notes'] = "{}".format(self.notes)
		os.environ['date'] = "{}".format(self.date)
		os.environ['box_notes'] = "{}".format(self.box_notes)

		self.parameters_exported_to_environment = True
		print("   > Exported parameters to shell environment")


	def set_recordkeeping_parameters(self):
		self.parameters_loaded = False
		self.ligset_list_gotten = False
		self.parameters_exported_to_environment = False
		self.is_data_dic_created = False

		self.vina_data_mined = False
		self.binding_sites_list_gotten = False
		self.binding_sites_scored = False
		self.aiad_icpd_calcd = False
		self.all_resis_assessed = False
		self.is_summary_written = False

		self.is_csv_written = False
		self.energies_props_gotten = False
		self.are_poses_clustered = False
		self.is_pickled = False

	def __init__(self, d):
		self.dock = d

		print("---> Creating docking object for docking {}...".format(self.dock))

		self.set_recordkeeping_parameters()
		self.load_parameters()
		self.get_ligset_list()
		self.create_data_dic()

		print("")


