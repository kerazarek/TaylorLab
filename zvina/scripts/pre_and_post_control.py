#! /usr/bin/env python

### One script to control them AAAAAALLLLL!!!!
# (c) Zarek Siegel
# v1 3/6/16

import argparse, subprocess

def main():
	print("")
	print("->-> hi")
	base_dir = "/Users/zarek/GitHub/TaylorLab/zvina/"
	cluster_base_dir = "/home/zsiegel/"
	ADT_dir="/Library/MGLTools/latest/MGLToolsPckgs/AutoDockTools/"
	MGL_py_bin="/Library/MGLTools/latest/bin/pythonsh"

	parser = argparse.ArgumentParser(description='Pre- and post-Vina file fun times')
	parser.add_argument('-d', '--dock', metavar='DOCK', type=str, nargs=1,
		help='the ID for this docking')

	parser.add_argument('-w', '--write_params', action='store_true', default=False,
		help='execute the R script to write the parameters.csv')
	parser.add_argument('-v', '--vina', action='store_true', default=False,
		help='write the Vina job submission script')
	parser.add_argument('-s', '--separate', action='store_true', default=False,
		help='execute the bash script to separate row Vina results')
	parser.add_argument('-n', '--clean', action='store_true', default=False,
		help='execute the bash script to clean up processed Vina results')

	parser.add_argument('-c', '--csv', action='store_true', default=False,
		help='save the alldata CSV file')
	parser.add_argument('-l', '--cluster', action='store_true', default=False,
		help='create cluster CSV files (all lig x lig AIADS)')
	parser.add_argument('-i', '--pickle', action='store_true', default=False,
		help='save the docking as a pickled object')

	args = vars(parser.parse_args())
	dock = str(args['dock'][0])
	write_params = args['write_params']
	vina = args['vina']
	separate = args['separate']
	clean = args['clean']

	csv = args['csv']
	cluster = args['cluster']
	pickle = args['pickle']

	if write_params:
		print("---> Parameters CSV for docking h11 has been created. It can be found at:")
		subprocess.call(["./write_params_csv.R", dock, base_dir])

	if not write_params:
		from docking_data_assembly import Docking
		d = Docking(dock, base_dir, cluster_base_dir)

	if vina:
		print("---> Writing Vina submission script")
		d.write_vina_submit()
	if separate:
		print("---> Processing raw Vina output PDBQTs")
		subprocess.call(["./separate_vina_results.sh", dock, ADT_dir, MGL_py_bin])
	if clean:
		print("---> Cleaning up processed PDBQTs and converting to PDBs")
		subprocess.call(["./cleanup_processed_vina_results.sh", dock, ADT_dir, MGL_py_bin])
	if csv: d.write_alldata_csv()
	if cluster: d.cluster_poses()
	if pickle: d.save_pickled_docking_obj()

	print("->-> All done!!!!!!!!!!!!!!!")
	print("")

if __name__ == "__main__": main()


