#!/usr/bin/env python

###
  #
  # (c) Zarek Siegel
  # created 2016/03/26
  #


import csv, re, argparse, time, datetime, sys
from collections import OrderedDict
from constants import *

class Timestamp():
	def __init__(self):
		time_obj = time.time()
		output = datetime.datetime.fromtimestamp(time_obj)
		self.display = output.strftime('%Y-%m-%d %H:%M:%S')
		self.eightdigit = output.strftime('%Y%m%d')
		self.twelvedigit = output.strftime('%Y%m%d%H%M')

global d_or_g
global entries_csv
global dict
global headers

headers = {

	# Dockings.csv columns:
	#	Docking ID
	#	Date
	#	Protein
	#	Protein File
	#	Ligset
	#	Gridbox
	#	Exhaustiveness
	#	Number of Models
	#	Number of CPUs
	#	Notes

	'dockings' : {
		'csv' : "{}/Dockings.csv".format(base_dir),
		'what' : 'docking',
		'list' : [
			{
				'col_name' : 'Docking ID',
				'table_header' : 'DOCKING ID',
				'description' : 'Docking identifier',
				'var_name' : 'dock',
				'var_input' : None
			},
			{
				'col_name' : 'Date',
				'table_header' : 'DATE',
				'description' : 'Date',
				'var_name' : 'date',
				'var_input' : None
			},
			{
				'col_name' : 'Protein',
				'table_header' : 'PROTEIN',
				'description' : 'Protein',
				'var_name' : 'prot',
				'var_input' : None
			},
			{
				'col_name' : 'Protein File',
				'table_header' : 'PROTEIN FILE',
				'description' :
					'Specific protein file (without the .pdbqt)',
				'var_name' : 'prot_file',
				'var_input' : None
			},
			{
				'col_name' : 'Ligset',
				'table_header' : 'LIGSET',
				'description' : 'Ligand set identifier',
				'var_name' : 'ligset',
				'var_input' : None
			},
			{
				'col_name' : 'Gridbox',
				'table_header' : 'GRIDBOX',
				'description' : 'Grid box identifier',
				'var_name' : 'box',
				'var_input' : None
			},
			{
				'col_name' : 'Exhaustiveness',
				'table_header' : 'EXH.',
				'description' : 'Exhaustiveness',
				'var_name' : 'exhaust',
				'var_input' : None
			},
			{
				'col_name' : 'Number of Models',
				'table_header' : 'n MODELS',
				'description' : 'Number of models',
				'var_name' : 'n_models',
				'var_input' : None
			},
			{
				'col_name' : 'Number of CPUs',
				'table_header' : 'n CPUs',
				'description' : 'Number of CPUs',
				'var_name' : 'n_cpus',
				'var_input' : None
			},
			{
				'col_name' : 'Notes',
				'table_header' : 'NOTES',
				'description' : 'Any notes (with no commas)',
				'var_name' : 'notes',
				'var_input' : None
			}
		]
	},

	# Gridboxes.csv columns:
	#	Gridbox Name
	#	Protein File
	#	Size in x-dimension
	#	Size in y-dimension
	#	Size in z-dimension
	#	Center in x-dimension
	#	Center in y-dimension
	#	Center in z-dimension
	#	Notes

	'gridboxes' : {
		'csv' : "{}/Gridboxes.csv".format(base_dir),
		'what' : 'grid box',
		'list' : [
			{
				'col_name' : 'Gridbox Name',
				'table_header' : 'GRIDBOX',
				'description' : 'Grid box name',
				'var_name' : 'box',
				'var_input' : None
			},
			{
				'col_name' : 'Protein File',
				'table_header' : 'PROTEIN FILE',
				'description' :
					'Specific protein file (without the .pdbqt)',
				'var_name' : 'prot_file',
				'var_input' : None
			},
			{
				'col_name' : 'Size in x-dimension',
				'table_header' : 'SIZE (x)',
				'description' : 'Size of grid box in x-dimension',
				'var_name' : 'box_size_x',
				'var_input' : None
			},
			{
				'col_name' : 'Size in y-dimension',
				'table_header' : 'SIZE (y)',
				'description' : 'Size of grid box in y-dimension',
				'var_name' : 'box_size_y',
				'var_input' : None
			},
			{
				'col_name' : 'Size in z-dimension',
				'table_header' : 'SIZE (z)',
				'description' : 'Size of grid box in z-dimension',
				'var_name' : 'box_size_z',
				'var_input' : None
			},
			{
				'col_name' : 'Center in x-dimension',
				'table_header' : 'CTR (x)',
				'description' : 'Center of grid box in x-dimension',
				'var_name' : 'box_center_x',
				'var_input' : None
			},
			{
				'col_name' : 'Center in y-dimension',
				'table_header' : 'CTR (y)',
				'description' : 'Center of grid box in y-dimension',
				'var_name' : 'box_center_y',
				'var_input' : None
			},
			{
				'col_name' : 'Center in z-dimension',
				'table_header' : 'CTR (z)',
				'description' : 'Center of grid box in z-dimension',
				'var_name' : 'box_center_z',
				'var_input' : None
			},
			{
				'col_name' : 'Notes',
				'table_header' : 'NOTES',
				'description' : 'Any notes (with no commas)',
				'var_name' : 'notes',
				'var_input' : None
			}
		]
	}
}

def load_entries(d_or_g):
	global dockings_dict
	dockings_dict = OrderedDict()


	global entries_csv
	global entries_dict
	entries_csv = headers[d_or_g]['csv']
	entries_dict = OrderedDict()

	entries_dict['header'] = {
		param['col_name'] : param['table_header'] \
			for param in headers[d_or_g]['list']
	}

	with open(entries_csv) as csvfile:
		reader = csv.DictReader(csvfile)
		for row in reader:
			entries_dict[row[headers[d_or_g]['list'][0]['col_name']]] = row


def print_all_entries(d_or_g):
	print('\n\tPrinting all {}:\n'.format(d_or_g))

	if d_or_g == 'dockings':
		row_template = (
			"{:<12} | " # Docking ID
			"{:<8} | " # Date
			"{:<8} | " # Protein
			"{:<16} | " # Protein File
			"{:<10} | " # Ligset
			"{:<8} | " # Gridbox
			"{:<4} | " # Exhaustiveness
			"{:<8} | " # Number of Models
			"{:<6}" # Number of CPUs
		)

		for entry, entry_dict in entries_dict.items():
			print(
				row_template.format(
					entry_dict['Docking ID'],
					entry_dict['Date'],
					entry_dict['Protein'],
					entry_dict['Protein File'],
					entry_dict['Ligset'],
					entry_dict['Gridbox'],
					entry_dict['Exhaustiveness'],
					entry_dict['Number of Models'],
					entry_dict['Number of CPUs']
				)
			)
	elif d_or_g == 'gridboxes':
		row_template = (
			"{:<12} | " # Docking ID
			"{:<16} | " # Protein File
			"{:<8} | " # Size in x-dimension
			"{:<8} | " # Size in y-dimension
			"{:<8} | " # Size in z-dimension
			"{:<8} | " # Center in x-dimension
			"{:<8} | " # Center in y-dimension
			"{:<8} | " # Center in z-dimension
			"{:<} " # Notes
		)

		for entry, entry_dict in entries_dict.items():
			print(
				row_template.format(
					entry_dict['Gridbox Name'],
					entry_dict['Protein File'],
					entry_dict['Size in x-dimension'],
					entry_dict['Size in y-dimension'],
					entry_dict['Size in z-dimension'],
					entry_dict['Center in x-dimension'],
					entry_dict['Center in y-dimension'],
					entry_dict['Center in z-dimension'],
					entry_dict['Notes']
				)
			)

	print('')

def print_one_entry(d_or_g, entry=None):
	what = headers[d_or_g]['what']
	if entry == None: entry = input('\n\t>>> Which {}? '.format(what))
	entry_dict = entries_dict[entry]
	print("\t>>> The parameters for {} '{}' are:".format(what, entry))

	for param in headers[d_or_g]['list']:
		col_name = param['col_name']
		print("\t\t{}: {}".format(col_name, entry_dict[col_name]))


def write_new_csv_entry(d_or_g, entry=None, edit=False):
	if edit == False: print("\n\t---> Adding a new {} entry\n".format(d_or_g))
	elif edit == True: print(
		"\n\t---> Editing entry in {}.csv\n"
		"\t\tFor each entry, enter new value then return,\n"
		"\t\tor only return to leave value as is\n".format(d_or_g.capitalize())
	)

	# New row as a dictionary
	new_row = {}

	for param in headers[d_or_g]['list']:
		var = param['var_name']
		var_input = param['var_input']
		description = param['description']
		col_name = param['col_name']

		if edit == False:
			if var == 'date':
				time = Timestamp().eightdigit
				var_input = input(
					"\t\t{} (enter 'd' to default to {}): ".format(
						description, time))
				if var_input == "d": var_input = time

			elif var == 'notes':
				time = Timestamp().display
				var_input = input("\t\t{}: ".format(description))
				if var_input == "":
					var_input = "Entered {}".format(time)
				else:
					var_input = "{} (Entered {})".format(var_input, time)

			else:
				var_input = input(
					"\t\t{}: ".format(description))

			print("\t\t>>> {} set to: {}\n".format(var, var_input))

		elif edit == True:
			old_value = entries_dict[entry][col_name]
			print("\t\t{} currently set to: '{}'".format(
				description, old_value))

			if var == 'date':
				time = Timestamp().eightdigit
				var_input = input(
					"\t\t> New entry (or blank, "
					"or 'd' to default to {}): ".format(time))
				if var_input == '': var_input = old_value
				else: var_input = var_input

			elif var == 'notes':
				time = Timestamp().display
				var_input = input(
					"\t\t> New entry (or blank, "
					"or 'd' to default to {}): ".format(time))
				if var_input == '': var_input = old_value
				else:
					var_input = "{} (Entered {})".format(var_input, time)

			else:
				var_input = input(
					"\t\t> New entry (or blank to leave as is): ")
				if var_input == '': var_input = old_value
				else: var_input = var_input

			print("\t\t>>> {} set to: {}\n".format(var, var_input))

		new_row[col_name] = var_input

	# Print confirmation of all entered variabled
	print("\t>>> The new row will be")
	for col_name in [param['col_name'] for param in headers[d_or_g]['list']]:
		print("\t\t{}: {}".format(col_name, new_row[col_name]))

	# Don't write row without confirmation
	if edit is True:
		proceed = input(
			"\n\t>>> Overwrite these parameters over the old ones? [y/n] ")
	else:
		proceed = input("\n\t>>> Record these parameters? [y/n] ")

	# If "y" is entered, write the row, otherwise don't
	if proceed == "y":
		col_headers = [param['col_name'] for param in headers[d_or_g]['list']]

		with open(entries_csv, 'a') as csvfile:
			appender = csv.DictWriter(csvfile, fieldnames=col_headers)
			appender.writerow(new_row)
		if edit is True:
			print(
				"\n\t>>> Edited row appended to {}.csv:"
				"\n\topen {}\n".format(d_or_g.capitalize(), entries_csv)
			)
		else:
			print(
				"\n\t>>> New row appended to {}.csv:"
				"\n\topen {}\n".format(d_or_g.capitalize(), entries_csv)
			)
	else:
		if edit is True: print("\n\t>>> {}.csv entry left unedited\n".format(
			d_or_g.capitalize()))
		else: print("\n\t>>> Nothing written to {}.csv\n".format(
			d_or_g.capitalize()))

def edit_entry(d_or_g):
	what = headers[d_or_g]['what']
	entry = input('\n\t>>> Which {}? '.format(what))
	# print_one_entry(d_or_g, entry=entry)
	write_new_csv_entry(d_or_g, edit=True, entry=entry)

def delete_entry(d_or_g):
	what = headers[d_or_g]['what']
	entry = input('\n\t>>> Which {}? '.format(headers[d_or_g]['what']))
	keep_lines = []
	del_lines = []
	with open(entries_csv, 'r') as f:
		entries_csv_lines = f.readlines()
		for line in entries_csv_lines:
			if re.search('^'+entry+',', line):
				del_lines.append(line)
			else:
				keep_lines.append(line)

	print("\n\t> Going to delete the following row(s):")
	for line in del_lines: print("\t\t{}".format(re.sub('\n', '', line)))
	proceed = input("\n\t>>> Are you sure you want to proceed? [y/n] ")
	if proceed == 'y':
		print("\n\t> OK, deleting {} {} from {}.csv".format(
			what, entry, d_or_g.capitalize()))
		with open(entries_csv, 'w') as f:
			for line in keep_lines:
				f.write(line)
		deleted_entries_csv = re.sub('.csv$', '_deleted_rows.csv', entries_csv)
		with open(deleted_entries_csv, 'a') as f:
			for line in del_lines:
				f.write(line)
	else:
		print("\n\t> OK, leaving {} {} in {}.csv".format(
			what, entry, d_or_g.capitalize()))

def dockings_and_gridboxes():
	print("\n\t>>> Greetings! This script will let you do several things...\n")

	choices = (
		"\t    Here are your options:\n"
		"\t\t[d] View all docking parameters in Dockings.csv\n"
		"\t\t[g] View all grid box parameters in Gridboxes.csv\n"
		"\t\t[rd] Read a specific set of docking parameters in Dockings.csv\n"
		"\t\t[rg] Read a specific set of grid box parameters in Gridboxes.csv\n"
		"\t\t[wd] Add/overwrite set of docking parameters to Dockings.csv\n"
		"\t\t[wg] Add/overwrite set of grid box parameters to Gridboxes.csv\n"
		"\t\t[dd] Delete a set of docking parameters from Dockings.csv\n"
		"\t\t[dg] Delete a set of grid box parameters from Gridboxes.csv\n"
		"\t\t[ed] Edit a set docking parameters in Dockings.csv\n"
		"\t\t[eg] Edit a set of grid box parameters in Gridboxes.csv\n"
		"\t\t[x] or [q] Exit\n"
		"\n\tPlease type the appropriate letters and then enter: "
	)

	dockings_choices = ['d', 'rd', 'wd', 'dd', 'ed']
	gridboxes_choices = ['g', 'rg', 'wg', 'dg', 'eg']
	valid_choices = dockings_choices + gridboxes_choices + ['x', 'q']


	global dockings_csv

	dockings_csv = "{b_d}/Dockings.csv".format(b_d=base_dir)

	time_to_exit = False

	def make_a_choice(what_to_do=None):
		what_to_do = input(choices)
		while what_to_do not in valid_choices:
			print("\n\t>>> '{}' is an invalid choice".format(
				what_to_do))
			what_to_do = input(choices)

		if what_to_do == 'x' or what_to_do == 'q':
			sys.exit("\n\t> OK, exiting this script\n")

		return what_to_do

	def execute_choice(what_to_do):
		if what_to_do in dockings_choices:
			d_or_g = 'dockings'
		elif what_to_do in gridboxes_choices:
			d_or_g = 'gridboxes'

		load_entries(d_or_g)

		if what_to_do in ['d', 'g']:
			print_all_entries(d_or_g)
		elif what_to_do in ['rd', 'rg']:
			print_one_entry(d_or_g)
		elif what_to_do in ['wd', 'wg']:
			write_new_csv_entry(d_or_g)
		elif what_to_do in ['ed', 'eg']:
			edit_entry(d_or_g)
		elif what_to_do in ['dd', 'dg']:
			delete_entry(d_or_g)

	what_now_text = (
		'\n\t>>> What now? \n'
		'\t\tEnter an option from (as listed before)\n'
		'\t\tEnter nothing to list options again\n'
		'\t\tEnter [x] or [q] to exit\n\n\t\t'
	)

	global what_to_do


	choice = make_a_choice()
	execute_choice(choice)

	while time_to_exit is False:
		what_now = input(what_now_text)
		if what_now == 'q' or what_now == 'x':
			time_to_exit = True
		else:
			time_to_exit = False
			if what_now in valid_choices:
				choice = what_now
			else:
				choice = make_a_choice()
			execute_choice(choice)

	sys.exit("\n\t> OK, exiting this script\n")


# 	load_entries()
# 	print_all_entries()
# 	print_one_entry()
# 	write_new_csv_entry()




