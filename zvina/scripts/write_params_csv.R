#!/usr/bin/env Rscript

### Write parameters.csv using information from docks.csv
# (c) Zarek Siegel
# v1 2/16/2016
# v1.1 3/4/2016

### Required input
arg <- commandArgs(TRUE)
if(length(arg) != 1) {
	stop("! ! ! This script requires exactly one argument (the Dock ID)")
} else {
	dock <- arg
}

### Required global constant
base_dir <- "/Users/zarek/GitHub/TaylorLab/zvina/"

### Reference CSVs
docks_csv <- paste0(base_dir, "Dockings.csv")
gridboxes_csv <- paste0(base_dir, "Gridboxes.csv")

### Import docking parameters
# Docking CSV
docks_df <- read.csv(docks_csv, header=TRUE)
# Check that the docking exists
if(is.na(match(dock, docks_df$Docking.ID))) {
	stop(paste0("! ! ! No docking called '", dock, "' in Dockings.csv"))
}
# Basics
prot <- as.character(docks_df$Protein[docks_df$Docking.ID == dock])
ligset <- as.character(docks_df$Ligset[docks_df$Docking.ID == dock])
box <- as.character(docks_df$Gridbox[docks_df$Docking.ID == dock])
exhaust <- as.character(docks_df$Exhaustiveness[docks_df$Docking.ID == dock])
n_models <- as.character(docks_df$Number.of.Models[docks_df$Docking.ID == dock])
n_cpus <- as.character(docks_df$Number.of.CPUs[docks_df$Docking.ID == dock])
  # flex res
# Grid Box Parameters
gridboxes_df <- read.csv(gridboxes_csv, header=TRUE)
box_center_x <- as.character(gridboxes_df$Center.in.x.dimension[gridboxes_df$Gridbox.Name == box])
box_center_y <- as.character(gridboxes_df$Center.in.y.dimension[gridboxes_df$Gridbox.Name == box])
box_center_z <- as.character(gridboxes_df$Center.in.z.dimension[gridboxes_df$Gridbox.Name == box])
box_size_x <- as.character(gridboxes_df$Size.in.x.dimension[gridboxes_df$Gridbox.Name == box])
box_size_y <- as.character(gridboxes_df$Size.in.y.dimension[gridboxes_df$Gridbox.Name == box])
box_size_z <- as.character(gridboxes_df$Size.in.z.dimension[gridboxes_df$Gridbox.Name == box])
# Ligset?

### Create parameters data frame
parameters_names_list <- c("dock", "prot", "ligset", "box",
                "box_center_x", "box_center_y", "box_center_z",
                "box_size_x", "box_size_y", "box_size_z",
                "exhaust", "n_models", "n_cpus") # flex
parameters_values_list <- c(dock, prot, ligset, box,
                           box_center_x, box_center_y, box_center_z,
                           box_size_x, box_size_y, box_size_z,
                           exhaust, n_models, n_cpus) # flex
parameters_df <- data.frame(row.names = parameters_names_list)
parameters_df$parameter <- parameters_names_list
parameters_df$value <- parameters_values_list

### Write parameters CSV
parameters_csv <- paste0(base_dir, "parameters_csvs/", dock, "_parameters.csv")
write.csv(parameters_df, parameters_csv, row.names = F, quote = F)
noquote(paste0("---> Parameters CSV for docking ", dock, " has been created. It can be found at:"))
noquote(parameters_csv)


