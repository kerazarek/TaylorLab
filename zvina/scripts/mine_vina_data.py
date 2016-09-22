#!/usr/bin/env python

### Mine data from processed vina results, add to data dictionary
# (c) Zarek Siegel

from parse_pdb import * # Pdb, Residue
from create_docking_object import * # Docking
from pdb_obj_types import * # Pose

# Mine Vina result for data (actual mining is in parse_pdb.py, acting via the Pdb class)
def mine_vina_data(self):
	print("---> Mining data from processed vina result PDBQTs...")
	## ** check if proper files exist
	self.poses = []
	print("   > Mining pose ", end="")
	char_count = 0

	self.keys = []
	for lig in self.ligset_list:
		for m in range(1, self.n_models + 1):

			if m == 1: message = "\n\t> {} #1 ".format(lig)
			else: message = m

			if char_count <= 76:
				print(message, end=" ")
				char_count = char_count + len(str(message)) + 1
			else:
				print("\n\t{}".format(message), end = " ")
				char_count = len(str(message)) + 1


			key = "{}_{}_m{}".format(self.dock, lig, m)
			self.keys.append(key)
			processed_pdbqt = "{d_d}/processed_pdbqts/{key}.pdbqt".format(
				d_d=self.dock_dir, key=key)
			if os.path.isfile(processed_pdbqt):
				_error = False
				try:
					# pose = Pdb(processed_pdbqt)
					# print("lig: {}".format(lig))
					# print("m: {}".format(m))
					pose = Pose(self, lig, m)
					if hasattr(pose, 'pvr_resis'):
						self.poses.append(pose)
					else:
						_error = True
				except:
					print("\n! ! ! Error while trying to read PDB for {}".format(key))
					_error = True
				try:
					pose_dic = {
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
						'pvr_obj' : pose,
						'pdbqt_address' : processed_pdbqt,
						'pdb_address' : re.sub('pdbqt', 'pdb', processed_pdbqt)
					}
				except AttributeError:
					print("\n! ! ! pose {} failed, check for the processed PDBQT".format(key))
					_error = True
				if not _error:
					self.data_dic[key] = dict(list(self.data_dic[key].items()) +
						list(pose_dic.items()))
				else: del self.data_dic[key]
					# error message?

			else: print("\n! ! ! processed_pdbqt does not exist for {}".format(key))

			# print(self.data_dic[key].items())
			# print(pose_dic.items())
# 			self.data_dic[key] = dict(list(self.data_dic[key].items()) +
# 				list(pose_dic.items()))
	self.vina_data_mined = True

# 	for pose in self.poses:
# 		print(pose)

	print("   > Data dictionary filled with data from process_VinaResult.py\n")

Docking.mine_vina_data = mine_vina_data