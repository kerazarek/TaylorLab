#!/usr/bin/env python

### Output all the data mined and analyzed into a CSV file
# (c) Zarek Siegel

from scipy.stats.stats import pearsonr
from operator import itemgetter
from create_docking_object import * # Docking
from write_alldata import get_fieldnames

def correlations(self):

	self.get_fieldnames()

	not_quant = ['key', 'lig', 'model', 'pdbqt_address', 'pdb_address',
		'name', 'formula', 'canonical_SMILES']
	correl_vars = [var for var in self.alldata_fieldnames if var not in not_quant]

	correl_var_lists = {}
	for var in correl_vars:
		correl_var_lists[var] = []
		for pose in self.keys:
			try: correl_var_lists[var].append(self.data_dic[pose][var])
			except KeyError: correl_var_lists[var].append(None)

	correls = []
	for var1 in correl_vars:
		print(var1)
		for var2 in correl_vars:
			pearson = pearsonr(correl_var_lists[var1], correl_var_lists[var2])
			correls.append(
				{
					'var1' : var1,
					'var2' : var2,
					'correl' : pearson[0],
					'cor_mag' : abs(pearson[0]),
					'p' : pearson[1]
				}
			)


	sig_correls = [c for c in correls if c['p'] < 0.05]

	print(len(correls))
	print(len(sig_correls))
	for c1 in sig_correls:
		# print(c1)
		if (c1['var1'] == c1['var2']):
				sig_correls.remove(c1)
		for c2 in sig_correls:
			# print(c2)
			if (c2['var1'] == c2['var2']):
				sig_correls.remove(c2)
			elif (c1['var1'] == c2['var2']) and (c1['var2'] == c2['var1']):
				sig_correls.remove(c2)

			else:
				continue
	print(len(correls))
	print(len(sig_correls))
	sig_correls = sorted(sig_correls, key=itemgetter('cor_mag', 'p', 'var1'))

	# Don't print correlations between two residues
	for c in sig_correls:
		if not (c['var1'] in self.prot_resis_list) and (c['var2'] in self.prot_resis_list):
			print("{:<30}{:<30}{:<30}{:<30}".format(c['var1'], c['var2'], c['correl'], c['p']))





# 	print("{} = {}".format("parameters_loaded", self.parameters_loaded))
# 	print("{} = {}".format("ligset_list_gotten", self.ligset_list_gotten))
# 	print("{} = {}".format("parameters_exported_to_environment", self.parameters_exported_to_environment))
# 	print("{} = {}".format("is_data_dic_created", self.is_data_dic_created))
#
# 	print("{} = {}".format("vina_data_mined", self.vina_data_mined))
# 	print("{} = {}".format("binding_sites_list_gotten", self.binding_sites_list_gotten))
# 	print("{} = {}".format("binding_sites_scored", self.binding_sites_scored))
# 	print("{} = {}".format("aiad_icpd_calcd", self.aiad_icpd_calcd))
# 	print("{} = {}".format("all_resis_assessed", self.all_resis_assessed))
#
# 	print("{} = {}".format("is_csv_written", self.is_csv_written))
# 	print("{} = {}".format("energies_props_gotten", self.energies_props_gotten))
# 	print("{} = {}".format("are_poses_clustered", self.are_poses_clustered))
# 	print("{} = {}".format("is_pickled", self.is_pickled))



Docking.correlations = correlations


# pvr_fieldnames = ['E', 'rmsd_lb', 'rmsd_ub', 'pvr_effic',
# 			'pvr_n_contacts', 'torsdof', 'pdbqt_address', 'pdb_address'] # (processed vina results)
# 		self.alldata_fieldnames = self.alldata_fieldnames + pvr_fieldnames
#
# 	if self.energies_props_gotten:
# 		energies_properties_fieldnames = [
# 			'total_bond_stretching_energy', 'total_angle_bending_energy',
# 			'total_torsional_energy', 'total_energy',
# 			'name', 'formula', 'mol_weight', 'exact_mass', 'canonical_SMILES',
# 			'num_atoms', 'num_bonds', 'num_rings', 'logP', 'PSA', 'MR'