#!/usr/bin/env python

### Parsing data from processed pdbqt result files
# (c) Zarek Siegel
# v1 3/5/16

import re

### A class for residues and residue atoms
#		(input is a string of form 'RES123' or 'RES123_A1')

class Residue:
	def __init__(self, str):
		# String
		self.str = str
		# Atom & Residue String
		if re.search(r'^[A-Z]+[0-9]+$', self.str):
			self.atom = None
			self.res_str = self.str
		elif re.search(r'^[A-Z]+[0-9]+_.+$', self.str):
			self.atom = re.sub(r'^[A-Z]+[0-9]+_', '', self.str)
			self.res_str = re.sub(r'_[A-Z0-9]+$', '', self.str)
		else: self.atom = None
		# Residue Index
		self.resi = re.sub(r'^[A-Z]+|_?[^_]*$', '', self.str)
		try:
			self.resi = int(self.resi)
		except ValueError:
			self.resi = None
		# Residue Name
		self.resn = re.sub(r'[0-9]+_?[^_]*$', '', self.str)
		# Dictionary of Props
		self.dic = {'str' : self.str, 'res_str' : self.res_str,
			'resi' : self.resi, 'resn' : self.resn, 'atom' : self.atom}
	def __str__(self):
		return self.str

### A class for molecules, including ones with data from process_VinaResult.py
#		(input is a .pdb or .pdbqt file address which may or may not be pvr'd)

class Pdb:
	def get_pdb_coords(self):
		_coords = []
		for line in self.pdb_lines:
			if re.search('HETATM', line) or (re.search('ATOM', line)):
				_dic = {
					'atomi' : int(line[6:11]),
					'atomn' : line[12:16].replace(" ", ""),
					'resn' : line[17:20].replace(" ", ""),
					'resi' : line[22:26].replace(" ", ""),
					'x' : float(line[30:38].replace(" ", "")),
					'y' : float(line[38:46].replace(" ", "")),
					'z' : float(line[46:54].replace(" ", "")),
					'xyz' : (float(line[30:38].replace(" ", "")),
						float(line[38:46].replace(" ", "")),
						float(line[46:54].replace(" ", "")) ),
					'atom_type' : line[76:78].replace(" ", ""),
					'charge' : line[78:80].replace(" ", "") # element
				}
				_coords.append(_dic)
		self.coords = _coords

	def get_pdbqt_coords(self):
		_coords = []
		for line in self.pdb_lines:
			if re.search('HETATM', line) or (re.search('ATOM', line)):
				_dic = {
					'atomi' : int(line[6:11]),
					'atomn' : line[12:16].replace(" ", ""),
					'resn' : line[17:20].replace(" ", ""),
					'resi' : line[22:26].replace(" ", ""),
					'x' : float(line[30:38].replace(" ", "")),
					'y' : float(line[38:46].replace(" ", "")),
					'z' : float(line[46:54].replace(" ", "")),
					'xyz' : (float(line[30:38].replace(" ", "")),
						float(line[38:46].replace(" ", "")),
						float(line[46:54].replace(" ", "")) ),
					'charge' : line[70:76].replace(" ", ""), # partial charge
					'atom_type' : line[77:79].replace(" ", "") # AD4 atom type
				}
				_coords.append(_dic)
		self.coords = _coords

	def mine_pvr_data(self): # mine data from pvrd file
		contacts = []
		for line in self.pdb_lines:
			# Binding Energy
			if re.search('REMARK VINA RESULT: ', line):
				self.E = re.sub( r'^REMARK VINA RESULT:[ ]+|[ ]+[^ ]+[ ]+[^ ]+$' ,
					r'' , line.replace('\n', '')) # [23:31].replace(" ", ""))
				self.E = float(self.E)
			# RMSD Lower Bound
			if re.search('REMARK VINA RESULT: ', line):
				self.rmsd_lb = re.sub( r'^REMARK VINA RESULT:[ ]+[^ ]+[ ]+|[ ]+[^ ]+$' ,
					r'' , line.replace('\n', ''))
				self.rmsd_lb = float(self.rmsd_lb)
			# RMSD Upper Bound
			if re.search('REMARK VINA RESULT: ', line):
				self.rmsd_ub = re.sub( r'^REMARK VINA RESULT:[ ]+[^ ]+[ ]+[ ]+[^ ]+' ,
					r'' , line.replace('\n', ''))
				self.rmsd_ub = float(self.rmsd_ub)
			# Ligand Efficiency (whatever that means...)
			if re.search('USER  AD>  ligand efficiency', line):
				self.pvr_effic = re.sub( r'USER  AD>  ligand efficiency' ,
					r'' , line.replace('\n', ''))
				self.pvr_effic = float(self.pvr_effic)
			# Model Number
			if re.search(r'USER  AD> .+ of .+ MODELS', line):
				self.pvr_model = re.sub( r'USER  AD>| of [0-9]+ MODELS' ,
					r'' , line.replace('\n', ''))
				self.pvr_model = int(self.pvr_model)
			# Torsional Degrees of Freesom
			if re.search('REMARK .+ active torsions:', line):
				self.torsdof = re.sub( r'REMARK|active torsions:' ,
					r'' , line.replace('\n', ''))
				self.torsdof = int(self.torsdof)
			# Number of Contacts
			if re.search('USER  AD> macro_close_ats:', line):
				self.macro_close_ats = re.sub( r'USER  AD> macro_close_ats:' ,
					r'' , line.replace('\n', ''))
				self.macro_close_ats = int(self.macro_close_ats)
			# Contacts
			if re.search(r'^USER  AD> [^ ]+:[^ ]+:[^ ]+:[^ ,]+$', line):
				contacts.append(line.replace('\n', '').replace('USER  AD> ', ''))

		# Contacts Processing
		self.pvr_resis_objs = []
		self.pvr_resis = []
		self.pvr_resis_atoms = []
		for c in contacts:
			self.pvr_resis_objs.append(Residue(re.sub(r'^[^:]+:[^:]+:', '',
				c).replace(':', '_')))

		for r in self.pvr_resis_objs:
			if r.atom != None:
				self.pvr_resis_atoms.append(r.str)
				self.pvr_resis.append(r.res_str)
			else:
				self.pvr_resis_atoms.append(None)
				self.pvr_resis.append(r.res_str)

		self.pvr_resis_objs = list(set(self.pvr_resis_objs)) # remove duplicates
		self.pvr_resis = list(set(self.pvr_resis))
		self.pvr_resis_atoms = list(set(self.pvr_resis_atoms))

		self.pvr_data = {
			'E' : self.E,
			'rmsd_ub' : self.rmsd_ub,
			'rmsd_lb' : self.rmsd_lb,
			'pvr_resis' : self.pvr_resis,
			'pvr_resis_atoms' : self.pvr_resis_atoms,
			'pvr_resis_objs' : self.pvr_resis_objs,
			'torsdof' : self.torsdof,
			'macro_close_ats' : self.macro_close_ats,
			'pvr_model' : self.pvr_model
		}

	def res_list(self, atoms = False):
		list = []
		if atoms is False:
			for atom in self.coords:
				list.append(atom['resn']+atom['resi'])
		elif atoms is True:
			for atom in self.coords:
				list.append(atom['resn']+atom['resi']+"_"+atom['atomn'])

		nodup_list = set(list)
		reslist = []
		for n in nodup_list:
			reslist.append(n)
		return reslist

	def get_types(self):
		# Detect if its been through ADT process_VinaResult.py
		self.is_pvrd = False # by default
		for line in self.pdb_lines:
			if re.search('REMARK VINA RESULT: ', line):
				self.mine_pvr_data()
				self.is_pvrd = True

		# Determine file type PDB/PDBQT (they are slightly different)
		if self.pdb_file_in[-5:] == 'pdbqt':
			self.get_pdbqt_coords()
			self.file_type = 'pdbqt'
		elif self.pdb_file_in[-3:] == 'pdb':
			self.get_pdb_coords()
			self.file_type = 'pdb'
		else:
			print("!!! BAD FILETYPE !!!")

	def __init__(self, pdb_file_in):
		# Specify input file
		self.pdb_file_in = pdb_file_in
		# Try to read it, else error
		try:
			pdb_file_open = open(pdb_file_in)
			with pdb_file_open as f:
				self.pdb_lines = f.readlines()
		except IOError:
			print("! ! ! IOError")
			pass
		# Determine if PDB or PDBQT, and whether it has been through process_VinaResult.py
		self.get_types() # this also mines the actual data




