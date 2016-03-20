#!/usr/bin/env python

### Putting together all parsed data from processed vina results
# (c) Zarek Siegel
# v1 3/5/16 (as assemble_alldata.py)
# v2 3/6/16

from __future__ import print_function
import subprocess, os, sys
from constants import *
from create_docking_object import * # Docking

def write_vina_submit_sh(self):
	# (no need for batch submission)
	if self.n_models <= 20:
		batch_submission = False
		vina_submit_sh = "{b_d}/vina_submit_shs/vina_submit_{d}.sh".format(
			b_d=base_dir, d=self.dock)
		if os.path.isfile(vina_submit_sh):
			print(">>> Vina submission script already exists at")
			print("\t{}".format(vina_submit_sh))
			overwrite = raw_input("\n\t>>> Enter 'y' or enter to overwrite, 'n' to exit: ")

			if overwrite == "y" or \
			   overwrite == "yes" or \
			   overwrite == "Y" or \
			   overwrite == "Yes" or \
			   overwrite == "":
				subprocess.call(["rm", "-f", vina_submit_sh])
				print("")
			else: sys.exit("\n\t> OK, exiting this script\n")

	# (batch submission)
	elif self.n_models > 20:
		batch_submission = True
		vina_submits_dir = "{b_d}/vina_submit_shs/vina_submits_{d}/".format(
			b_d=base_dir, d=self.dock)
		if os.path.isdir(vina_submits_dir):
			print(">>> Vina submission scripts already exist at")
			print("\t{}".format(vina_submits_dir))
			overwrite = raw_input("\n\t>>> Enter 'y' or enter to overwrite, 'n' to exit: ")

			if overwrite == "y" or \
			   overwrite == "yes" or \
			   overwrite == "Y" or \
			   overwrite == "Yes" or \
			   overwrite == "":
				subprocess.call(["rm", "-rf", vina_submits_dir])
				print("")
			else: sys.exit("\n\t> OK, exiting this script\n")

	else: print("! ! ! bad n_models")

	template = (
		"#BSUB -q hp12\n"
		"#BSUB -n {self.n_cpus}\n"
		"#BSUB -N\n"
		"#BSUB -o {cluster_base_dir}/bsub_logs/vina_{subdock}_log.txt\n"
		"#BSUB -J vina_{subdock}\n"
		"\n"
		"# Parameters"
		"dock={self.dock}\n"
		"ligset={self.ligset}\n"
		"ligset_list=\"{self.ligset_list_str}\"\n"
		"\n"
		"# Create the docking and output directories\n"
		"mkdir {cluster_base_dir}/{self.prot}/{self.dock}/\n"
		"mkdir {cluster_base_dir}/{self.prot}/{self.dock}/result_pdbqts\n"
		"\n"
		"vina_start_time=$(date \"+%Y%m%d%H%M%S\")\n"
		"printf '\\n~~~> Vina docking %s started %s' \"$dock\" \"$vina_start_time\"\n"
		"\n"
		"# Vina command\n"
		"for lig in $ligset_list\n"
		"do\n"
		"	lig_start_time=$(date \"+%Y%m%d%H%M%S\")\n"
		"	printf '\\n\\n> Docking ligand <%s> starting at %s\\n' \"$lig\" \"$lig_start_time\"\n"
		"	/share/apps/autodock/autodock_vina_1_1_2_linux_x86/bin/vina \\\n"
		"	--receptor {cluster_base_dir}/{self.prot}/{self.prot_file}.pdbqt \\\n"
		"	--ligand {cluster_base_dir}/ligsets/{self.ligset}/pdbqts/$lig.pdbqt \\\n"
		"	--out {cluster_base_dir}/{self.prot}/{self.dock}/result_pdbqts/{subdock}_$lig\_results.pdbqt \\\n"
		"	--center_x {self.box_center_x} \\\n"
		"	--center_y {self.box_center_y} \\\n"
		"	--center_z {self.box_center_z} \\\n"
		"	--size_x {self.box_size_x} \\\n"
		"	--size_y {self.box_size_y} \\\n"
		"	--size_z {self.box_size_z} \\\n"
		"	--cpu {self.n_cpus} \\\n"
		"	--num_modes {self.n_models} \\\n"
		"	--exhaustiveness {self.exhaust}\n"
		"	lig_end_time=$(date \"+%Y%m%d%H%M%S\")\n"
		"	printf '> Finished at %s' \"$lig_start_time\"\n"
		"	lig_duration=$(bc <<< \"$lig_end_time - $lig_start_time\")\n"
		"	printf '\\n> Docking of ligand %s took %s seconds' \"$lig\" \"$lig_duration\"\n"
		"done\n"
		"\n"
		"vina_end_time=$(date \"+%Y%m%d%H%M%S\")\n"
		"printf '\\n\\n---> Vina job finished %s\\n' \"$vina_end_time\"\n"
		"\n"
		"vina_duration=$(bc <<< \"$vina_end_time - $vina_start_time\")\n"
		"printf '\\n---> Docking %s of ligset %s took %s seconds \\n\\n' \"$dock\" \"$lig\" \"$vina_duration\"\n"
	)

	template = template.format(
		cluster_base_dir = cluster_base_dir,
		self=self,
		n_models = '{n_models}',
		dock = '{dock}',
		subdock = '{subdock}'
	)

	# (no need for batch submission)
	if not batch_submission:
		template_filled = template.format(
			n_models = self.n_models, dock = self.dock, subdock = self.dock)
		with open(vina_submit_sh, 'w') as f:
			f.write(template_filled)
		print("---> Vina submission script for docking {} has been created. It can be found at:".format(self.dock))
		print("\t{}".format(vina_submit_sh))
	# (batch submission)
	elif batch_submission:
		subprocess.call(['mkdir', vina_submits_dir])
		n_batches = self.n_models / 20
		for b in range(1, n_batches + 1):
			subdock = "{d}.{b}".format(d = self.dock, b = b)
			template_filled = template.format(
				n_models = 20, dock = self.dock, subdock = subdock)
			vina_submit_sh = "{v_s_d}/vina_submit_{sd}.sh".format(
				v_s_d = vina_submits_dir, sd = subdock)
			with open(vina_submit_sh, 'w') as f:
				f.write(template_filled)
		print("---> Vina submission scripts for docking h11 have been created. They can be found in:")
		print("\t{}".format(vina_submits_dir))

Docking.write_vina_submit_sh = write_vina_submit_sh



