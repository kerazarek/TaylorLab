#!/usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16

# from parse_pdbqt import *
import parse_pdbqt

def main():
	infile = "/Users/zarek/GitHub/TaylorLab/zvina/hepi/h11/processed_pdbqts/h11_aa8_m1.pdbqt"
	thing = parse_pdbqt.Pdb(infile)
	print(thing.pvr_model)

if __name__ == "__main__": main()