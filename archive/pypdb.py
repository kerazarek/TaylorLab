#!/usr/bin/env python

##################################################
###	PYTHONICALLY READ PDB(QT) FILES
##################################################
# (c) Zarek Siegel
# created 10/03/15 21:42
#
#
# 		For single molecules
#
#
# updated 10/04/15 16:42
#
#

import sys, re

script, pdb_file_in = sys.argv

class Residue:
	def __init__(self, str):
# 		String
		self.str = str
# 		Atom & Residue String
		if re.search(r'^[A-Z]+[0-9]+$', self.str):
			self.atom = None
			self.res_str = self.str
		elif re.search(r'^[A-Z]+[0-9]+_.+$', self.str):
			self.atom = re.sub(r'^[A-Z]+[0-9]+_', '', self.str)
			self.res_str = re.sub(r'_[A-Z0-9]+$', '', self.str)
		else: self.atom = None
# 		Residue Index
		self.resi = re.sub(r'^[A-Z]+|_?[^_]*$', '', self.str)
		try:
			self.resi = int(self.resi)
		except ValueError:
			self.resi = None
# 		Residue Name
		self.resn = re.sub(r'[0-9]+_?[^_]*$', '', self.str)
# 		Dictionary of Props
		self.dic = {'str' : self.str, 'res_str' : self.res_str,
			'resi' : self.resi, 'resn' : self.resn, 'atom' : self.atom}

	def __str__(self):
		return self.str

class Pdb:
	def pdb(self):
		print('PDB file')
		coords = []
		for line in self.pdb_lines:
			if re.search('HETATM', line) or (re.search('ATOM', line)):
				dic = {
					'atomi' : int(line[6:11]),
					'atomn' : line[12:16].replace(" ", ""),
					'resn' : line[17:20].replace(" ", ""),
					'resi' : (line[22:26]),
					'x' : float(line[30:38]),
					'y' : float(line[38:46]),
					'z' : float(line[46:54]),
					'xyz' : (float(line[30:38]), float(line[38:46]), float(line[46:54]) ),
					'atom_type' : line[76:78].replace(" ", ""),
					'charge' : line[78:80].replace(" ", "") # element
				}
				coords.append(dic)
		self.coords = coords

	def pdbqt(self):
		print('PDBQT file')
		coords = []
		for line in self.pdb_lines:
# 			print(line)
			if re.search('HETATM', line) or (re.search('ATOM', line)):
				dic = {
					'atomi' : int(line[6:11]),
					'atomn' : line[12:16].replace(" ", ""),
					'resn' : line[17:20].replace(" ", ""),
					'resi' : (line[22:26]),
					'x' : float(line[30:38]),
					'y' : float(line[38:46]),
					'z' : float(line[46:54]),
					'xyz' : (float(line[30:38]), float(line[38:46]), float(line[46:54]) ),
					'charge' : line[70:76].replace(" ", ""), # partial charge
					'atom_type' : line[77:79].replace(" ", "") # AD4 atom type
				}
				coords.append(dic)
		self.coords = coords

	def pvrd(self): # mine data from pvrd file
		print('File has been through ADT process_VinaResult.py')
		contacts = []
		for line in self.pdb_lines:
# 			Energy
			if re.search('REMARK VINA RESULT: ', line):
				self.E = re.sub( r'^REMARK VINA RESULT:[ ]+|[ ]+[^ ]+[ ]+[^ ]+$' ,
					r'' , line.replace('\n', '')) # [23:31].replace(" ", ""))
				self.E = float(self.E)
# 			RMSD_UB
			if re.search('REMARK VINA RESULT: ', line):
				self.rmsd_ub = re.sub( r'^REMARK VINA RESULT:[ ]+[^ ]+[ ]+|[ ]+[^ ]+$' ,
					r'' , line.replace('\n', '')) # [23:31].replace(" ", ""))
				self.rmsd_ub = float(self.rmsd_ub)
# 			RMSD_LB
			if re.search('REMARK VINA RESULT: ', line):
				self.rmsd_lb = re.sub( r'^REMARK VINA RESULT:[ ]+[^ ]+[ ]+[ ]+[^ ]+' ,
					r'' , line.replace('\n', '')) # [23:31].replace(" ", ""))
				self.rmsd_lb = float(self.rmsd_lb)
# 			Contacts
			if re.search(r'^USER  AD> [^ ]+:[^ ]+:[^ ]+:[^ ,]+$', line):
				contacts.append(line.replace('\n', '').replace('USER  AD> ', ''))

# 		Contacts Processing
		self.pvr_resis_objs = []
		self.pvr_resis = []
		self.pvr_resis_atoms = []
		for c in contacts:
			self.pvr_resis_objs.append(Residue(re.sub(r'^[^:]+:[^:]+:', '',
				c).replace(':', '_')))

		for r in self.pvr_resis_objs:
# 			print(r.dic)
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
			'pvr_resis_objs' : self.pvr_resis_objs
		}

	def get_type(self):
# 		Detect if its been through ADT process_VinaResult.py
		self.is_pvrd = False # by default
		for line in self.pdb_lines:
			if re.search('REMARK VINA RESULT: ', line):
				self.pvrd()
				self.is_pvrd = True

# 		Determine file type PDB/PDBQT (they are slightly different)
		if pdb_file_in[-5:] == 'pdbqt':
			self.pdbqt()
			self.file_type = 'pdbqt'
		elif pdb_file_in[-3:] == 'pdb':
			self.pdb()
			self.file_type = 'pdb'
		else:
			print("!!! BAD FILETYPE !!!")

	def __init__(self, pdb):
		pdb_file_open = open(pdb_file_in)
		with pdb_file_open as f:
			self.pdb_lines = f.readlines()

		self.get_type()

def main():
	p = Pdb(pdb_file_in)
	print(p.pvr_data)
# 	for a in p.coords: print(a)

if __name__ == "__main__": main()
