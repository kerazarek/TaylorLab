#!/usr/bin/env python

import argparse
from postvina_data_mining import Docking

def main():
	base_dir = "/Users/zarek/GitHub/TaylorLab/zvina/"

	parser = argparse.ArgumentParser(description='Pre- and post-Vina file fun times')
	parser.add_argument('-d', '--dock', metavar='DOCK', type=str, nargs=1,
		help='the ID for this docking')
	parser.add_argument('-c', '--csv', action='store_true', default=False,
		help='save the alldata CSV file')
	parser.add_argument('-l', '--cluster', action='store_true', default=False,
		help='create cluster CSV files (all lig x lig AIADS)')
	parser.add_argument('-i', '--pickle', action='store_true', default=False,
		help='save the docking as a pickled object')

	args = vars(parser.parse_args())
	dock = str(args['dock'][0])
	csv = args['csv']
	cluster = args['cluster']
	pickle = args['pickle']

	d = Docking(dock, base_dir)

	if csv: d.write_alldata_csv()
	if cluster: d.cluster_poses()
	if pickle: d.save_pickled_docking_obj()

if __name__ == "__main__": main()


