#!/usr/bin/env python

###
# (c) Zarek Siegel
# v1 3/16/16

import subprocess, re, sys
from constants import *

##########

def get_energies(molc_in):
	obenergy_binary = "{}/obenergy".format(openbabel_binaries_dir)

	obenergy_out = subprocess.Popen([obenergy_binary, molc_in],
		stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	obenergy_out = obenergy_out.communicate()[0]
	obenergy_out = re.split('\n', obenergy_out)

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
# 				print(row)
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
##########

##########

def get_properties(molc_in):
	obprop_binary = "{}/obprop".format(openbabel_binaries_dir)

	obprop_out = subprocess.Popen([obprop_binary, molc_in],
		stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	obprop_out = obprop_out.communicate()[0]
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
##########

def get_combined_dic(molc_in):
	combined_dic = dict(get_energies(molc_in).items() + \
		get_properties(molc_in).items())
	return combined_dic

def print_energies_properties(molc_in):
	print("\n{0:.<36}{v}".format("PROPERTY", v="VALUE"))
	for prop, value in get_combined_dic(molc_in).items():
		print("{0:.<36}{v}".format(prop, v=value))

def main():
	print_energies_properties(sys.argv[1])

if __name__ == "__main__": main()
