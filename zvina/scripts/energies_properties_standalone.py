#!/usr/bin/env python

###
# (c) Zarek Siegel
# v1 3/16/16
# updated 7/20/16

# This script requires Python 3.2 or newer
import sys
py_maj = sys.version_info[0]
py_min = sys.version_info[1]
if py_maj < 3 or (py_maj == 3 and py_min < 2):
	print("!!! This script requires Python version 3 "
		"(you're using {}.{})".format(py_maj, py_min))
	sys.exit(1)

import argparse, subprocess, re, csv
from collections import OrderedDict

################################################################################

# If as part of zvina/scripts, use the obprop binary listed in constants.py
import constants
OPENBABEL_BINARIES_DIR = constants.openbabel_binaries_dir
# To specify a different binary, comment the 2 lines above, and
#		uncomment the line below (and edit it if necessary)
# OPENBABEL_BINARIES_DIR = "/usr/local/bin"

OBENERGY_BINARY = "{}/obenergy".format(OPENBABEL_BINARIES_DIR)
OBPROP_BINARY = "{}/obprop".format(OPENBABEL_BINARIES_DIR)

################################################################################

def get_energies(molc_in):
	obenergy_out = subprocess.Popen([OBENERGY_BINARY, molc_in],
		stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	obenergy_out = obenergy_out.communicate()[0].decode('ascii')
	obenergy_out = re.split('\n', obenergy_out)

	# print((obenergy_out))
	# print(type(obenergy_out))

	#      TOTAL BOND STRETCHING ENERGY =   28.617 kJ/mol
	#      TOTAL ANGLE BENDING ENERGY =   18.099 kJ/mol
	#      TOTAL TORSIONAL ENERGY =   62.835 kJ/mol
	#      TOTAL VAN DER WAALS ENERGY =  104.782 kJ/mol
	#
	# TOTAL ENERGY = 214.33290 kJ/mol

	obenergy_dic = {}

	def extract_energy_value(search_str):
		for row in obenergy_out:
			if re.search(search_str, row):
				value = (re.sub(r'^\s*([\w ]+)=\s*(-?\d+\.\d+)\s+(.+)$', r'\2', row))
				units = (re.sub(r'^\s*([\w ]+)=\s*(-?\d+\.\d+)\s+(.+)$', r'\3', row))
		return value#, units

	search_str_list = [
		"TOTAL BOND STRETCHING ENERGY",
		"TOTAL ANGLE BENDING ENERGY",
		"TOTAL TORSIONAL ENERGY",
		"TOTAL ENERGY"
	]

	for search_str in search_str_list:
		parameter = search_str.lower()
		parameter = re.sub(' ', '_', parameter)
		obenergy_dic[parameter] = extract_energy_value(search_str)

	return obenergy_dic

# -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - #

def get_properties(molc_in):
	obprop_out = subprocess.Popen([OBPROP_BINARY, molc_in],
		stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	obprop_out = obprop_out.communicate()[0].decode('ascii')
	obprop_out = re.split('\n', obprop_out)

	# name             /Users/zarek/lab/zvina/ligsets/hls1/pdbs/ab.pdb 1
	# formula          C6H12O6
	# mol_weight       180.156
	# exact_mass       180.063
	# canonical_SMILES OC[C@H]1O[C@@H](O)[C@@H]([C@H]([C@H]1O)O)O
	#
	# InChI            InChI=1S/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3+,4+,5-,6-/m1/s1
	#
	# num_atoms        24
	# num_bonds        24
	# num_residues     1
	# sequence         LIG
	# num_rings        1
	# logP             -3.2214
	# PSA              110.38
	# MR               35.736

	obprop_dic = {}

	def extract_property_value(search_str):
		for row in obprop_out:
			if re.search(search_str, row):
		# 		print(row)
				value = (re.sub(r'^(\w+)\s+(\S+)\s?\S?$', r'\2', row))
		return value

	search_str_list = [
		"name", "formula", "mol_weight",
		"exact_mass", "canonical_SMILES", "num_atoms",
		"num_bonds", "num_rings", "logP", "PSA", "MR"
	]

	for search_str in search_str_list:
		parameter = search_str
		obprop_dic[parameter] = extract_property_value(search_str)

	return obprop_dic


################################################################################

def print_dict(dict):
	print("\n{0:.<36}{v}".format("PROPERTY", v="VALUE"))
	for prop, value in dict.items():
		print("{0:.<36}{v}".format(prop, v=value))
	print("")

def write_csv_header(dict, csv_out):
	with open(csv_out, 'w') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames=dict.keys())
		writer.writeheader()

def write_csv_row(dict, csv_out):
	with open(csv_out, 'w') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames=dict.keys())
		writer.writerow(dict)

################################################################################

def main():
	parser = argparse.ArgumentParser(
		description=(
			"Get energies and/or properties for molecule files. "
			"Notes: Files must be OpenBabel compatible formats "
			"(see <http://openbabel.org/wiki/Babel> for a list). "
			"Paths must be absolute (not relative to working directory). "
			"You must specify 1) either '-f <file>' or '-d <dir>', "
			"2) '-t' and/or '-c <file>', and "
			"3) '-e' and/or '-p' (descriptions below)."
		)
	)

	parser.add_argument('-f', '--file_in', metavar='FILE_IN', type=str,
		nargs='?', default=None,
		help='the input molecule to analyze')
	parser.add_argument(
		'-d', '--dir_in', metavar='DIR_IN', type=str, nargs='?', default=None,
		help=(
			'the directory of input molecules to analyze '
			'(must contain analyzable molecule files and nothing else)'
		)
	)

	parser.add_argument('-t', '--print', action='store_true', default=False,
		help='print output to the console')
	parser.add_argument('-c', '--csv_out', metavar='CSV_OUT', type=str,
		nargs='?', default=None,
		help='path to the CSV to write (will overwrite an existing file)')

	parser.add_argument(
		'-e', '--energy', action='store_true', default=False,
		help=(
			'predict energies for the input molecule(s) using obenergy '
			'(see <http://openbabel.org/wiki/obenergy> for details)'
		)
	)
	parser.add_argument(
		'-p', '--props', action='store_true', default=False,
		help=(
			'predict properties for the input molecule(s) using obprop '
			'(see <http://openbabel.org/wiki/obprop> for details)'
		)
	)
	args = vars(parser.parse_args())
	# print(args)

	def get_output_dict(molc_in):
		global output_dict
		output_dict = OrderedDict()
		global headers
		headers = []

		if not args['energy'] and not args['props']:
			print("You must specify either -e, -p, or both (-h for help)")
			sys.exit(1)
		if args['energy']:
			en_dict = get_energies(molc_in)
			for k,v in en_dict.items():
				output_dict[k] = v
				headers.append(k)
		if args['props']:
			pr_dict = get_properties(molc_in)
			for k,v in pr_dict.items():
				output_dict[k] = v
				headers.append(k)

		if args['dir_in'] is not None: headers = ["file"] + headers

	if args['file_in'] is None and args['dir_in'] is None:
		print("You must specify either -f or -d (-h for help)")
		sys.exit(1)
	elif args['file_in'] is not None and args['dir_in'] is not None:
		print("You must specify either -f or -d, not both (-h for help)")
		sys.exit(1)
	elif args['file_in'] is not None and args['dir_in'] is None:
		molc_in = args['file_in']
		print("Analyzing the file {}".format(molc_in))
		get_output_dict(molc_in)
		# print(output_dict)
	elif args['file_in'] is None and args['dir_in'] is not None:
		dir_in = args['dir_in']
		print("Analyzing the directory {}".format(dir_in))
		if dir_in[-1] != '/': dir_in = dir_in + '/'
		# print(dir_in)
		file_list = subprocess.Popen(["ls", dir_in],
			stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		file_list = file_list.communicate()[0].decode('ascii')
		file_list = file_list.split('\n')
		file_list = [file for file in file_list if file != '']

		output_dicts_dict = OrderedDict()
		for file in file_list:
			molc_in = dir_in + file
			get_output_dict(molc_in)
# 			print_dict(output_dict)
			output_dict["file"] = file
			output_dicts_dict[file] = output_dict
			print("Analyzed {}".format(file))
		# print(output_dicts_dict)

	if args['print']:
		print()
		if args['file_in'] is not None:
			print_dict(output_dict)
		elif args['dir_in'] is not None:
			for file in file_list:
				print(file)
				print_dict(output_dicts_dict[file])

	if args['csv_out'] is not None:
		csv_out = args['csv_out']
		csv_file = open(csv_out, 'w')
		writer = csv.DictWriter(csv_file, fieldnames=headers)
		writer.writeheader()
		# Write CSV if single file
		if args['file_in'] is not None: writer.writerow(output_dict)
		# Write CSV if whole directory
		if args['dir_in'] is not None:
			for file in file_list:
				writer.writerow(output_dicts_dict[file])
		print("Output CSV is located at {}".format(csv_out))

	if not args['print'] and args['csv_out'] is None:
		print('Use option -t and/or -w <csv_out> (-h for help)')

if __name__ == "__main__": main()
