#!/usr/bin/env python

### Output all the data mined and analyzed into a CSV file
# (c) Zarek Siegel

import os, sys
# import cPickle as pickle
import pickle
from create_docking_object import * # Docking


def read_alldata_csv(self):
	self.alldata_csv = "{d_d}/{d}_alldata.csv".format(d_d=self.dock_dir, d=self.dock)

	print("---> Reading alldata.csv\n")
	with open(self.alldata_csv, 'r') as csvfile:
		reader = csv.DictReader(csvfile)
		for row in reader:
			self.data_dic[row['key']] = row
	print("! ! ! Warning, it is better to load from the whole object pickled versus just the data from a CSV")


Docking.read_alldata_csv = read_alldata_csv

# Save the data dictionary as a pickled file (i.e. in native python format)
def read_docking_pickled(self):
	self.docking_obj_pickled = "{d_d}/{d}.p".format(d_d=self.dock_dir, d=self.dock)

	print("---> Reading docking.p\n")
	self = pickle.load(open(self.docking_obj_pickled, 'rb'))

Docking.read_docking_pickled = read_docking_pickled











