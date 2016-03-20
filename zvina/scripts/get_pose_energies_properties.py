#!/usr/bin/env python

###
# (c) Zarek Siegel

from __future__ import print_function
from energies_properties import *
from create_docking_object import * # Docking

def get_pose_energies_properties(self):
	if not self.vina_data_mined: self.mine_vina_data()

	print("---> Assessing molecular properties and energies for pose...")
	# Properties are gathered once per ligand
	# 	But energies are gathered for each pose
	print("   > Evaluating pose ", end="")
	for lig in self.ligset_list:
		first_pose = "{}_{}_m{}".format(self.dock, lig, "1")
		first_pdbqt = self.data_dic[first_pose]['pdbqt_address']

		char_count = 24
		pose_properties_dic = get_properties(first_pdbqt)
		for m in range(1, self.n_models + 1):
			pose = "{}_{}_m{}".format(self.dock, lig, m)
			if char_count <= 76:
				print(pose, end=" ")
				char_count = char_count + len(pose) + 1
			else:
				print("\n\t{}".format(pose), end = " ")
				char_count = len(pose) + 1
			pdbqt = self.data_dic[pose]['pdbqt_address']
			pose_energies_dic = get_energies(pdbqt)
			combined_dic = dict(pose_properties_dic.items() +
				pose_energies_dic.items())
# 			print(combined_dic)
			self.data_dic[pose] = dict(self.data_dic[pose].items() + combined_dic.items())

	self.energies_props_gotten = True

	print("\n   > Done\n")

Docking.get_pose_energies_properties = get_pose_energies_properties
