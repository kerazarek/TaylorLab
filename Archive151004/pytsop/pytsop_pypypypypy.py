#!/anaconda/pkgs/python-3.4.3-0/bin/python3.4

import csv
from sys import argv
script, dock = argv # only h# for now

class DockDataDic:
	def __init__(self, source_csv):
		self.source_csv = source_csv
		self.dic = {}

		csv_open = open(self.source_csv, 'r')
		csv_read = csv.reader(csv_open, delimiter=',', quotechar='"')

		csv_list = []
		for row in csv_read:
			csv_list.append(row)

		keys = csv_list[0]
		for row in csv_list:
			dic_entry = {}
			for i in range(0, len(keys)):
				if row[i] != '':
					dic_entry[keys[i]] = row[i]
			self.dic[row[0]] = dic_entry

	def keys(self):
		for k, v in self.dic.items():
			if k != ('' or 'key'): yield k

	def lig_minE(self, lig):
		lig_Es = []
		for k, v in self.dic.items():
			if v['LIG'] == lig: lig_Es.append(float(v['E']))
		return min(lig_Es)

	def lig_avgE(self, lig):
		lig_Es = []
		for k, v in self.dic.items():
			if v['LIG'] == lig: lig_Es.append(float(v['E']))
		return (sum(lig_Es) / len(lig_Es))

	def lig_bsite_count(self, lig, site):
		threshold = 0.1
		count = 0
		frac_name = "resis_score_fraction_"+site
		for k, v in self.dic.items():
			if (v['LIG'] == lig) and (float(v[frac_name]) >= threshold):
				count += 1
		return count

	def lig_bsite_minE(self, lig, site):
		threshold = 0.1
		lig_bs_Es = []
		frac_name = "resis_score_fraction_"+site
		for k, v in self.dic.items():
			if (v['LIG'] == lig) and (float(v[frac_name]) >= threshold):
				lig_bs_Es.append(float(v['E']))
		try:
			return min(lig_bs_Es)
		except ValueError:
			return "NA"

	def lig_bsite_avgE(self, lig, site):
		threshold = 0.1
		lig_bs_Es = []
		frac_name = "resis_score_fraction_"+site
		for k, v in self.dic.items():
			if (v['LIG'] == lig) and (float(v[frac_name]) >= threshold):
				lig_bs_Es.append(float(v['E']))
		try:
			return (sum(lig_bs_Es) / len(lig_bs_Es))
		except ZeroDivisionError:
			return "NA"

class AllDataDic(DockDataDic):
	def __init__(self, source_address_dic):
		self.source_address_dic = source_address_dic

		allDDDs = {}
		for k, v in self.source_address_dic.items():
			allDDDs[k] = DockDataDic(v)

		self.dic = {}
		for dock in self.source_address_dic:
			for k, v in allDDDs[dock].dic.items():
				self.dic[k] = v

	def lig_data(self, lig):
		for k, v in self.dic.items():
			if v['LIG'] == lig:
				yield v




def main():
	def hepi_address(h):
		return "/Users/zarek/lab/Docking/hepi/"+str(h)+"/"+str(h)+"_alldata.csv"

	print(hepi_address(dock))

	h1thru16 = []
	for h in range(1, 9):
		h1thru16.append("h"+str(h))

	h1thru16_addresses = {}
	for h in h1thru16:
		h1thru16_addresses[h] = hepi_address(h)

	LIGSET_LIST_py = ["aa8", "aa10", "aam", "ab", "ab3", "ab6", "ab7", "ab8", "ab10", "abm", "adph", "fdla", "ga8", "ga10", "gam", "gb", "gb3", "gb6", "gb7", "gb8", "gb8y", "gb10", "gbm"]

	ALL = AllDataDic(h1thru16_addresses)
	def print_w_words():
		for LIG in LIGSET_LIST_py:
			print("~~~~~~~~~~~~~~")
			print(LIG)
			print("minE is:", ALL.lig_minE(LIG))
			print("avgE is:", ALL.lig_avgE(LIG))
			print("# adph is:", ALL.lig_bsite_count(LIG, 'adph'))
			print("# fdla is:", ALL.lig_bsite_count(LIG, 'fdla'))
			print("# allo is:", ALL.lig_bsite_count(LIG, 'allo'))
			print("adph minE is:", ALL.lig_bsite_minE(LIG, 'adph'))
			print("fdla minE is:", ALL.lig_bsite_minE(LIG, 'fdla'))
			print("allo minE is:", ALL.lig_bsite_minE(LIG, 'allo'))
			print("adph avgE is:", ALL.lig_bsite_avgE(LIG, 'adph'))
			print("fdla avgE is:", ALL.lig_bsite_avgE(LIG, 'fdla'))
			print("allo avgE is:", ALL.lig_bsite_avgE(LIG, 'allo'))

	print("~~~~~~~~~~~~~~~~~~~")
	print("~~~~~~~~~~~~~~~~~~~")
	print("~~~~~~~~~~~~~~~~~~~")

	print("LIG, minE, avgE, #adph, #fdla, #allo, avgE-adph, avgE-fdla, avgE-allo, minE-adph, minE-fdla, minE-allo")
	# for LIG in LIGSET_LIST_py:
# 		print('{},{},{},{},{},{},{},{},{},{},{},{}'.format(LIG, ALL.lig_minE(LIG), ALL.lig_avgE(LIG), ALL.lig_bsite_count(LIG, 'adph'), ALL.lig_bsite_count(LIG, 'fdla'), ALL.lig_bsite_count(LIG, 'allo'), ALL.lig_bsite_minE(LIG, 'adph'), ALL.lig_bsite_minE(LIG, 'fdla'), ALL.lig_bsite_minE(LIG, 'allo'), ALL.lig_bsite_avgE(LIG, 'adph'), ALL.lig_bsite_avgE(LIG, 'fdla'), ALL.lig_bsite_avgE(LIG, 'allo')))

	dockinquestion = DockDataDic(hepi_address(dock))
# 	print(dockinquestion)

	# for LIG in LIGSET_LIST_py:
# # 		print(LIG)
# 		print('{},{},{},{},{},{},{},{},{},{},{},{}'.format(LIG, dockinquestion.lig_minE(LIG), dockinquestion.lig_avgE(LIG), dockinquestion.lig_bsite_count(LIG, 'adph'), dockinquestion.lig_bsite_count(LIG, 'fdla'), dockinquestion.lig_bsite_count(LIG, 'allo'), dockinquestion.lig_bsite_minE(LIG, 'adph'), dockinquestion.lig_bsite_minE(LIG, 'fdla'), dockinquestion.lig_bsite_minE(LIG, 'allo'), dockinquestion.lig_bsite_avgE(LIG, 'adph'), dockinquestion.lig_bsite_avgE(LIG, 'fdla'), dockinquestion.lig_bsite_avgE(LIG, 'allo')))

	h21thru26 = []
	for h in range(21, 27):
		h21thru26.append("h"+str(h))

	h21thru26_addresses = {}
	for h in h21thru26:
		h21thru26_addresses[h] = hepi_address(h)

	print(h21thru26_addresses)

	h21thru26_ALL = AllDataDic(h21thru26_addresses)

	LIG = 'gb8'
	for k in h21thru26_addresses:
# 		print(k)
		print('{},{},{},{},{},{},{},{},{},{},{},{},{}'.format(LIG, k, h21thru26_ALL.lig_minE(LIG), h21thru26_ALL.lig_avgE(LIG), h21thru26_ALL.lig_bsite_count(LIG, 'adph'), h21thru26_ALL.lig_bsite_count(LIG, 'fdla'), h21thru26_ALL.lig_bsite_count(LIG, 'allo'), h21thru26_ALL.lig_bsite_minE(LIG, 'adph'), h21thru26_ALL.lig_bsite_minE(LIG, 'fdla'), h21thru26_ALL.lig_bsite_minE(LIG, 'allo'), h21thru26_ALL.lig_bsite_avgE(LIG, 'adph'), h21thru26_ALL.lig_bsite_avgE(LIG, 'fdla'), h21thru26_ALL.lig_bsite_avgE(LIG, 'allo')))


# 		print('{:5},{:5},{:5},{:5},{:5},{:5},{:5},{:5},{:5},{:5},{:5},{:5}'.format(LIG, ALL.lig_minE(LIG), ALL.lig_avgE(LIG), ALL.lig_bsite_count(LIG, 'adph'), ALL.lig_bsite_count(LIG, 'fdla'), ALL.lig_bsite_count(LIG, 'allo'), ALL.lig_bsite_minE(LIG, 'adph'), ALL.lig_bsite_minE(LIG, 'fdla'), ALL.lig_bsite_minE(LIG, 'allo'), ALL.lig_bsite_avgE(LIG, 'adph'), ALL.lig_bsite_avgE(LIG, 'fdla'), ALL.lig_bsite_avgE(LIG, 'allo')))
#

# 	for key, data in all.items():
#
# 		if data['LIG'] == "aa8":
# 			print(data['E'])
#



if __name__ == "__main__": main()
