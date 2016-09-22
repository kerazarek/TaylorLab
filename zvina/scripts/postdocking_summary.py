#!/usr/bin/env python

### Post-docking summary table
# (c) Zarek Siegel

#!/usr/bin/env python

### Output all the data mined and analyzed into a CSV file
# (c) Zarek Siegel

from scipy.stats import * # tmean, tstd, pearsonr
# from numpy import array, mean
from operator import itemgetter
from collections import *
from create_docking_object import * # Docking
from binding_site_analysis import * # get_binding_sites_list, score_binding_sites, aiad_icpd_binding_sites, assess_all_resis

def f(num):
	return float(num)

def r(num):
	return round(num, 3)

def n(num):
# 	if (type(num) is "float") or (type(num) is "int"):
# 		return True
# 	else:
# 		return False
	return True

def create_summary_dict(self):
	print("---> Creating summary data dictionary")
	self.lig_subsets = OrderedDict()
	for lig in self.ligset_list:
		self.lig_subsets[lig] = [pose for pose in self.poses if pose.lig == lig]
	self.lig_subsets["ALL"] = [pose for pose in self.poses]
	self.summary_dic_list = []

	for lig, subset in self.lig_subsets.items():
		lig_dic = {}
		lig_dic["lig"] = lig

		try: lig_dic["AvgE"] = r(tmean([pose.E for pose in subset if n(pose.E)]))
		except: lig_dic["AvgE"] = ""
		try: lig_dic["MinE"] = min([pose.E for pose in subset if n(pose.E)])
		except: lig_dic["MinE"] = ""
		try: lig_dic["StdevE"] = r(tstd([pose.E for pose in subset if n(pose.E)]))
		except: lig_dic["StdevE"] = ""
		for bs in self.binding_sites_list:
			lig_in_bs_E_list = [pose.E for pose in subset if n(pose.E) if pose.binds_in[bs]]
			if len(lig_in_bs_E_list) > 0:
				lig_dic["{}_{}".format("Num",bs)] = len(lig_in_bs_E_list)
				lig_dic["{}_{}".format("DistribFrac",bs)] = r(f(len(lig_in_bs_E_list)) / \
					len([pose.E for pose in subset if n(pose.E)]))
				lig_dic["{}_{}".format("AvgE",bs)] = r(tmean(lig_in_bs_E_list))
				lig_dic["{}_{}".format("MinE",bs)] = min(lig_in_bs_E_list)
				if len(lig_in_bs_E_list) > 1:
					lig_dic["{}_{}".format("StdevE",bs)] = r(tstd(lig_in_bs_E_list))
				else:
					lig_dic["{}_{}".format("StdevE",bs)] = ""
			else:
				lig_dic["{}_{}".format("Num",bs)] = 0
				lig_dic["{}_{}".format("DistribFrac",bs)] = 0
				lig_dic["{}_{}".format("AvgE",bs)] = ""
				lig_dic["{}_{}".format("MinE",bs)] = ""
				lig_dic["{}_{}".format("StdevE",bs)] = ""

		self.summary_dic_list.append(lig_dic)
# 		print(self.summary_dic_list)

Docking.create_summary_dict = create_summary_dict

def write_summary_csv(self):
	if not self.binding_sites_scored: self.score_binding_sites()
	self.create_summary_dict()

	col_headers = [
		"lig", "AvgE", "MinE", "StdevE"
	]
	for h in ["Num", "DistribFrac", "AvgE", "MinE", "StdevE"]:
		for bs in self.binding_sites_list:
			col_headers.append("{}_{}".format(h,bs))

	self.summary_csv = "{}/{}_summary.csv".format(self.dock_dir, self.dock)

	print("   > Writing summary.csv...")
	with open(self.summary_csv, 'w') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames=col_headers)
		writer.writeheader()
		for dict in self.summary_dic_list:
# 			print(dict)
			writer.writerow(dict)

	self.is_summary_written = True
	print("   > Completed summary.csv is located at:\n\t{}\n".format(self.summary_csv))

# 	print("---> Writing alldata.csv...")
# 	with open(self.alldata_csv, 'w') as csvfile:
# 		writer = csv.DictWriter(csvfile, fieldnames=self.alldata_fieldnames)
# 		writer.writeheader()
# 		for key in self.keys:
# 			row = {}
# 			for f in self.alldata_fieldnames:
# 				try: row[f] = self.data_dic[key][f]
# 				except KeyError:
# 					print("! ! ! KeyError while trying to write {}".format(f))
# 					row[f] = "!Err!"
# 			writer.writerow(row)





# 	print(self.summary_dic_list)



Docking.write_summary_csv = write_summary_csv
