#!/usr/bin/env python

### clusterblah
# (c) Zarek Siegel

from __future__ import print_function
from scipy.stats.stats import pearsonr
from scipy.cluster.vq import vq, kmeans, whiten
from scipy.cluster.hierarchy import linkage
from numpy import array
import csv
from operator import itemgetter
from create_docking_object import * # Docking
from aiad_icpd import * # caclulate_aiad
from write_alldata import get_fieldnames

# Write another CSV that shows the AIAD values between all ligands
def write_all_pose_distances_csv(self):
	if not self.vina_data_mined: self.mine_vina_data()

	self.clustering_csv = "{d_d}/{d}_all_pose_distances.csv".format(d_d=self.dock_dir, d=self.dock)
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

Docking.write_all_pose_distances_csv = write_all_pose_distances_csv

def write_thresholded_csv(self):
# 	print(self.clustering_dic)
	self.clustering_pairs = []

	i = 0
	i_max = (self.n_models * len(self.ligset_list)) ** 2

	memory = {}
	for pose1 in self.poses:
		memory[pose1.key] = {}
		for pose2 in self.poses:
			memory[pose1.key][pose2.key] = False

	for pose1 in self.poses:
		for pose2 in self.poses:
			i += 1
			print(
				"comparing {:<15} and {:>15}, comparison {:<10} of {:>10}".format(
					pose1.key, pose2.key, i, i_max
				)
			)
			entry = [pose1.key, pose2.key, float(self.clustering_dic[pose1.key][pose2.key])]

			if pose1.key != pose2.key and not memory[pose1.key][pose2.key] and not memory[pose2.key][pose1.key]:
				self.clustering_pairs.append(entry)
				memory[pose1.key][pose2.key] = True
				memory[pose2.key][pose1.key] = True

	print(sorted([pair for pair in self.clustering_pairs], reverse=True))
Docking.write_thresholded_csv = write_thresholded_csv

def array(self):
	self.all_poses_array = []
	for pose in self.poses:
		print(pose.key)
		pose.coords_array = []
		for coords in pose.coords:
			pose.coords_array.append([float(c) for c in coords['xyz']])
		self.all_poses_array.append(pose.coords_array)
# 	self.all_poses_array = array(self.all_poses_array)
# 	print((self.all_poses_array))
	linked = linkage(self.all_poses_array)

# 	print(self.clustering_pairs)
# 	print(len(self.clustering_pairs))
# 	calc = ((((self.n_models*len(self.ligset_list))**2) - (self.n_models*len(self.ligset_list)))/2)
# 	print(calc)

# jesse shanahan




# 	source_csv = self.clustering_csv
#
# 	data = []
#
# 	with open(source_csv) as csvfile:
# 		reader = csv.DictReader(csvfile)
# 		for row in reader:
# 	# 		data[row['compared']] = row
# 			data.append(row)
#
# 	groups = {}
# 	groups[data[0]['compared']] = []
#
# 	# for x, y in data.items():
# 	# 	del data[x]['compared']
#
# 	pairs = []
# 	all_keys = []
# 	not_outliers = []
#
# 	threshold = 1
# 	for row in data:
# 		all_keys.append(row['compared'])
# 		for colkey, colvalue in row.items():
# 			try:
# 				if (float(colvalue) < threshold) and ((colkey, row['compared'], colvalue) not in set(pairs)) and (row['compared'] != colkey):
# 					pairs.append((row['compared'], colkey, colvalue))
# 					not_outliers.append(colkey)
# 			except ValueError:
# 				pass
#
# 	pairs12 = []
# 	pairs3 = []
#
# 	self.thresholded_csv = "{d_d}/{d}_clustering_thresholded.csv".format(d_d=self.dock_dir, d=self.dock)
# 	csv_out = self.thresholded_csv
#
# 	fieldnames = ["pose1", "pose2", "aiad"]
# 	with open(csv_out, 'w') as csvfile:
# 		writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
# 		writer.writeheader()
# 		for pair in pairs:
# 			row = {}
# 			row['pose1'] = pair[0]
# 			row['pose2'] = pair[1]
# 			row['aiad'] = pair[2]
# 			writer.writerow(row)
# 			pairs12.append((pair[0], pair[1]))
# 			pairs12.append((pair[2]))
#
# 	print("Total keys in set: {}".format(len(all_keys)))
# 	print("Threshold (angstroms): {}".format(threshold))
# 	print("Number of edges under threshold: {}".format(len(pairs)))
# 	print("{} keys not in output CSV: ".format(len(all_keys) - len(set(not_outliers))), end = '')
# 	for key in all_keys:
# 		if key not in set(not_outliers):
# 			print(key, end = ' ')
# 	print("")

Docking.array = array

def cluster_poses(self):
	self.write_all_pose_distances_csv()
	self.write_thresholded_csv()
	self.array()

Docking.cluster_poses = cluster_poses