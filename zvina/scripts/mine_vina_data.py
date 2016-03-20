#!/usr/bin/env python

### Mine data from processed vina results, add to data dictionary
# (c) Zarek Siegel

from parse_pdb import * # Pdb
from create_docking_object import * # Docking

# Mine Vina result for data (actual mining is in parse_pdb.py, acting via the Pdb class)
def mine_vina_data(self):
	print("---> Mining data from processed vina result PDBQTs...")
	## ** check if proper files exist
	for lig in self.ligset_list:
		for m in range(1, self.n_models + 1):
			key = "{}_{}_m{}".format(self.dock, lig, m)
			processed_pdbqt = "{d_d}/processed_pdbqts/{key}.pdbqt".format(
				d_d=self.dock_dir, key=key)
			if os.path.isfile(processed_pdbqt):
				try: pose = Pdb(processed_pdbqt)
				except: print("! ! ! Error while trying to read PDB for {}".format(key))
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
					print("! ! ! pose {} failed, check for the processed PDBQT".format(key))
			else: print("! ! ! processed_pdbqt does not exist for {}".format(key))

			self.data_dic[key] = dict(self.data_dic[key].items() + pose_dic.items())

	self.vina_data_mined = True
	print("   > Data dictionary filled with data from process_VinaResult.py\n")

Docking.mine_vina_data = mine_vina_data