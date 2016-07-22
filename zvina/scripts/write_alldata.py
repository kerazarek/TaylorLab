#!/usr/bin/env python

### Output all the data mined and analyzed into a CSV file
# (c) Zarek Siegel

import os, sys
# import cPickle as pickle
import pickle
from create_docking_object import * # Docking

def get_fieldnames(self):
	# Determine which headers to write to the CSV

	# Choose from these groups
	self.alldata_fieldnames = ['key', 'lig', 'model'] # basics
# 	energies_properties_fieldnames = self.energies_dic.keys() + self.properties_dic.keys()

	if self.vina_data_mined:
		pvr_fieldnames = ['E', 'rmsd_lb', 'rmsd_ub', 'pvr_effic',
			'pvr_n_contacts', 'torsdof', 'pdbqt_address', 'pdb_address'] # (processed vina results)
		self.alldata_fieldnames = self.alldata_fieldnames + pvr_fieldnames

	if self.energies_props_gotten:
		energies_properties_fieldnames = [
			'total_bond_stretching_energy', 'total_angle_bending_energy',
			'total_torsional_energy', 'total_energy',
			'name', 'formula', 'mol_weight', 'exact_mass', 'canonical_SMILES',
			'num_atoms', 'num_bonds', 'num_rings', 'logP', 'PSA', 'MR'
		]
		self.alldata_fieldnames = self.alldata_fieldnames + energies_properties_fieldnames

	if self.binding_sites_scored:
		binding_site_fieldnames = []
		for bs in self.binding_sites_list:
			binding_site_fieldnames.append("{}_fraction".format(bs))
			binding_site_fieldnames.append("{}_atoms_fraction".format(bs))
		self.alldata_fieldnames = self.alldata_fieldnames + binding_site_fieldnames

	if self.aiad_icpd_calcd:
		aiad_icpd_fieldnames = []
		for bs in self.binding_sites_list:
			aiad_icpd_fieldnames.append("{}_aiad".format(bs))
			aiad_icpd_fieldnames.append("{}_icpd".format(bs))
		self.alldata_fieldnames = self.alldata_fieldnames + aiad_icpd_fieldnames

	if self.all_resis_assessed:
		self.alldata_fieldnames = self.alldata_fieldnames + self.prot_resis_list
		if self.evaluate_resis_atoms:
			self.alldata_fieldnames = self.alldata_fieldnames + self.prot_resis_atoms_list

Docking.get_fieldnames = get_fieldnames

def write_alldata_csv(self):
	self.alldata_csv = "{d_d}/{d}_alldata.csv".format(d_d=self.dock_dir, d=self.dock)

	# If the CSV already exists, ask to overwrite
	if os.path.isfile(self.alldata_csv):
		print(">>>> Docking CSV file already exists at")
		print("\t{}".format(self.alldata_csv))
		overwrite = raw_input("\n\t>>>> Enter 'y' or enter to overwrite, 'n' to exit: ")
		if overwrite == "y" or \
		   overwrite == "yes" or \
		   overwrite == "Y" or \
		   overwrite == "Yes" or \
		   overwrite == "":
			subprocess.call(["rm", "-f", self.alldata_csv])
			print("")
		else: sys.exit("\n\t> OK, exiting this script\n")

	self.get_fieldnames()

	print("---> Writing alldata.csv...")
	with open(self.alldata_csv, 'w') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames=self.alldata_fieldnames)
		writer.writeheader()
		for key in self.keys:
			row = {}
			for f in self.alldata_fieldnames:
				try: row[f] = self.data_dic[key][f]
				except KeyError:
					print("! ! ! KeyError while trying to write {}".format(f))
					row[f] = "!Err!"
			writer.writerow(row)

	self.is_csv_written = True
	print("   > Completed alldata.csv is located at:\n\t{}\n".format(self.alldata_csv))

Docking.write_alldata_csv = write_alldata_csv

# Save the data dictionary as a pickled file (i.e. in native python format)
def write_docking_pickled(self):
	self.docking_obj_pickled = "{d_d}/{d}.p".format(d_d=self.dock_dir, d=self.dock)

	# If the pickled dictionary already exists, ask to overwrite
	if os.path.isfile(self.docking_obj_pickled):
		print(">>>> Pickled docking object file already exists at")
		print("\t{}".format(self.docking_obj_pickled))
		overwrite = raw_input("\n\t>>>> Enter 'y' or enter to overwrite, 'n' to exit: ")
		if overwrite == "y" or \
		   overwrite == "yes" or \
		   overwrite == "Y" or \
		   overwrite == "Yes" or \
		   overwrite == "":
			subprocess.call(["rm", "-f", self.docking_obj_pickled])
			print("")
		else: sys.exit("\n\t> OK, exiting this script\n")

	print("---> Pickling docking object...")
	pickle.dump(self, open(self.docking_obj_pickled, 'wb'))

	self.is_pickled = True
	print("   > Pickled docking object located at:\n\t{}\n".format(self.docking_obj_pickled))

Docking.write_docking_pickled = write_docking_pickled











