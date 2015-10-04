#!/bin/bash

# lig1_pdbqt="/Users/zarek/mr/s4.pdbqt"
# lig2_pdbqt="/Users/zarek/mr/nce.pdbqt"
# lig1_pdbqt="/Users/zarek/lab/Docking/p300/p21/pvrd/p21-s4-m2.pdbqt"
# lig2_pdbqt="/Users/zarek/lab/Docking/p300/p21/pvrd/p21-s4-m3.pdbqt"
lig1_pdbqt=$1
lig2_pdbqt=$2


lig1_csv="lig1.csv"
lig2_csv="lig2.csv"

echo "num,atm,x,y,z" > $lig1_csv
echo "num,atm,x,y,z" > $lig2_csv

# cat $lig1_pdbqt | 
# grep 'HETATM' |
# tr -s ' ' ',' | 
# # sed -E s/'HETATM,(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+,.+,.+,.+)/\1,\2,\6,\7,\8/' \
# sed -E s/'HETATM,(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+,.+,.+,.+)/\1,\2,\6,\7,\8/' \
# >> $lig1_csv

cat $lig1_pdbqt |
grep 'HETATM' |
sed -e 's/./&,/6' \
	-e 's/./&,/12' \
	-e 's/./&,/19' \
	-e 's/./&,/33' \
	-e 's/./&,/42' \
	-e 's/./&,/51' \
	-e 's/./&,/60' |
sed -E 's/HETATM,(.+),(.+),(.+),(.+),(.+),(.+),(.+)/\1,\2,\4,\5,\6/' |
tr -d ' ' \
>> $lig1_csv

# HETATM   22  C   LIG A   1     -15.473  25.205   1.963  0.00  0.00     0.000 C 
# ATOM   2430  C   ARG A1645     -14.536  11.658 -19.275  1.00 17.76           C  
# ATOM   2438  NH2 ARG A1645     -15.731   7.817 -24.336  1.00 26.92           N  
# HETATM    7  O           1     -17.657  34.003  -1.607  0.00  0.00    -0.310 OA
# 12345678901234567890123456789012345678901234567890123456789012345678901234567890
# 0        1         2         3         4         5         6         7         8

cat $lig2_pdbqt |
grep 'HETATM' |
sed -e 's/./&,/6' \
	-e 's/./&,/12' \
	-e 's/./&,/19' \
	-e 's/./&,/33' \
	-e 's/./&,/42' \
	-e 's/./&,/51' \
	-e 's/./&,/60' |
sed -E 's/HETATM,(.+),(.+),(.+),(.+),(.+),(.+),(.+)/\1,\2,\4,\5,\6/' |
tr -d ' ' \
>> $lig2_csv

python aiad_icpd.py $lig1_csv $lig2_csv b

rm -f $lig1_csv $lig2_csv





