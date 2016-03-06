### Write parameters csv
# (c) Zarek Siegel
# v1 2/16/2016

# Import Filesystem constants
scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
filesystem_constants_csv=$scripts_dir"/filesystem_constants.csv"
docking_dir=$(cat $filesystem_constants_csv | grep '^docking_dir' | sed 's/^docking_dir,//')
ligsets_dir=$(cat $filesystem_constants_csv | grep '^ligsets_dir' | sed 's/^ligsets_dir,//')
docking_dir=$(cat $filesystem_constants_csv | grep '^docking_dir' | sed 's/^docking_dir,//')
docking_dir=$(cat $filesystem_constants_csv | grep '^docking_dir' | sed 's/^docking_dir,//')



echo $docking_dir

# docking_dir,/Users/zarek/GitHub/TaylorLab/zvina
# ligsets_dir,/Users/zarek/GitHub/TaylorLab/zvina/ligsets
# docks_csv,/Users/zarek/GitHub/TaylorLab/zvina/Dockings.csv
# gridboxes_csv,/Users/zarek/GitHub/TaylorLab/zvina/Gridboxes.csv
