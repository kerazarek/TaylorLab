#!/usr/bin/env Rscript

### Write parameters.csv using information from docks.csv
# (c) Zarek Siegel
# v1 2/16/2016

# Required input to the script
dock <- "DOCK"
scripts_dir <- "/Users/zarek/GitHub/TaylorLab/zvina/scripts"

# Import filesystem constants
fs_constants_csv <- paste(scripts_dir, "/filesystem_constants.csv", sep="")
fs_constants <- read.csv(fs_constants_csv, header=TRUE)
docking_dir <- as.character(fs_constants$address[fs_constants$constant == "docking_dir"])
ligsets_dir <- as.character(fs_constants$address[fs_constants$constant == "ligsets_dir"])
docks_csv <- as.character(fs_constants$address[fs_constants$constant == "docks_csv"])
gridboxes_csv <- as.character(fs_constants$address[fs_constants$constant == "gridboxes_csv"])

# Import docking parameters
docks <- read.csv(docks_csv, header=TRUE)
prot <- as.character(docks$Protein[docks$Docking.ID == dock])
ligset <- as.character(docks$Ligset[docks$Docking.ID == dock])
box <- as.character(docks$Gridbox[docks$Docking.ID == dock])
exhaust <- as.character(docks$Exhaustiveness[docks$Docking.ID == dock])
n_models <- as.character(docks$Number.of.Models[docks$Docking.ID == dock])
n_cpus <- as.character(docks$Number.of.Cpus[docks$Docking.ID == dock])

# Import ligset?

# Write params.csv
