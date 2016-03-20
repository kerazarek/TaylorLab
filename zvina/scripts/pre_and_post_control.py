#!/usr/bin/env python

### One script to control them AAAAAALLLLL!!!!
# (c) Zarek Siegel
# v1 3/6/16

import argparse, subprocess, os
import new_grid_or_dock_entry
from constants import *
from create_docking_object import * # Docking
from write_vina_submit_sh import * # write_vina_submit_sh
from get_pose_energies_properties import * # get_pose_energies_properties
from mine_vina_data import * # mine_vina_data
from binding_site_analysis import * # get_binding_sites_list
# from binding_site_analysis import * # score_binding_sites
# from binding_site_analysis import * # aiad_icpd_binding_sites
# from binding_site_analysis import * # assess_all_resis
from write_alldata import * # write_alldata_csv, write_docking_pickled
from read_alldata import * # read_alldata_csv, read_docking_pickled
from correlations import * # correlations

# from docking_data_assembly import *


def main():
	print("")
	print("->-> hi")

	parser = argparse.ArgumentParser(description='Pre- and post-Vina file fun times')
	parser.add_argument('-d', '--dock', metavar='DOCK', type=str, nargs='?',
		help='the ID for this docking')

	parser.add_argument('-nd', '--new_docking', action='store_true', default=False,
		help='Write a new set of docking parameters to Dockings.csv')
	parser.add_argument('-ng', '--new_gridbox', action='store_true', default=False,
		help='Write a new set of grid box parameters to Gridboxes.csv')
	parser.add_argument('-v', '--vina', action='store_true', default=False,
		help='write the Vina job submission script')
	parser.add_argument('-p', '--print', action='store_true', default=False,
		help='print docking parameters')

	parser.add_argument('-s', '--separate', action='store_true', default=False,
		help='execute the bash script to separate row Vina results')
	parser.add_argument('-n', '--clean', action='store_true', default=False,
		help='execute the bash script to clean up processed Vina results')

	parser.add_argument('-rc', '--read_csv', action='store_true', default=False,
		help='load data from alldata CSV file')
	parser.add_argument('-ri', '--read_pickle', action='store_true', default=False,
		help='load data from pickled object')

	parser.add_argument('-bs', '--binding_sites', action='store_true', default=False,
		help='score binding sites by fraction of binding site residues contacted')
	parser.add_argument('-ai', '--aiad_icpd', action='store_true', default=False,
		help='score binding sites by AIAD and ICPD')
	parser.add_argument('-ar', '--all_resis', action='store_true', default=False,
		help='asses contacts with all residues')
	parser.add_argument('--atoms', action='store_true', default=False,
		help='assess poses against all atoms (not just residues) for -bs and -ar')

	parser.add_argument('-l', '--cluster', action='store_true', default=False,
		help='create cluster CSV files (all lig x lig AIADs)')
	parser.add_argument('-co', '--correls', action='store_true', default=False,
		help='find correlations between all quantitative variables')
	parser.add_argument('-c', '-wc', '--write_csv', action='store_true', default=False,
		help='generate and save the alldata CSV file')
	parser.add_argument('-i', '-wi', '--write_pickle', action='store_true', default=False,
		help='save the entire docking as a pickled object')

	parser.add_argument('-ep', '--en_props', action='store_true', default=False,
		help='Write a new set of docking parameters to Dockings.csv')
	parser.add_argument('-o', '--post_proc', action='store_true', default=False,
		help='Perform all post-processing steps (separate, clean, csv, cluster, pickle)')
	parser.add_argument('-g', '--graphs', action='store_true', default=False,
		help='Generate graphs for this docking')

	args = vars(parser.parse_args())


	if args['new_docking']:
		print("---> Write new set of docking parameters to Dockings.csv...")
		new_grid_or_dock_entry.new_docking_entry()
	elif args['new_gridbox']:
		print("---> Write new set of grid box parameters to Gridboxes.csv...")
		new_grid_or_dock_entry.new_gridbox_entry()
	else:
		dock = str(args['dock'])
		d = Docking(dock)
		if args['print']:
			d.print_parameters()
		if args['vina']:
			print("---> Writing Vina submission script")
			d.write_vina_submit_sh()
		if args['separate']:
			print("---> Processing raw Vina output PDBQTs")
			d.export_parameters_to_environment()
			subprocess.call(["{b_d}/scripts/separate_vina_results.sh".format(b_d=base_dir), dock])
		if args['clean']:
			print("---> Cleaning up processed PDBQTs and converting to PDBs")
			d.export_parameters_to_environment()
			subprocess.call(["{b_d}/scripts/cleanup_processed_vina_results.sh".format(b_d=base_dir), dock])
		if args['read_csv']: d.read_alldata_csv()
		if args['read_pickle']: d.read_docking_pickled()
		if args['en_props']:
			print("---> Getting molecular energies and properties for all poses")
			d.get_pose_energies_properties()
		if args['atoms']: d.evaluate_resis_atoms = True
		else: d.evaluate_resis_atoms = False
		if args['binding_sites']: d.score_binding_sites()
		if args['aiad_icpd']: d.aiad_icpd_binding_sites()
		if args['all_resis']: d.assess_all_resis()
		if args['cluster']: d.cluster_poses()
		if args['write_csv']: d.write_alldata_csv()
		if args['correls']: d.correlations()
		if args['write_pickle']: d.write_docking_pickled()
		if args['graphs']:
			print("---> Generating graphs")
			subprocess.call([Rscript_binary, "{b_d}/scripts/postdocking_graphs.R".format(b_d=base_dir), dock])
		if args['post_proc']:
			print("---> Processing raw Vina output PDBQTs")
			subprocess.call(["{b_d}/scripts/separate_vina_results.sh".format(b_d=base_dir),
				dock, base_dir, AutoDockTools_dir, AutoDockTools_pythonsh_binary])
			print("---> Cleaning up processed PDBQTs and converting to PDBs")
			subprocess.call(["{b_d}/scripts/cleanup_processed_vina_results.sh".format(b_d=base_dir),
				dock, base_dir, AutoDockTools_dir, AutoDockTools_pythonsh_binary])
			d.write_alldata_csv()
			d.cluster_poses()
			d.save_pickled_docking_obj()

	print("->-> All done!!!!!!!!!!!!!!!")
	print("")

if __name__ == "__main__": main()







# print("{} = {}".format("parameters_loaded", self.parameters_loaded))
# print("{} = {}".format("ligset_list_gotten", self.ligset_list_gotten))
# print("{} = {}".format("parameters_exported_to_environment", self.parameters_exported_to_environment))
# print("{} = {}".format("is_data_dic_created", self.is_data_dic_created))
#
# print("{} = {}".format("vina_data_mined", self.vina_data_mined))
# print("{} = {}".format("binding_sites_list_gotten", self.binding_sites_list_gotten))
# print("{} = {}".format("binding_sites_scored", self.binding_sites_scored))
# print("{} = {}".format("aiad_icpd_calcd", self.aiad_icpd_calcd))
# print("{} = {}".format("all_resis_assessed", self.all_resis_assessed))
#
# print("{} = {}".format("is_csv_written", self.is_csv_written))
# print("{} = {}".format("energies_props_gotten", self.energies_props_gotten))
# print("{} = {}".format("are_poses_clustered", self.are_poses_clustered))
# print("{} = {}".format("is_pickled", self.is_pickled))










