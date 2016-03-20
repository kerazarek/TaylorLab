#!/usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16 (as assemble_alldata.py)
# v2 3/6/16

from __future__ import print_function
import csv, re, os, subprocess
from constants import *
from parse_pdb import *
from aiad_icpd import *
from create_docking_object import Docking
import energies_properties


### AFTER DOCKING

# Get energies and properties
def get_lig_energies_properties(self):
	if not self.is_assembled: self.create_dic()

	print("---> Creating energies_properties_dic")
	print("\t> Processing pose:")
	self.energies_properties_dic = {}
	for lig in self.ligset_list:
		for m in range(1, self.n_models + 1):
			key = "{}_{}_m{}".format(self.dock, lig, m)
			processed_pdbqt = "{d_d}/processed_pdbqts/{key}.pdbqt".format(
				d_d=self.dock_dir, key=key)
			energies = energies_properties.get_lig_energies(processed_pdbqt)
			properties = energies_properties.get_lig_properties(processed_pdbqt)
			self.energies_properties_dic[key] = dict(energies.items() + properties.items())
			print(self.energies_properties_dic[key])
			print("\t\t{}".format(key))

# 		for lig in self.ligset_list:
# 			first_key_processed_pdbqt = "{d_d}/processed_pdbqts/{d}_{l}_m1.pdbqt".format(
# 					d_d=self.dock_dir, d=self.dock, l=lig)
# 			energies = energies_properties.get_lig_energies(first_key_processed_pdbqt)
# 			properties = energies_properties.get_lig_properties(first_key_processed_pdbqt)
# 			self.energies_properties_dic[lig] = dict(energies.items() + properties.items())
# 			print(lig, end=" ")
# 		print(self.energies_properties_dic)
	print("\t> Done ")

	for key in self.data_dic:
		for lig, ep in self.energies_properties_dic.items():
			self.data_dic[key] = dict(self.data_dic[key].items() + ep.items())

	self.energies_props_gotten = True

Docking.get_lig_energies_properties = get_lig_energies_properties


# Write only energies and properties CSV
def write_energies_properties_csv(self):
	self.create_dic()
	self.get_lig_energies_properties()

	energies_properties_fieldnames = self.energies_properties_dic[self.ligset_list[0]].keys()
	fieldnames = ['lig'] + energies_properties_fieldnames

	self.energies_properties_csv = "{d_d}/{d}_energies_properties.csv".format(
		d_d=self.dock_dir, d=self.dock)

	with open(self.energies_properties_csv, 'w') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
		writer.writeheader()
		for key in self.keys:
			row = {}
			for f in fieldnames:
				row[f] = self.data_dic[key][f]
			writer.writerow(row)
# 		with open(self.energies_properties_csv, 'w') as csvfile:
# 			writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
# 			writer.writeheader()
# 			for lig, data in self.energies_properties_dic.items():
# # 				print(data)
# 				row = dict({'lig':lig}.items() + data.items())
# # 				for f in fieldnames:
# # 					row[f] = self.data_dic[pose][f]
# 				writer.writerow(row)

	print("---> Completed energies_properties.csv is located at:\n\t{}".format(self.energies_properties_csv))

Docking.write_energies_properties_csv = write_energies_properties_csv

# Write another CSV that shows the AIAD values between all ligands
def cluster_poses(self):
	if not self.is_assembled: self.assemble_dic()

	self.clustering_csv = "{d_d}/{d}_clustering.csv".format(d_d=self.dock_dir, d=self.dock)
	self.clustering_dic = {}

	# If the CSV already exists, read it in as a dictionary
	if os.path.isfile(self.clustering_csv):
		with open(self.clustering_csv) as f:
			reader = csv.DictReader(f)
			for row in reader:
				key = row['compared']
				del row['compared']
				self.clustering_dic[key] = row
	# If it doesn't, write it
	else:
		c = 0
		print("---> Calculating AIAD between poses (for clustering)... ")
		for key1 in self.data_dic:
			self.clustering_dic[key1] = {}
			c += 1
			print("\t- calculated for {:25}{:<9}of{:>9}".format(key1,c,len(self.keys)))
			for key2 in self.data_dic:
				aiad12 = caclulate_aiad(self.data_dic[key1]['pvr_obj'], self.data_dic[key2]['pvr_obj'])
				self.clustering_dic[key1][key2] = aiad12

		fieldnames = ['compared'] + self.keys
		with open(self.clustering_csv, 'w') as csvfile:
			writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
			writer.writeheader()
			for key in self.keys:
				row = self.clustering_dic[key]
				row['compared'] = key
				writer.writerow(row)

	self.are_poses_clustered = True
	print("   > Completed clustering.csv is located at:\n\t{}\n".format(self.clustering_csv))

Docking.cluster_poses = cluster_poses





		# WOOOT!










