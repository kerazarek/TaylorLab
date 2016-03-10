#!/usr/bin/env Rscript

### Write a new entry to Dockings.csv or Gridboxes.csv
# (c) Zarek Siegel
# v1 3/9/2016

### Required input
arg <- commandArgs(TRUE)
if(length(arg) != 2) {
	stop("! ! ! This script requires exactly two arguments (g/d and the base_dir)")
} else {
	option <- as.character(arg[1])
}

### Required global constant
base_dir <- as.character(arg[2])

### Reference CSVs
docks_csv <- paste0(base_dir, "Dockings.csv")
gridboxes_csv <- paste0(base_dir, "Gridboxes.csv")

### Option error
if(option != "d" & option == "g") {
	print("! ! ! bad option")
}



### Docking
if(option == "d") {
	docks_df <- read.csv(docks_csv, header=TRUE)
	new_row <- nrow(docks_df)+1
	docks_df[new_row,] <- rep(NA, length(colnames))
	docks_df[new_row, "Docking.ID"] <- readline("Docking ID for new docking")
# 	Date
# 	Protein
# 	Ligset
# 	Gridbox
# 	Exhaustiveness
# 	Number.of.Models
# 	Number.of.CPUs
# 	Notes
	print(docks_df)
}



### Grid box
if(option == "g") {
	grid.entry = T
}