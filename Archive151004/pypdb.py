#!/usr/bin/env python

##
# 	(c) 10/3/15 9:42pm
# 	For ligands (HETATM), not proteins (ATOM)

import sys, re

script, pdb_file_in = sys.argv




# pdb, pdbqt, and pvrd_pdbqt

def file_type():
	print(pdb[-2:])


class Pdb:
	def pdb(self):
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
		print('hihi')

	def pdbqt(self):
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
# 		print('pdbqt')

	def pvrd(self):
		# Interactors
# 		for line in self.pdb_lines:
# 			print(line)
# 			if re.search('USER  AD> ', line):



		# Energy

		for line in self.pdb_lines:
# 			print(line)
# 			print('line')

# 			Energy
			if re.search('REMARK VINA RESULT: ', line):
				self.E = re.sub( r'^REMARK VINA RESULT:[ ]+|[ ]+[^ ]+[ ]+[^ ]+$' ,  r'' , line.replace('\n', '')) # [23:31].replace(" ", ""))
				self.E = float(self.E)
# 			RMSD_UB
			if re.search('REMARK VINA RESULT: ', line):
				self.rmsd_ub = re.sub( r'^REMARK VINA RESULT:[ ]+[^ ]+[ ]+|[ ]+[^ ]+$' ,  r'' , line.replace('\n', '')) # [23:31].replace(" ", ""))
				self.rmsd_ub = float(self.rmsd_ub)
# 			RMSD_LB
			if re.search('REMARK VINA RESULT: ', line):
				self.rmsd_lb = re.sub( r'^REMARK VINA RESULT:[ ]+[^ ]+[ ]+[ ]+[^ ]+' ,  r'' , line.replace('\n', '')) # [23:31].replace(" ", ""))
				self.rmsd_lb = float(self.rmsd_lb)


# 		print("pvrd")


	def get_type(self):
		pvrd = False
		pdbqt = False

		for line in self.pdb_lines:
			if re.search('REMARK VINA RESULT: ', line):
				self.pvrd()



		if pdb_file_in[-5:] == 'pdbqt':
			pdbqt = True

		if pvrd is True:
			self.pvrd()

		if pdbqt is True:
			self.pdbqt()
		elif pdbqt is False:
			self.pdb()
		else:
			print("!!! BAD FILETYPE !!!")

	def __init__(self, pdb):
		pdb_file_open = open(pdb_file_in)
		with pdb_file_open as f:
			self.pdb_lines = f.readlines()

		self.get_type()
# 		print('hi')


def main():
# 	file_type()
	p = Pdb(pdb_file_in)
	print(p.rmsd_lb)
# 	for a in p.coords: print(a)


if __name__ == "__main__": main()
