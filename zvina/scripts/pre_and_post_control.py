#!/usr/bin/env python

### One script to control them AAAAAALLLLL!!!!
# (c) Zarek Siegel
# v1 3/6/16

import argparse, subprocess
import new_grid_or_dock_entry
from constants import *

def main():
	print("")
	print("->-> hi")

	parser = argparse.ArgumentParser(description='Pre- and post-Vina file fun times')
	parser.add_argument('-d', '--dock', metavar='DOCK', type=str, nargs='?',
		help='the ID for this docking')

	parser.add_argument('-nd', '--new_docking', action='store_true', default=False,
		help='execute the R script to write the parameters.csv')
	parser.add_argument('-ng', '--new_gridbox', action='store_true', default=False,
		help='execute the R script to write the parameters.csv')
	parser.add_argument('-w', '--write_params', action='store_true', default=False,
		help='execute the R script to write the parameters.csv')
	parser.add_argument('-v', '--vina', action='store_true', default=False,
		help='write the Vina job submission script')

	parser.add_argument('-s', '--separate', action='store_true', default=False,
		help='execute the bash script to separate row Vina results')
	parser.add_argument('-n', '--clean', action='store_true', default=False,
		help='execute the bash script to clean up processed Vina results')

	parser.add_argument('-c', '--csv', action='store_true', default=False,
		help='generate and save the alldata CSV file')
	parser.add_argument('-l', '--cluster', action='store_true', default=False,
		help='create cluster CSV files (all lig x lig AIADs)')
	parser.add_argument('-i', '--pickle', action='store_true', default=False,
		help='save the docking as a pickled object')


	parser.add_argument('-o', '--post_proc', action='store_true', default=False,
		help='Perform all post-processing steps (separate, clean, csv, cluster, pickle)')

	args = vars(parser.parse_args())
	#
	new_docking = args['new_docking']
	new_gridbox = args['new_gridbox']
	write_params = args['write_params']
	vina = args['vina']
	#
	separate = args['separate']
	clean = args['clean']
	#
	csv = args['csv']
	cluster = args['cluster']
	pickle = args['pickle']

	post_proc = args['post_proc']

# 	if write_params:
# 		print("---> Parameters CSV for docking h11 has been created. It can be found at:")
# 		subprocess.call(["./write_params_csv.R", dock, base_dir])

	if new_docking:
		print("---> Write new set of docking parameters to Dockings.csv...")
		new_grid_or_dock_entry.new_docking_entry()
	if new_gridbox:
		print("---> Write new set of grid box parameters to Gridboxes.csv...")
		new_grid_or_dock_entry.new_gridbox_entry()

	if separate or clean or vina or csv or cluster or pickle or post_proc:
		dock = str(args['dock'])

	if separate:
		print("---> Processing raw Vina output PDBQTs")
		subprocess.call(["./separate_vina_results.sh", dock])
	if clean:
		print("---> Cleaning up processed PDBQTs and converting to PDBs")
		subprocess.call(["./cleanup_processed_vina_results.sh", dock])

	if vina or csv or cluster or pickle or post_proc:
		from docking_data_assembly import Docking
		d = Docking(dock)

	if vina:
		print("---> Writing Vina submission script")
		d.write_vina_submit()

	if csv: d.write_alldata_csv()
	if cluster: d.cluster_poses()
	if pickle: d.save_pickled_docking_obj()

	if post_proc:
		print("---> Processing raw Vina output PDBQTs")
		subprocess.call(["./separate_vina_results.sh", dock, base_dir, ADT_dir, MGL_py_bin])
		print("---> Cleaning up processed PDBQTs and converting to PDBs")
		subprocess.call(["./cleanup_processed_vina_results.sh", dock, base_dir, ADT_dir, MGL_py_bin])
		d.write_alldata_csv()
		d.cluster_poses()
		d.save_pickled_docking_obj()


	print("->-> All done!!!!!!!!!!!!!!!")
	print("")

if __name__ == "__main__": main()


