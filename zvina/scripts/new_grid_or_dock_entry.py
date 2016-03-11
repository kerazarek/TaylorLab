#!/usr/bin/env python

### Write a new entry to Dockings.csv or Gridboxes.csv
# (c) Zarek Siegel
# v1 3/10/16
# v1.1 3/11/16

import csv, re, argparse, time, datetime
from constants import *

class Timestamp():
	def __init__(self):
		time_obj = time.time()
		self.display = datetime.datetime.fromtimestamp(time_obj).strftime('%Y-%m-%d %H:%M:%S')
		self.eightdigit = datetime.datetime.fromtimestamp(time_obj).strftime('%Y%m%d')

def new_docking_entry():
	# Hello
	print("\n\tWelcome! This script will add an entry to Dockings.csv\n")

	# Dockings.csv columns:
	#	Docking ID
	#	Date
	#	Protein
	#	Ligset
	#	Gridbox
	#	Exhaustiveness
	#	Number of Models
	#	Number of CPUs
	#	Notes

	# Going through each variable, taking user input
	dock_input = raw_input("\t\tDocking identifier: ")
	print("\t\t>>> dock set to: {}\n".format(dock_input))

	current_time = Timestamp()
	date_input = raw_input("\t\tDate (enter 'd' to default to {}): ".format(current_time.eightdigit))
	if date_input == "d": date_input = current_time.eightdigit
	print("\t\t>>> date set to: {}\n".format(date_input))

	prot_input = raw_input("\t\tProtein identifier: ")
	print("\t\t>>> prot set to: {}\n".format(prot_input))

	ligset_input = raw_input("\t\tLigset identifier: ")
	print("\t\t>>> ligset set to: {}\n".format(ligset_input))

	box_input = raw_input("\t\tGridbox identifier: ")
	print("\t\t>>> box set to: {}\n".format(box_input))

	exhaust_input = raw_input("\t\tExhaustiveness: ")
	print("\t\t>>> exhaust set to: {}\n".format(exhaust_input))

	n_models_input = raw_input("\t\tNumber of models: ")
	print("\t\t>>> n_models set to: {}\n".format(n_models_input))

	n_cpus_input = raw_input("\t\tNumber of CPUs: ")
	print("\t\t>>> n_cpus set to: {}\n".format(n_cpus_input))

	notes_input = raw_input("\t\tAny notes: ")
	if notes_input == "":
		notes_input = "Entered by new_grid_or_dock_entry.py {}".format(current_time.display)
	else:
		notes_input = "{} (Entered by new_grid_or_dock_entry.py {})".format(
			notes_input, current_time.display)
	print("\t\t>>> notes set to: {}\n".format(notes_input))

	# New row as a dictionary
	new_row = {
		'Docking ID' : dock_input,
		'Date' : date_input,
		'Protein' : prot_input,
		'Ligset' : ligset_input,
		'Gridbox' : box_input,
		'Exhaustiveness' : exhaust_input,
		'Number of Models' : n_models_input,
		'Number of CPUs' : n_cpus_input,
		'Notes': notes_input
	}

	# Print confirmation of all entered variabled
	print("\t>>> The new row will be\n\n\
		Docking ID: {dock}\n\
		Date: {date}\n\
		Protein: {prot}\n\
		Ligset: {ligset}\n\
		Gridbox: {box}\n\
		Exhaustiveness: {exhaust}\n\
		Number of Models: {n_models}\n\
		Number of CPUs: {n_cpus}\n\
		Notes: {notes}\n".format(
							dock = dock_input,
							date = date_input,
							prot = prot_input,
							ligset = ligset_input,
							box = box_input,
							exhaust = exhaust_input,
							n_models = n_models_input,
							n_cpus = n_cpus_input,
							notes = notes_input
						)
	)

	# Don't write row without confirmation
	proceed = raw_input("\tWrite this as a new docking entry? [y/n] ")
# 	print("\t{}".format(new_row))

	# If "y" is entered, write the row, otherwise don't
	if proceed == "y":
		dockings_csv = "{b_d}Dockings.csv".format(b_d=base_dir)
		dockings_headers = ["Docking ID", "Date", "Protein", "Ligset", "Gridbox",
			"Exhaustiveness", "Number of Models", "Number of CPUs", "Notes"]
		with open(dockings_csv, 'a') as f:
			appender = csv.DictWriter(f, fieldnames=dockings_headers)
			appender.writerow(new_row)
		print("\n\t>>> New row appended to Dockings.csv:\n\topen {}\n".format(dockings_csv))
	else:
		print("\n\t>>> No docking entry written\n")

def new_gridbox_entry():
	# Hello
	print("\n\tWelcome! This script will add an entry to Gridboxes.csv\n")

	# Gridboxes.csv columns:
	#	Gridbox Name
	#	Protein
	#	Size in x-dimension
	#	Size in y-dimension
	#	Size in z-dimension
	#	Center in x-dimension
	#	Center in y-dimension
	#	Center in z-dimension
	#	Notes

	# Going through each variable, taking user input
	box_input = raw_input("\t\tGridbox Name: ")
	print("\t\t>>> box set to: {}\n".format(box_input))

	prot_input = raw_input("\t\tProtein: ")
	print("\t\t>>> prot set to: {}\n".format(prot_input))

	box_size_x_input = raw_input("\t\tSize in x-dimension: ")
	print("\t\t>>> box_size_x set to: {}\n".format(box_size_x_input))

	box_size_y_input = raw_input("\t\tSize in y-dimension: ")
	print("\t\t>>> box_size_y set to: {}\n".format(box_size_y_input))

	box_size_z_input = raw_input("\t\tSize in z-dimension: ")
	print("\t\t>>> box_size_z set to: {}\n".format(box_size_z_input))

	box_center_x_input = raw_input("\t\tCenter in x-dimension: ")
	print("\t\t>>> box_center_x set to: {}\n".format(box_center_x_input))

	box_center_y_input = raw_input("\t\tCenter in y-dimension: ")
	print("\t\t>>> box_center_y set to: {}\n".format(box_center_y_input))

	box_center_z_input = raw_input("\t\tCenter in z-dimension: ")
	print("\t\t>>> box_center_z set to: {}\n".format(box_center_z_input))

	current_time = Timestamp()
	notes_input = raw_input("\t\tAny notes: ")
	if notes_input == "":
		notes_input = "Entered by new_grid_or_dock_entry.py {}".format(current_time.display)
	else:
		notes_input = "{} (Entered by new_grid_or_dock_entry.py {})".format(
			notes_input, current_time.display)
	print("\t\t>>> notes set to: {}\n".format(notes_input))

	# New row as a dictionary
	new_row = {
		'Gridbox Name' : box_input,
		'Protein' : prot_input,
		'Size in x-dimension' : box_size_x_input,
		'Size in y-dimension' : box_size_y_input,
		'Size in z-dimension' : box_size_z_input,
		'Center in x-dimension' : box_center_x_input,
		'Center in y-dimension' : box_center_y_input,
		'Center in z-dimension' : box_center_z_input,
		'Notes' : notes_input
	}

	# Print confirmation of all entered variabled
	print("\t>>> The new row will be\n\n\
		Gridbox Name: {box}\n\
		Protein: {prot}\n\
		Size in x-dimension: {box_size_x}\n\
		Size in y-dimension: {box_size_y}\n\
		Size in z-dimension: {box_size_z}\n\
		Center in x-dimension: {box_center_x}\n\
		Center in y-dimension: {box_center_y}\n\
		Center in z-dimension: {box_center_z}\n\
		Notes: {notes}\n".format(
							box = box_input,
							prot = prot_input,
							box_size_x = box_size_x_input,
							box_size_y = box_size_y_input,
							box_size_z = box_size_z_input,
							box_center_x = box_center_x_input,
							box_center_y = box_center_y_input,
							box_center_z = box_center_z_input,
							notes = notes_input
						)
	)

	# Don't write row without confirmation
	proceed = raw_input("\tWrite this as a new grid box entry? [y/n] ")

	# If "y" is entered, write the row, otherwise don't
	if proceed == "y":
		gridboxes_csv = "{b_d}Gridboxes.csv".format(b_d=base_dir)
		gridboxes_headers = ["Gridbox Name", "Protein", "Size in x-dimension",
			"Size in y-dimension", "Size in z-dimension", "Center in x-dimension",
			"Center in y-dimension", "Center in z-dimension", "Notes"]
		with open(gridboxes_csv, 'a') as f:
			appender = csv.DictWriter(f, fieldnames=gridboxes_headers)
			appender.writerow(new_row)
		print("\n\t>>> New row appended to Gridboxes.csv:\n\topen {}\n".format(gridboxes_csv))
	else:
		print("\n\t>>> No grid box entry written\n")

# Stuff below is commented because this script is being used as a module

# def main():
# 	parser = argparse.ArgumentParser(
# 		description='Write a new entry to Dockings.csv or Gridboxes.csv')
#
# 	parser.add_argument('-b', '--base_dir', metavar='BASE_DIR', type=str, nargs=1,
# 		help='The base directory containing Docking.csv and Gridboxes.csv')
# 	parser.add_argument('-d', '--new_docking', action='store_true', default=False,
# 		help='New set of docking parameters (written to Dockings.csv)')
# 	parser.add_argument('-g', '--new_gridbox', action='store_true', default=False,
# 		help='New set of grid box parameters (written to Gridboxes.csv)')
#
# 	args = vars(parser.parse_args())
# 	global base_dir
# 	base_dir = str(args['base_dir'][0])
# 	new_docking = args['new_docking']
# 	new_gridbox = args['new_gridbox']
#
# 	if new_docking: new_docking_entry()
# 	elif new_gridbox: new_gridbox_entry()
#
# if __name__ == "__main__": main()


