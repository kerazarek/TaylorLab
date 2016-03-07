#! /usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16 (as assemble_alldata.py)
# v2 3/6/16

from __future__ import print_function
import csv, re, os
import cPickle as pickle
from parse_pdb import *
from aiad_icpd import *

class Docking():
	def load_parameters(self):
		parameters_csv = "{b_d}parameters_csvs/{d}_parameters.csv".format(b_d=base_dir, d=dock)
		parameters_csv_open = open(parameters_csv, 'r')
		parameters_csv_read = csv.reader(parameters_csv_open)

		parameters_dic = {}
		for row in parameters_csv_read:
			parameters_dic[row[0]] = row[1]
		self.parameters = parameters_dic

		self.dock = self.parameters['dock']
		self.prot = self.parameters['prot']
		self.ligset = self.parameters['ligset']
		self.box = self.parameters['box']
		self.box_center_x = self.parameters['box_center_x']
		self.box_center_y = self.parameters['box_center_y']
		self.box_center_z = self.parameters['box_center_z']
		self.box_size_x = self.parameters['box_size_x']
		self.box_size_y = self.parameters['box_size_y']
		self.box_size_z = self.parameters['box_size_z']
		self.exhaust = self.parameters['exhaust']
		self.n_models = int(self.parameters['n_models'])
		self.n_cpus = self.parameters['n_cpus']

		self.prot_dir = "{b_d}{p}/".format(b_d=base_dir, p=self.prot)
		self.dock_dir = "{b_d}{p}/{d}/".format(b_d=base_dir, p=self.prot, d=self.dock)

		print("---> Loaded docking parameters")

	def get_ligset_list(self):
		ligset_list_txt = "{b_d}ligsets/{ls}/{ls}_list.txt".format(
			b_d=base_dir,ls=self.parameters['ligset'])
		ligset_list_txt_open = open(ligset_list_txt, 'r')
		with ligset_list_txt_open as f:
			self.ligset_list = f.read().splitlines()
		print("---> Retrieved ligset list")

	def write_vina_submit(self):
		if self.n_models <= 20:
			template_empty =  """#BSUB -q hp12
#BSUB -n {n_cpus}
#BSUB -J {job_name}

# Text file with list of ligands (one on each line)
ligset_list_txt={ligset_list_txt}

# Create the docking and output directories
mkdir {out_dir}
mkdir {out_dir}result_pdbqts

# Generate the list of ligands
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Vina command
for lig in $ligset_list; do
	/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \\
	--receptor {prot_pdbqt} \\
	--ligand {in_dir}$lig.pdbqt \\
	--out {out_dir}result_pdbqts/$lig\_results.pdbqt \\
	--center_x {box_center_x} \\
	--center_y {box_center_y} \\
	--center_z {box_center_z} \\
	--size_x {box_size_x} \\
	--size_y {box_size_y} \\
	--size_z {box_center_z} \\
	--cpu {n_cpus} \\
	--num_modes {n_models} \\
	--exhaustiveness {exhaust}
done

echo \"---> Finished docking $ligset_list\""""
		elif self.n_models > 20:
			template_empty =  """#BSUB -q hp12
#BSUB -n {n_cpus}
#BSUB -J {job_name}

# Text file with list of ligands (one on each line)
ligset_list_txt={ligset_list_txt}

# Create the docking and output directories
mkdir {out_dir}
mkdir {out_dir}result_pdbqts

# Generate the list of ligands
ligset_list=$(for l in $(cat $ligset_list_txt); do echo $l; done)

# Vina command
for ((b=1;b<={n_batches};b++)); do
	for lig in $ligset_list; do
		/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \\
		--receptor {prot_pdbqt} \\
		--ligand {in_dir}$lig.pdbqt \\
		--out {out_dir}result_pdbqts/$lig\_results_b$b.pdbqt \\
		--center_x {box_center_x} \\
		--center_y {box_center_y} \\
		--center_z {box_center_z} \\
		--size_x {box_size_x} \\
		--size_y {box_size_y} \\
		--size_z {box_center_z} \\
		--cpu {n_cpus} \\
		--num_modes {n_models} \\
		--exhaustiveness {exhaust}
	done

done

echo \"---> Finished docking $ligset_list\""""
		template_filled = template_empty.format(
			n_cpus = self.n_cpus,
			job_name = "vina_{}".format(dock),
			ligset_list_txt = "{c_b_d}ligsets/{ls}/{ls}_list.txt".format(
				c_b_d=cluster_base_dir, ls=self.ligset),
			in_dir = "{c_b_d}ligsets/{ls}/pdbqts/".format(
				c_b_d=cluster_base_dir, ls=self.ligset),
			out_dir = "{c_b_d}{p}/{d}/".format(
				c_b_d=cluster_base_dir, p=self.prot, d=self.dock),
			prot_pdbqt = "{c_b_d}{p}/{p}.pdbqt".format(
				c_b_d=cluster_base_dir, p=self.prot),
			box_center_x = self.box_center_x,
			box_center_y = self.box_center_y,
			box_center_z = self.box_center_z,
			box_size_x = self.box_size_x,
			box_size_y = self.box_size_y,
			box_size_z = self.box_size_z,
			n_models = self.n_models,
			exhaust = self.exhaust,
			n_batches = self.n_models / 20
		)

		vina_submit_sh = "{b_d}vina_submit_shs/vina_submit_{d}.sh".format(
			b_d=base_dir, d=dock)
		with open(vina_submit_sh, 'w') as f:
			f.write(template_filled)
# 		print(vina_submit_sh)
# 		print(template_filled)
		print("---> Vina submission script for docking h11 has been created. It can be found at:")
		print("\t{}".format(vina_submit_sh))

	def write_vina_submit_gt20ligs(self):
		pass

	def assemble_dic(self):
		self.data_dic = {}
		self.keys = []
		for lig in self.ligset_list:
			for m in range(1, int(self.parameters['n_models'])+1):
				processed_pdbqt = "{d_d}processed_pdbqts/{d}_{lig}_m{m}.pdbqt".format(
					d_d=self.dock_dir, d=dock, lig=lig, m=m)
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

		self.is_assembled = True
		print("---> data dictionary created with data from process_VinaResult.py")

	def get_binding_sites_list(self):
		if not self.is_assembled: self.assemble_dic()

		binding_sites_dir = "{p_d}binding_sites/".format(p_d=self.prot_dir)
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

		self.is_bs_listed = True
		print("---> Retrieved binding sites")

	def score_binding_sites(self):
		if not self.is_assembled: self.assemble_dic()
		if not self.is_bs_listed: self.get_binding_sites_list()

		for pose in self.data_dic:
			for bs in self.binding_sites_list:
				resis_union = ( set(self.bs_resis_lists[bs]) & set(self.data_dic[pose]['pvr_resis']) )
				self.data_dic[pose]["{}_fraction".format(bs)] = float(len(resis_union)) / float(len(self.bs_resis_lists[bs]))
				resis_atoms_union = ( set(self.bs_resis_atoms_lists[bs]) & set(self.data_dic[pose]['pvr_resis_atoms']) )
				self.data_dic[pose]["{}_atoms_fraction".format(bs)] = float(len(resis_atoms_union)) / float(len(self.bs_resis_atoms_lists[bs]))

		self.is_bs_scored = True
		print("---> Scored binding sites")

	def aiad_icpd_binding_sites(self):
		if not self.is_assembled: self.assemble_dic()

		for pose in self.data_dic:
			for bs, bso in self.binding_sites_objs.items():
				aiad = caclulate_aiad(self.data_dic[pose]['pvr_obj'], bso)
				self.data_dic[pose]["{}_aiad".format(bs)] = aiad
				icpd = calculate_icpd(self.data_dic[pose]['pvr_obj'], bso)
				self.data_dic[pose]["{}_icpd".format(bs)] = icpd

		self.are_aiad_icpd_calcd = True
		print("---> Calculated AIAD and ICPD")

	def assess_all_resis(self):
		if not self.is_assembled: self.assemble_dic()

		self.prot_pdbqt = "{p_d}{p}.pdbqt".format(p_d=self.prot_dir, p=self.prot)
		self.prot_obj = Pdb(self.prot_pdbqt)
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

	def write_alldata_csv(self):
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
# 		for atom in self.prot_resis_atoms_list: fieldnames.append(atom)

		self.alldata_csv = "{d_d}{d}_alldata.csv".format(d_d=self.dock_dir, d=dock)
		with open(self.alldata_csv, 'w') as csvfile:
			writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
			writer.writeheader()
			for pose in self.data_dic:
				row = {}
				for f in fieldnames:
					row[f] = self.data_dic[pose][f]
				writer.writerow(row)

		self.is_csv_written = True
		print("---> Completed alldata.csv is located at:\n\t{}".format(self.alldata_csv))

	def cluster_poses(self):
		if not self.is_assembled: self.assemble_dic()

		self.clustering_dic = {}
		c = 0
		print("---> Calculating AIAD between poses (for clustering)")
		for key1 in self.data_dic:
			self.clustering_dic[key1] = {}
			c += 1
			print("\t- calculated for {:25}{:<9}of{:>9}".format(key1,c,len(self.keys)))
			for key2 in self.data_dic:
				aiad12 = caclulate_aiad(self.data_dic[key1]['pvr_obj'], self.data_dic[key2]['pvr_obj'])
				self.clustering_dic[key1][key2] = aiad12

		self.clustering_csv = "{d_d}{d}_clustering.csv".format(d_d=self.dock_dir, d=dock)
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

	def save_pickled_docking_obj(self):
		self.pickled_docking_obj = "{d_d}{d}.p".format(d_d=self.dock_dir, d=dock)
		pickle.dump(self, open(self.pickled_docking_obj, 'wb'))

		self.is_pickled = True
		print("---> Pickled docking object located at:\n\t{}".format(self.pickled_docking_obj))

	def __init__(self, d, b_d, c_b_d):
		global dock
		global base_dir
		global cluster_base_dir
		dock = d
		base_dir = b_d
		cluster_base_dir = c_b_d

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










