#!/bin/bash

~~~0: KEY~~~
~PARAMETERS~	
	DOCK: $d - the unique dock ID given to each docking
		-Named as x#, where x indicates the protein and # is the number
			eg. p21 is the 21st p300 docking
			{p: p300, h: hepi}
	PROT: $p - 
		{p300, hepi}
	SPECPROT: $s - 
		{p300: {p300},
		 hepi: {h1, h1a, h1f, h1af 
		  	    h1c, h1ca, h1cf, h1caf}}
	LIG: **
	BOX: **
		BOXTEXT: **
	LIGSET: **
		LSTEXT: **
	MODEL:  **
		nM
	RES: ** result/collection of 9 outputted
	PATH: /Users/zarek/lab/Docking/PROT = ~/lab/Docking/PROT/ = path/
~DOCKINGPROPERTIES~
	E:
	rmsd_ub:
	rmsd_lb:
	***
~COMMENTSKEY~
	[FILESatp]: denotes the files that exist at this point in the process
					(only the ones that are still relevant)
	<file> a file
	[in]: files required by a step/script
	[out]: files produced by a step/script
	[irrel]: files no longer of use
	*** - expand explanationg
	** - fill in comments
	*>* - fill in command
	!!! - place to change procedure
	nLS - number of ligands in ligset
		nLS * - for each ligand in the ligset, the following
	nM - number of models ** (default 9)
~FILESENCOUNTERED~
	<log.txt> (*nLS)
	<res.pdbqt> (*nLS)
	<dock_logs.csv> 
	<res_pvrd.pdbqt> (*nLS *nM)

~~~~~~~~~~~~~~~~~~~~~~~~~

~~~0.5: BEFOREHAND~~~
	Download files to computer into proper directories:
		/Users/zarek/lab/PROT/DOCK/results/
			containing result pdbqts:
				<.../results/DOCK_LIG_results.pdbqt>
				(older files: .../results/DOCK-LIG-results.pdbqt)
		/Users/zarek/lab/PROT/DOCK/logs/
			containing result log files:
				<.../results/DOCK_LIG_log.txt>
				(older files: .../results/DOCK-LIG-log.txt)
			lists binding energy+2rmsd values (relative to best) model
				for each model of the docking (9 by default)

[FILESatp]: 
	For each ligand in the ligset:
		<res.pdbqt>: path/DOCK/results/DOCK_LIG_results.pdbqt
			each file containing 9 models of one ligand in one box
				positional/charge info for each atom
		<log.txt>: path/DOCK/logs/results/DOCK_LIG_log.txt
				binding energy+2rmsd values for each of 9 models 

~0.9: STATING OUR PARAMETERS~
DOCK="p20"
PROT="p300"
...***


~~~~~~~~~~~~~~~~~~~~~~~~~

~~~1: EXTRACTING BINDING ENERGIES FROM LOG FILES~~~
~1.1: grep-pld
	***
	[in]: nLS * <log.txt>
	[out]: 1* <dock_logs.csv>: path/vinaresults/DOCK_results.csv
				contains basic results data for all models of all ligs in ligset
					 dock,lig,model,E,rmsd_lb,rmsd_ub
					 p24,fccc1_1,1,-4.6,0.000,0.000
		!!! put this file elsewhere?
*>*

[FILESatp]: 
	nLS* <res.pdbqt>
	1*   <dock.csv> 
		
		
		
		
0 dock
1 grep-pld: pull out log data into csv
2 pvr res.pdbqts -> 9* 
3 pull out (of pvrd.csv) contacts and such
 pull out ligand properties
 process pdbqts into csvs

------------------------------------------------------

/dock
	/results
		/DOCK_LIG_results.pdbqt *nLS
	/logs
		/DOCK_LIG_log.txt *nLS
	/pvrd
		/DOCK_LIG_mMODEL.pdbqt *nLS *nM
	/res_data
		/DOCK_LIG_mMODEL.txt *nLS *nM
	/res_csvs
		/DOCK_LIG_mMODEL.csv *nLS *nM
	/DOCK_data.csv *1
	
~FILESENCOUNTERED~
	<log.txt> (*nLS)
	<res.pdbqt> (*nLS)
	<dock_logs.csv> 
	<res_pvrd.pdbqt> (*nLS *nM)
	<dock_pvrd.csv>
	
	<props.txt> 
	<data.csv>
	
	
~POPULATIONDATA~
	key [0] (DOCK_LIG_mMODEL)
run_parameters
	dock [0]
	prot [0]
	specprot [0]
	lig [0]
	ligset [0]
	box [0]
	exhaust [0]
	model [1]
	?n_models
	res_pdbqt_path
	pvrd_pdbqt_path
	specprot_pdbqt_path
	?other paths
	??cpus? time to run?
lig_props
	lig_form (molecular formula)
	lig_weight (molecular weight)
	lig_smiles
	lig_nbonds (# of bonds)
	lig_natoms (# of atoms)
	lig_logp
	lig_psa (polar surface area)
	lig_mr (molar refractivity)
vina_out
	E
	rmsd_ub
	rmsd_lb
contacts
	pvr_contacts
	pvr_resis
	pvr_resis_atoms
	pvr_ligeffic
	(hbp_hb resi, atoms, distances, donor/acceptor, etc.)
binding_site
	aiad_XYZ *substrates/otherligs/residues/sites
	icpd_XYZ *substrates/otherligs/residues/sites/points
	resscore_XYZ *substrate (from pvr, or hbp)
	resfraction_XYZ *substrate (from pvr, or hbp)
?others?
	?torsional DoF
	?average E for lig
	?other scoring algorithms
in_vitro...
in_vivo...

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

clipboard: 

[FILESatp]: 

	[in]: 
	[out]: 
	[irrel]: 









