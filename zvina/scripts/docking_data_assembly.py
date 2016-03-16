#!/usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16 (as assemble_alldata.py)
# v2 3/6/16

from __future__ import print_function
import csv, re, os, subprocess
import cPickle as pickle
from constants import *
from parse_pdb import *
from aiad_icpd import *

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

		# Some useful directories
		self.prot_dir = "{b_d}/{p}".format(b_d=base_dir, p=self.prot)
		self.dock_dir = "{b_d}/{p}/{d}".format(b_d=base_dir, p=self.prot, d=self.dock)

		print("---> Loaded docking parameters")

	# Retrieve the list of ligands in the set
	def get_ligset_list(self):
		ligset_list_txt = "{b_d}/ligsets/{ls}/{ls}_list.txt".format(
			b_d=base_dir,ls=self.ligset)
		ligset_list_txt_open = open(ligset_list_txt, 'r')
		with ligset_list_txt_open as f:
			self.ligset_list = f.read().splitlines()
		print("---> Retrieved ligset list")

	# Write the script for submission of vina jobs on the cluster
	def write_vina_submit(self):
		template =  "#BSUB -q hp12\n\
#BSUB -n {n_cpus}\n\
#BSUB -J vina_{subdock}\n\
\n\
# Text file with list of ligands (one on each line)\n\
ligset_list_txt={cluster_base_dir}/ligsets/{ligset}/{ligset}_list.txt\n\
\n\
# Create the docking and output directories\n\
mkdir {cluster_base_dir}/{prot}/{dock}/\n\
mkdir {cluster_base_dir}/{prot}/{dock}/result_pdbqts\n\
\n\
# Generate the list of ligands\n\
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)\n\
\n\
# Vina command\n\
for lig in $ligset_list; do\n\
	/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \\\n\
	--receptor {cluster_base_dir}/{prot}/{prot_file}.pdbqt \\\n\
	--ligand {cluster_base_dir}/ligsets/{ligset}/pdbqts/$lig.pdbqt \\\n\
	--out {cluster_base_dir}/{prot}/{dock}/result_pdbqts/{subdock}_$lig\_results.pdbqt \\\n\
	--center_x {box_center_x} \\\n\
	--center_y {box_center_y} \\\n\
	--center_z {box_center_z} \\\n\
	--size_x {box_size_x} \\\n\
	--size_y {box_size_y} \\\n\
	--size_z {box_size_z} \\\n\
	--cpu {n_cpus} \\\n\
	--num_modes {n_models} \\\n\
	--exhaustiveness {exhaust}\n\
done".format(
			cluster_base_dir = cluster_base_dir,
			n_cpus = self.n_cpus,
			prot = self.prot,
			prot_file = self.prot_file,
			ligset = self.ligset,
			box_center_x = self.box_center_x,
			box_center_y = self.box_center_y,
			box_center_z = self.box_center_z,
			box_size_x = self.box_size_x,
			box_size_y = self.box_size_y,
			box_size_z = self.box_size_z,
			exhaust = self.exhaust,
			n_models = '{n_models}',
			dock = '{dock}',
			subdock = '{subdock}'
		)
		# (no need for batch submission)
		if self.n_models <= 20:
			template_filled = template.format(
				n_models = self.n_models, dock = self.dock, subdock = self.dock)
			vina_submit_sh = "{b_d}/vina_submit_shs/vina_submit_{d}.sh".format(
				b_d=base_dir, d=dock)
			with open(vina_submit_sh, 'w') as f:
				f.write(template_filled)
			print("---> Vina submission script for docking {} has been created. It can be found at:".format(dock))
			print("\t{}".format(vina_submit_sh))
		# (batch submission)
		elif self.n_models > 20:
			vina_submits_dir = "{b_d}/vina_submit_shs/vina_submits_{d}/".format(
				b_d=base_dir, d=dock)
			subprocess.call(['mkdir', vina_submits_dir])
			n_batches = self.n_models / 20
			for b in range(1, n_batches + 1):
				subdock = "{d}.{b}".format(d = dock, b = b)
				template_filled = template.format(
					n_models = 20, dock = self.dock, subdock = subdock)
				vina_submit_sh = "{v_s_d}/vina_submit_{sd}.sh".format(
					v_s_d = vina_submits_dir, sd = subdock)
				with open(vina_submit_sh, 'w') as f:
					f.write(template_filled)
			print("---> Vina submission scripts for docking h11 have been created. They can be found in:")
			print("\t{}".format(vina_submits_dir))
		else: print("! ! ! bad n_models")

	### AFTER DOCKING

	# Mine Vina result for data (actual mining is in parse_pdb.py, acting via the Pdb class)
	def assemble_dic(self):
		self.data_dic = {}
		self.keys = []
		for lig in self.ligset_list:
			for m in range(1, self.n_models + 1):
				key = "{}_{}_m{}".format(dock, lig, m)
				processed_pdbqt = "{d_d}/processed_pdbqts/{key}.pdbqt".format(
					d_d=self.dock_dir, key=key)
				if os.path.isfile(processed_pdbqt):
					try: pose = Pdb(processed_pdbqt)
					except: print("! ! ! Error while trying to read PDB for {}".format(key))
					try:
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
					except AttributeError:
						print("! ! ! pose {} failed, check for the processed PDBQT".format(key))
				else: print("! ! ! processed_pdbqt does not exist for {}".format(key))

				self.data_dic[key] = pose_dic
				self.keys.append(key)
		self.is_assembled = True
		print("---> Data dictionary created with data from process_VinaResult.py")

	# Create a list of the binding sites previously prepared for the protein
	def get_binding_sites_list(self):
		if not self.is_assembled: self.assemble_dic()

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
			bs_resis_atoms = []
			for atom in bso.coords:
				bs_resis.append("{}{}".format(atom['resn'], atom['resi']))
				bs_resis_atoms.append("{}{}_{}".format(atom['resn'], atom['resi'], atom['atomn']))
			self.bs_resis_lists[bs] = list(set(bs_resis))
			self.bs_resis_atoms_lists[bs] = list(set(bs_resis_atoms))

		self.is_bs_listed = True
		print("---> Retrieved binding sites\n")

	# Score the binding sites in terms of the residues they contact
	#	relative to those contained in the reference PDB
	def score_binding_sites(self):
		if not self.is_assembled: self.assemble_dic()
		if not self.is_bs_listed: self.get_binding_sites_list()

		print("...Scoring binding sites for ", end="")
		for pose in self.data_dic:
			print("{} ".format(pose), end="")
			for bs in self.binding_sites_list:
				resis_union = ( set(self.bs_resis_lists[bs]) & set(self.data_dic[pose]['pvr_resis']) )
				self.data_dic[pose]["{}_fraction".format(bs)] = float(len(resis_union)) / float(len(self.bs_resis_lists[bs]))
				resis_atoms_union = ( set(self.bs_resis_atoms_lists[bs]) & set(self.data_dic[pose]['pvr_resis_atoms']) )
				self.data_dic[pose]["{}_atoms_fraction".format(bs)] = float(len(resis_atoms_union)) / float(len(self.bs_resis_atoms_lists[bs]))

		self.is_bs_scored = True
		print("\n---> Scored binding sites\n")

	# Score binding sites by average inter-atomic distance
	#	and inter-centerpoint difference
	#	Acting via aiad_icpd.py
	def aiad_icpd_binding_sites(self):
		if not self.is_assembled: self.assemble_dic()

		print("...Scoring AIAD and ICPD for ", end="")
		for pose in self.data_dic:
			print("{} ".format(pose), end="")
			for bs, bso in self.binding_sites_objs.items():
				aiad = caclulate_aiad(self.data_dic[pose]['pvr_obj'], bso)
				self.data_dic[pose]["{}_aiad".format(bs)] = aiad
				icpd = calculate_icpd(self.data_dic[pose]['pvr_obj'], bso)
				self.data_dic[pose]["{}_icpd".format(bs)] = icpd

		self.are_aiad_icpd_calcd = True
		print("\n---> Calculated AIAD and ICPD\n")

	# Add attributes for whether the ligand contacts each residue of the protein
	def assess_all_resis(self):
		if not self.is_assembled: self.assemble_dic()

		self.prot_pdbqt = "{p_d}/{p_f}.pdbqt".format(p_d=self.prot_dir, p_f=self.prot_file)
		try: self.prot_obj = Pdb(self.prot_pdbqt)
		except: print("! ! ! Error while trying to read PDB for {}".format(file))
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

		self.are_all_resis_assessed = True
		print("---> Residues contacts added to data dictionary")

	# Output all the data mined and analyzed into a CSV file
	def write_alldata_csv(self):
		self.alldata_csv = "{d_d}/{d}_alldata.csv".format(d_d=self.dock_dir, d=dock)

		# If the CSV already exists, read it in as a dictionary
		if os.path.isfile(self.alldata_csv):
			with open(self.alldata_csv) as f:
				reader = csv.DictReader(f)
				self.data_dic = {}
				for row in reader:
					self.data_dic[row['key']] = row
		# If it doesn't, write it
		else:
			if not self.is_assembled: self.assemble_dic()
			if not self.is_bs_listed: self.get_binding_sites_list()
			if not self.is_bs_scored: self.score_binding_sites()
			if not self.are_aiad_icpd_calcd: self.aiad_icpd_binding_sites()
			if not self.are_all_resis_assessed: self.assess_all_resis()

			fieldnames = ['key', 'lig', 'model', 'E', 'rmsd_lb', 'rmsd_ub',
				'pvr_effic', 'pvr_n_contacts', 'torsdof', 'pdb_address']
			for bs in self.binding_sites_list:
				fieldnames.append("{}_fraction".format(bs))
				fieldnames.append("{}_atoms_fraction".format(bs))
				fieldnames.append("{}_aiad".format(bs))
				fieldnames.append("{}_icpd".format(bs))
			for res in self.prot_resis_list: fieldnames.append(res)
			# for atom in self.prot_resis_atoms_list: fieldnames.append(atom)

			with open(self.alldata_csv, 'w') as csvfile:
				writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
				writer.writeheader()
				for pose in self.data_dic:
					row = {}
					for f in fieldnames:
						try: row[f] = self.data_dic[pose][f]
						except KeyError:
							print("! ! ! KeyError while trying to write {}".format(f))
							row[f] = "!Err!"
					writer.writerow(row)

		self.is_csv_written = True
		print("---> Completed alldata.csv is located at:\n\t{}".format(self.alldata_csv))

	# Write another CSV that shows the AIAD values between all ligands
	def cluster_poses(self):
		if not self.is_assembled: self.assemble_dic()

		self.clustering_csv = "{d_d}/{d}_clustering.csv".format(d_d=self.dock_dir, d=dock)
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
			print("---> Calculating AIAD between poses (for clustering)")
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
		print("   > Completed clustering.csv is located at:\n\t{}".format(self.clustering_csv))

	# Save the data dictionary as a pickled file (i.e. in native python format)
	def save_pickled_docking_obj(self):
		self.pickled_docking_obj = "{d_d}/{d}.p".format(d_d=self.dock_dir, d=dock)
		pickle.dump(self, open(self.pickled_docking_obj, 'wb'))

		self.is_pickled = True
		print("---> Pickled docking object located at:\n\t{}".format(self.pickled_docking_obj))

	def __init__(self, d):
		global dock
		dock = d

		self.dock = dock
		self.load_parameters()
		self.get_ligset_list()

		self.is_assembled = False
		self.is_bs_listed = False
		self.is_bs_scored = False
		self.are_aiad_icpd_calcd = False
		self.are_all_resis_assessed = False
		self.is_csv_written = False
		self.are_poses_clustered = False
		self.is_pickled = False





		# WOOOT!










