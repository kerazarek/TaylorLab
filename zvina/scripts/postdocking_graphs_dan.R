### Docking data graphs (hepi and p300 - pls1a and hls1)
#		2/14/16 Zarek Siegel
#		2/21/16 up to full ggplot2 replacement
#		2/23/16 more density plots, p300 and hepi compatible
#	v1.0 3/16/16 lots stuff

rm(list=ls(all=TRUE)) # clear out old variables
library(foreign) # for reading csv
library(ggplot2)
library(reshape2)

### Command line arguments
manual <- T
manual_dock <- "h35"
# h29 h23 h35

if(manual) {
	base_dir <- "/Users/zarek/lab/zvina"
	script_path <- paste0(base_dir, "/scripts/postdocking_graphs.R")
	dock <- manual_dock
} else {
	args <- commandArgs()
	script_path <- args[4]
	script_path <- sub("--file=", "", script_path)
	base_dir <- sub("/scripts/postdocking_graphs.R", "", script_path)
	#	base_dir <- "/Users/zarek/lab/zvina"
	dock <- args[6]
}




### Basic parameters
#	dock <- "p7b" # docking id
#	if(substr(dock,0,1) == "p") {prot <- "p300"} # p300 dockings are labeled p##
#	if(substr(dock,0,1) == "h") {prot <- "hepi"} # hepi dockings are labeled h##
#	assumptions
#		-dockings have a docking id of the form d##,
#			where d represents the protein and ## is a number
#		-inallo the home docking directory,
#			there is a directory with the protein's name (e.g. .../p300/).
#			(this is what I mean by 'dock directory')
#		-inallo the protein directory directory,
#			there is a directory with the docking id (e.g. .../p300/p27/)
#		-inallo the docking directory,
#			threre is a CSV file called d##_alldata.csv (** see zarek or a sample for details)

#	docks.xlsx <- "/Users/zarek/lab/Docking/docks.xlsx"
#	dock.params <- read.xlsx2(docks.xlsx, sheetName = prot)
#
#	ligset <- as.character(dock.params$ligSET[dock.params$DOCK == dock])
#
#	all.ligsets <- read.xlsx2(docks.xlsx, sheetName = "ligsets")
#	ligset_list <- as.character(all.ligsets$lig_list[all.ligsets$name == ligset])
#	ligset_list <- unlist(strsplit(ligset_list, "[ ]"))

#	### System directories
#	docking.base.dir <- "/Users/zarek/lab/Docking/"
#	dock.dir <- paste(docking.base.dir, prot, "/", dock, "/", sep = "")
#	graphs_dir <- paste(dock.dir, "graphs/", sep="")
#	if(dir.exists(graphs_dir)) {
#		print("graphs directory was not created because it already exists")
#	} else {dir.create(graphs_dir)}
#
#	### Read in alldata.csv
#	alldata.csv <- paste(dock.dir, dock, "_alldata.csv", sep="")
#	data <- read.csv(alldata.csv)
#
#	### Look up ligset
#	# ** add this**, this (below) is temporary
#
#	# ligset_list <- c("adph", "fdla", "ab", "gb", "aam",
#	#                  "abm", "gam", "gbm", "ab3", "gb3",
#	#                  "ab6", "gb6", "ab7", "gb7", "aa8",
#	#                  "ab8", "ga8", "gb8", "gb8y", "aa10",
#	#                  "ab10", "ga10", "gb10")
#
#	### Look up ligset
#	#**KLUDGE* ** add this**, this (below) is temporary
#	if(prot == "hepi") {
#		binding_sites <- c("adph", "fdla", "allo")
#		#***# Order levels
#		ncs.sugargrouped <- c("adph", "fdla",
#                         "ab", "aam", "abm", "ab3", "ab6",
#                         "ab7", "aa8", "ab8", "aa10", "ab10",
#                         "gb", "gam", "gbm", "gb3", "gb6",
#                         "gb7", "ga8", "gb8", "gb8y",
#                         "ga10", "gb10")
#		ligset_list <- ncs.sugargrouped
#	}
#	if(prot == "p300") {
#		binding_sites <- c("lys", "coa", "side", "allo1", "allo2") # "coa_adpp", "coa_pant",
#		ligset_list <- c("Garcinol", "CTB", "EGCG", "CTPB", "C646")
#	}
#	##**##
#
#	### Recode variables with more convenient names
#	if(is.element(dock, c("p28", "p29", "p30"))) {
#		ligset.coded <- c("ng", "s2", "ne", "s1", "s3")
#		ligset.names <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
#		data$lig <- ligset.names[match(data$lig, ligset.coded)]
#		data$lig <- factor(data$lig, levels = ligset.names)
#	}
#	if(is.element(dock, c("p27", "p31"))) {
#		ligset.names <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
#		data$lig <- factor(data$lig, levels = ligset.names)
#	}


dockings_csv <- paste0(base_dir, "/", "Dockings.csv")
dockings_df <- read.csv(dockings_csv)

prot <- as.character(dockings_df$Protein[dockings_df$Docking.ID == dock])
date <- as.character(dockings_df$Date[dockings_df$Docking.ID == dock])
prot_file <- as.character(dockings_df$Protein.File[dockings_df$Docking.ID == dock])
ligset <- as.character(dockings_df$Ligset[dockings_df$Docking.ID == dock])
box <- as.character(dockings_df$Gridbox[dockings_df$Docking.ID == dock])
exhaust <- as.character(dockings_df$Exhaustiveness[dockings_df$Docking.ID == dock])
n_models <- as.integer(dockings_df$Number.of.Models[dockings_df$Docking.ID == dock])
n_cpus <- as.integer(dockings_df$Number.of.CPUs[dockings_df$Docking.ID == dock])
notes <- as.character(dockings_df$Notes[dockings_df$Docking.ID == dock])

gridboxes_csv <- paste0(base_dir, "/", "Gridboxes.csv")
gridboxes_df <- read.csv(gridboxes_csv)

box_center_x <- as.numeric(gridboxes_df$Center.in.x.dimension[gridboxes_df$Gridbox.Name == box])
box_center_y <- as.numeric(gridboxes_df$Center.in.y.dimension[gridboxes_df$Gridbox.Name == box])
box_center_z <- as.numeric(gridboxes_df$Center.in.z.dimension[gridboxes_df$Gridbox.Name == box])
box_size_x <- as.numeric(gridboxes_df$Size.in.x.dimension[gridboxes_df$Gridbox.Name == box])
box_size_y <- as.numeric(gridboxes_df$Size.in.y.dimension[gridboxes_df$Gridbox.Name == box])
box_size_z <- as.numeric(gridboxes_df$Size.in.z.dimension[gridboxes_df$Gridbox.Name == box])
box_notes <- as.character(gridboxes_df$Notes[gridboxes_df$Gridbox.Name == box])

ligset_list_txt <- paste0(base_dir, "/ligsets/", ligset, "/", ligset, "_list.txt")
ligset_list <- read.delim(ligset_list_txt, header = F, sep = "\n")
ligset_list <- as.character(unlist(ligset_list))
ligset_list <- factor(ligset_list, levels = ligset_list)

### Read in alldata.csv to a data frama called 'data'
dock_dir <- paste0(base_dir, "/", prot, "/", dock)
dock_alldata_csv <- paste0(dock_dir, "/", dock, "_alldata.csv")
data <- read.csv(dock_alldata_csv)

### Recode variables with more convenient names
if(ligset == "pls1a") {
#	ligset.coded <- c("ng", "s2", "ne", "s1", "s3")
#	ligset.names <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
	pls1a_coded <- c("ng", "s2", "ne", "s1", "s3")
	pls1a_renamed <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
	data$lig <- pls1a_renamed[match(data$lig, pls1a_coded)]
	data$lig <- factor(data$lig, levels = pls1a_renamed)
	ligset_list <- pls1a_renamed
}
if(ligset == "hls1") {
#		ncs.sugargrouped <- c("adph", "fdla",
#                         "ab", "aam", "abm", "ab3", "ab6",
#                         "ab7", "aa8", "ab8", "aa10", "ab10",
#                         "gb", "gam", "gbm", "gb3", "gb6",
#                         "gb7", "ga8", "gb8", "gb8y",
#                         "ga10", "gb10")
#		ligset_list <- ncs.sugargrouped
	hls1_ordered <- c("adph", "fdla",
                        "ab", "aam", "abm", "ab3", "ab6",
                        "ab7", "aa8", "ab8", "aa10", "ab10",
                        "gb", "gam", "gbm", "gb3", "gb6",
                        "gb7", "ga8", "gb8", "gb8y",
                        "ga10", "gb10")
	data$lig <- factor(data$lig, levels = hls1_ordered)
	ligset_list <- hls1_ordered
	data$chain_length <- rep(NA, nrow(data))
	data$chain_length[data$lig == "ab"] <- 0
	data$chain_length[data$lig == "gb"] <- 0
	data$chain_length[data$lig == "aam"] <- 1
	data$chain_length[data$lig == "abm"] <- 1
	data$chain_length[data$lig == "gam"] <- 1
	data$chain_length[data$lig == "gbm"] <- 1
	data$chain_length[data$lig == "ab3"] <- 3
	data$chain_length[data$lig == "gb3"] <- 3
	data$chain_length[data$lig == "ab6"] <- 6
	data$chain_length[data$lig == "gb6"] <- 6
	data$chain_length[data$lig == "ab7"] <- 7
	data$chain_length[data$lig == "gb7"] <- 7
	data$chain_length[data$lig == "ab8"] <- 8
	data$chain_length[data$lig == "gb8"] <- 8
	data$chain_length[data$lig == "aa8"] <- 8
	data$chain_length[data$lig == "ga8"] <- 8
	data$chain_length[data$lig == "gb8y"] <- 8
	data$chain_length[data$lig == "ab10"] <- 10
	data$chain_length[data$lig == "gb10"] <- 10
	data$chain_length[data$lig == "aa10"] <- 10
	data$chain_length[data$lig == "ga10"] <- 10
	
	data$E[data$E == '!Err!'] <- NA
	data$E <- factor(data$E)
	data$E <- as.double(as.vector(data$E))

	with(data, cor.test(E, chain_length))
		# 	Pearson's product-moment correlation
		# 
		# data:  E and chain_length
		# t = -66.105, df = 8396, p-value < 2.2e-16
		# alternative hypothesis: true correlation is not equal to 0
		# 95 percent confidence interval:
		#  -0.5989627 -0.5708247
		# sample estimates:
		#        cor 
		# -0.5850697 
}

binding_sites_dir <- paste0(base_dir, "/binding_sites/", prot_file)
binding_sites <- list.files(path = binding_sites_dir)
binding_sites <- sub(".pdb", "", binding_sites)

### Create bindsin_SITE rows (T/F depending on score fraction)
# binding.threshold <- 0.10 # threshold for binding fraction
# for(bs in binding_sites) {
# #	data[, paste("bindsin_", bs, sep = "")] <- rep(NA, nrow(data))
# #	data[, paste("bindsin_", bs, sep = "")][data[,paste("resis_score_fraction_", bs, sep = "")] >= binding.threshold] <- T
# #	data[, paste("bindsin_", bs, sep = "")][data[,paste("resis_score_fraction_", bs, sep = "")] < binding.threshold] <- F
# #
# 	bindsin_bs <- paste0("bindsin_", bs)
# 	bs_fraction <- paste0("fraction_", bs)
# 	data[, bindsin_bs] <- rep(NA, nrow(data))
# 	data[,bs_fraction][data[,bs_fraction] == '!Err!'] <- NA
# 	data[, bindsin_bs][!is.na(data[,bs_fraction]) >= binding.threshold] <- T
# 	data[, bindsin_bs][!is.na(data[,bs_fraction]) < binding.threshold] <- F
# }

# data$E <- as.double(data$E)
data$E[data$E == '!Err!'] <- NA
data$E <- factor(data$E)
data$E <- as.double(as.vector(data$E))
# 
# ### Create analysis data frame
# analysis <- data.frame(row.names = ligset_list)
# 
# #	Build column headers for averages, minimums, standard deviations, distribution fractions
# analysis.columns <- c("AvgE", "MinE", "StdevE", paste("Num_", binding_sites, sep = ""),
#                       paste("DistribFrac_", binding_sites, sep = ""),
#                       paste("AvgE_", binding_sites, sep = ""), paste("MinE_", binding_sites, sep = ""))
# for(c in analysis.columns) {
# 	analysis[,c] <- rep(NA, ligset_length)
# }
# 
# #	Fill in analysis data
# for(l in ligset_list) {
# 	analysis[l, "lig"] <- l
# 	analysis[l, "AvgE"] <- mean(data$E[data$lig == l]) # Overall average energy for lig
# 	analysis[l, "MinE"] <- min(data$E[data$lig == l]) # Overall minimum energy for lig
# 	analysis[l, "StdevE"] <- sd(data$E[data$lig == l]) # Overall standard deviation of energies for lig
# 	DistribFrac_Denom <- 0
# 	for(bs in binding_sites) {
# 		bindsin_bs <- paste0("bindsin_", bs)
# 		
# 		num_in_site <- length(data$E[data$lig == l & data[, bindsin_bs] == 1])
# 		analysis[l, paste0("Num_", bs)] <- num_in_site # Number binding in each site
# 		DistribFrac_Denom <- DistribFrac_Denom + num_in_site
# 		if(analysis[l, paste0("Num_", bs)] > 0) {
# 			analysis[l, paste0("AvgE_", bs)] <-  # Average energy for ligs binding in site
# 				mean(data$E[data$lig == l & data[, bindsin_bs] == 1])
# 			analysis[l, paste0("MinE_", bs)] <- # Minimum energy for ligs binding in site
# 				min(data$E[data$lig == l & data[, bindsin_bs] == 1])
# 		} else { # otherwise it will return Inf's
# 			analysis[l, paste0("AvgE_", bs)] <- NA
# 			analysis[l, paste0("MinE_", bs)] <- NA
# 		}
# 	}
# 	for(bs in binding_sites) { # fraction of bindings in site from count
# 		analysis[l, paste("DistribFrac_", bs, sep = "")] <-
# 			analysis[l, paste("Num_", bs, sep = "")] / DistribFrac_Denom
# 	}
# }
# 

# analysis_csv = paste0(dock_dir, "/", dock, "_summary_from_graphing.csv")
# 
# write.csv(analysis, file = analysis_csv)
# print(paste0("Created summary CSV"))

analysis_csv = paste0(dock_dir, "/", dock, "_summary.csv")
analysis <- read.csv(analysis_csv)
analysis[,][is.na(analysis[,])] <- 0

################################################################################
################################################################################
################################################################################

height <- 4
ligset_length <- length(ligset_list)
if((ligset_length / 15) < 1) {ligset_length <- 15}
if((ligset_length / 10 * height) > 20) {ligset_length <- 200/height}



data <- subset(data, !is.na(data$lig))

### Graphs!!!!!!!
#	setwd(graphs_dir) # needed for pdf names below
#	bs.colors <- brewer.pal(length(binding_sites), "Set1")
#	lig.colors <- brewer.pal(ligset_length, "Set2")
#	lig.palette <- "Greys"

graphs_dir <- paste0(dock_dir, "/graphs/")
if(dir.exists(graphs_dir)) {
	print("graphs directory was not created because it already exists")
} else {dir.create(graphs_dir)}
setwd(graphs_dir)

####################
### Box plot of binding energies (in all sites) by ligand
boxplots_energy_vs_lig_allsites <- ggplot(data=data, aes(x=lig, y=E)) +
	geom_boxplot(aes(fill=lig)) +
	scale_fill_hue(name="Ligands") + # legend
	scale_x_discrete(limits=ligset_list) +
	xlab("Ligand") +
	ylab("Binding energy (kcal/mol)") +
	ggtitle("Binding Energies by Ligand (All binding sites)") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
boxplots_energy_vs_lig_allsites

graph_name <- "boxplots_energy_vs_lig_allsites"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height), height=height)
print(paste0("Created ", graph_name))

####################

####################
### Density of dockings over energy range
#	All ligands combined
densities_energy_by_lig_allcombined <- ggplot(data=data, aes(x=E)) +
	geom_density() +
	xlab("Binding energy (kcal/mol)") +
	ggtitle("Overall Density of Dockings versus Binding Energy") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
densities_energy_by_lig_allcombined

graph_name <- "densities_energy_by_lig_allcombined"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=height*2, height=height*1.5)
print(paste0("Created ", graph_name))

#	Separate charts for each ligand, arranged in a grid
#		OK fine it actually wraps but whatever
densities_energy_by_lig_grid <- ggplot(data=data, aes(x=E, color=lig, group=lig)) +
	geom_density() +
	scale_color_hue(name="Ligands") +
	xlab("Binding energy (kcal/mol)") +
	ggtitle("Density of Dockings versus Binding Energy by Ligand (All Binding Sites)") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold")) +
	facet_wrap(~lig)
densities_energy_by_lig_grid

graph_name <- "densities_energy_by_lig_grid"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*1.5, height=(ligset_length / 10 * height))
print(paste0("Created ", graph_name))

#	*A*
#	Same thing but overlayed
densities_energy_by_lig_overlay <- ggplot(data=data, aes(x=E, color=lig)) +
	geom_density() +
	scale_color_hue(name="Ligands") +
	scale_x_reverse(limits=c(max(data$E), min(data$E))) +
	xlab("Binding energy (kcal/mol)") +
	ylab("Probability density") +
	ggtitle("Density of Dockings versus Binding Energy (All Binding Sites)") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
densities_energy_by_lig_overlay

graph_name <- "densities_energy_by_lig_overlay"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=height*3, height=height*2)
print(paste0("Created ", graph_name))

####################


####################
### Create a new melted data frame for energies with one unique entry per bidning site placement
data.E.bs.melted <- melt(data,
                         id.vars=c("key", "E", "lig"), # ID variables - all the variables to keep but not split apart on
                         measure.vars=paste0("bindsin_", binding_sites) # The source columns
)
data.E.bs.melted <- subset(data.E.bs.melted, !is.na(data.E.bs.melted$key))

#	This new variable will simply be name of the site
data.E.bs.melted$binding.placement <-  rep(NA, nrow(data.E.bs.melted))
data.E.bs.melted$binding.placement <- sub("bindsin_", "", data.E.bs.melted$variable) # data.E.bs.melted$variable is bindsin_SITE

# data.E.bs.melted <- data.E.bs.melted[data.E.bs.melted$value, c("key", "E", "lig", "binding.placement")]
data.E.bs.melted <- data.E.bs.melted[data.E.bs.melted$value, c("key", "E", "lig", "binding.placement")]

# data.E.bs.melted$value is T/F
### A density plot for all ligands with separate traces for each binding site
densities_energy_by_site_overlay <- ggplot(data=data.E.bs.melted, aes(x=E, color=binding.placement)) +
	geom_density() +
	scale_color_hue(name="Binding Site", labels=binding_sites) +
	xlab("Binding energy (kcal/mol)") +
	ggtitle("Density of Dockings versus Binding Energy by Binding Site (All Ligands)") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
densities_energy_by_site_overlay

graph_name <- "densities_energy_by_site_overlay"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=height*2, height=height*1.5)
print(paste0("Created ", graph_name))


### A grid of density plots (lig vs. site) with single energy traces for each box
densities_energy_by_lig_and_site_grid <- ggplot(data=subset(data.E.bs.melted, !is.na(data.E.bs.melted$lig)), aes(x=E, color=binding.placement, group=lig)) +
	geom_density() +
	facet_grid(binding.placement ~ lig) +
	scale_color_hue(name="Binding Site", labels=binding_sites) +
	xlab("Binding energy (kcal/mol)") +
	ggtitle("Density of Dockings versus Binding Energy by Binding Site and Ligand") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
densities_energy_by_lig_and_site_grid

graph_name <- "densities_energy_by_lig_and_site_grid"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=(ligset_length / 10 * height))
print(paste0("Created ", graph_name))

####################












#	*A*
data$combined.sites <- rep(NA, nrow(data))
if(prot_file == "p300") {
	binding_sites_capitalized <- c("Lys", "CoA", "Side", "Allo1", "Allo2")
}
if(prot_file == "hepi_2h1h" | prot_file == "hepi_2h1h_adph" | prot_file == "hepi_2h1h_fdla" | prot_file == "hepi_2gt1" | prot_file == "hepi_2gt1_adph" | prot_file == "hepi_2gt1_fdla") {
	binding_sites_capitalized <- c("ADPH", "FDLA")
}
if(prot_file == "hepi_carm" | prot_file == "hepi_carm_adph" | prot_file == "hepi_carm_fdla") {
	binding_sites_capitalized <- c("ADPH", "FDLA", "Allo")
}

for(r in 1:nrow(data)) {
	combined.sites <- NA
	# for(bs in binding_sites) {
	for(bs in binding_sites_capitalized) {
		# if(data[r, paste0("bindsin_", bs)]) {combined.sites <- c(combined.sites, bs) }
		if(data[r, paste0("bindsin_", tolower(bs))] == 1) {combined.sites <- c(combined.sites, bs) }
	}
	data[r, "combined.sites"] <- paste(na.omit(combined.sites), collapse=" + ")
}
combined.sites <- combined.sites[!is.na(combined.sites)]
data$combined.sites[data$combined.sites == ""] <- "No site placement"

barplot_bindingdist_by_lig_combinedsites <- ggplot(data=data) +
	geom_bar(aes(x=lig, fill=combined.sites), color="black", width=0.8) +
	scale_x_discrete(limits=ligset_list) +
# 	scale_fill_hue(name="Binding Site(s)") +
# 	scale_fill_manual(values=c("orchid", "mediumpurple", "greenyellow", "mediumaquamarine", "grey"), name="Binding Site(s)") +
	scale_fill_brewer(palette="Set2", name="Binding Site(s)") +
	xlab("Ligand") +
	ylab("Number of Ligands in Site") +
	ggtitle("Binding Site Placement Distribution by Ligand") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
barplot_bindingdist_by_lig_combinedsites

graph_name <- "barplot_bindingdist_by_lig_combinedsites"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*1.25, height=height*1.25)
print(paste0("Created ", graph_name))








####################
### Bar plot of binding distribution in each binding site by ligand
#	Make a data frame with only the binding site numbers
analysis.bindingsites <- analysis[c(paste("Num_", binding_sites, sep=""))]
analysis.bindingsites$bs_cat <- row.names(analysis.bindingsites)

#	Melt this data frame for graphing
melted.analysis.bindingsites <- melt(analysis.bindingsites, id.vars = "bs_cat")

ligset_list_all <- (c(as.character(ligset_list), "ALL"))
ligset_list_all <- factor(ligset_list_all, levels=ligset_list_all)

barplot_bindingdist_by_lig <- ggplot(data=melted.analysis.bindingsites, aes(x=bs_cat, y=value, fill=variable)) +
	geom_bar(stat="identity", color="black") +
	scale_x_discrete(labels=ligset_list_all) +
	scale_fill_hue(name="Binding Site", labels=binding_sites) +
	xlab("Ligand") +
	ylab("Number of Ligands in Site") +
	ggtitle("Binding Distribution by Ligand") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
barplot_bindingdist_by_lig


graph_name <- "barplot_bindingdist_by_lig"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height), height=height*1.25)
print(paste0("Created ", graph_name))

####################

####################
### Bar plot of average binding energy in each binding site per ligand
#	Make a data frame with only the binding site numbers
analysis.avgenergies <- analysis[c(paste("AvgE_", binding_sites, sep=""))]
analysis.avgenergies$bs_cat <- row.names(analysis.avgenergies)
#	Melt this data frame for graphing
melted.analysis.avgenergies <- melt(analysis.avgenergies, id.vars = "bs_cat")
barplot_avge_vs_lig_by_bs <- ggplot(data=melted.analysis.avgenergies, aes(x=bs_cat, y=value, fill=variable, width=0.75)) +
 	geom_bar(stat="identity", color="black", position=position_dodge()) +
	scale_x_discrete(labels=ligset_list_all) +
	scale_fill_hue(name="Binding Site", labels=binding_sites) +
	xlab("Ligand") +
	ylab("Binding energy (kcal/mol)") +
	ggtitle("Average Energy by Binding Site") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
barplot_avge_vs_lig_by_bs

graph_name <- "barplot_avge_vs_lig_by_bs"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*1.25, height=height*1.25)
print(paste0("Created ", graph_name))

####################

####################

counts.max <- max(analysis[, paste0("Num_", binding_sites)])/1.5
### 'Stripcharts' for energy by ligand
#	Overall
vertbarplots_energy_by_lig_allsites <- ggplot(data=data, aes(x=E, fill=lig, group=lig)) +
	geom_bar(width=0.1) +
	coord_flip() +
	scale_fill_hue(guide=FALSE) +
	xlab("Binding energy (kcal/mol)") +
	scale_x_reverse(limits=c(max(data$E), min(data$E))) +
	ylim(0, counts.max) +
	ggtitle("Binding Affinity Frequencies by Ligand (All binding sites)") +
	theme(plot.title=element_text(face="bold"),
         legend.title=element_text(face="bold")) +
	facet_grid(. ~ lig, drop=F)
vertbarplots_energy_by_lig_allsites

graph_name <- "vertbarplots_energy_by_lig_allsites"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
print(paste0("Created ", graph_name))

counts.max <- n_models / 3
### For each binding site
#	HepI:
if(prot == "hepi") {
	# ADPH
	vertbarplots_energy_by_lig_adphsite <- ggplot(data=subset(data, data$bindsin_adph == 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ylim(0, counts.max) +
		ggtitle("Binding Affinity Frequencies by Ligand (ADPH Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_adphsite

	graph_name <- "vertbarplots_energy_by_lig_adphsite"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))

	# FDLA
	vertbarplots_energy_by_lig_fdlasite <- ggplot(data=subset(data, data$bindsin_fdla == 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ylim(0, counts.max) +
		ggtitle("Binding Affinity Frequencies by Ligand (FDLA Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_fdlasite

	graph_name <- "vertbarplots_energy_by_lig_fdlasite"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))

	# ALLO
	vertbarplots_energy_by_lig_allosite <- ggplot(data=subset(data, data$bindsin_allo == 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ylim(0, counts.max) +
		ggtitle("Binding Affinity Frequencies by Ligand (ALLO Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_allosite

	graph_name <- "vertbarplots_energy_by_lig_allosite"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))



	## Dan's Percent Inhibition data
	hls1_ordered <- c("adph", "fdla",
                        "ab", "aam", "abm", "ab3", "ab6",
                        "ab7", "aa8", "ab8", "aa10", "ab10",
                        "gb", "gam", "gbm", "gb3", "gb6",
                        "gb7", "ga8", "gb8", "gb8y",
                        "ga10", "gb10")
	hls1_ordered <- factor(hls1_ordered, levels=hls1_ordered)
	dan.data <- read.csv("/Users/zarek/lab/Resources/Dans_Percent_Inhib_Data.csv", header = T)
	dan.data$Ligand <- factor(dan.data$Ligand, levels = hls1_ordered)
	
	
	dan_percent_inhib_barplot <- ggplot(data=dan.data, aes(x=Ligand, y=Percent.Inhibition, fill=Ligand)) +
		geom_bar(stat="identity", color="black") +
		scale_fill_discrete(guide=F) +
		xlab("Ligand") +
		ylab("Percent Inhibition") +
		ggtitle("In Vitro Percent Inhibition of HepI by Alkylated Monosaccharides") +
		theme(legend.title=element_text(face="bold"))
	dan_percent_inhib_barplot
	ggsave("/Users/zarek/Desktop/thesis_shit/dan_percent_inhib_barplot.pdf", width=8, height=4)
	
	cor.test(dan.data$Chain.Length, dan.data$Percent.Inhibition)
		# 	Pearson's product-moment correlation
		# 
		# data:  dan.data$Chain.Length and dan.data$Percent.Inhibition
		# t = -2.895, df = 19, p-value = 0.009281
		# alternative hypothesis: true correlation is not equal to 0
		# 95 percent confidence interval:
		#  -0.7950526 -0.1597034
		# sample estimates:
		#        cor 
		# -0.5532483
}
#	p300:
if(prot == "p300") {
	# lys
	vertbarplots_energy_by_lig_lyssite <- ggplot(data=subset(data, data$bindsin_lys == 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		ylim(0, counts.max) +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ggtitle("Binding Affinity Frequencies by Ligand (lys Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_lyssite

	graph_name <- "vertbarplots_energy_by_lig_lyssite"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))

	# coa
	vertbarplots_energy_by_lig_coasite <- ggplot(data=subset(data, data$bindsin_coa== 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ylim(0, counts.max) +
		ggtitle("Binding Affinity Frequencies by Ligand (coa Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_coasite

	graph_name <- "vertbarplots_energy_by_lig_coasite"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))

	# side
	vertbarplots_energy_by_lig_sidesite <- ggplot(data=subset(data, data$bindsin_side == 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ylim(0, counts.max) +
		ggtitle("Binding Affinity Frequencies by Ligand (side Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_sidesite

	graph_name <- "vertbarplots_energy_by_lig_sidesite"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))

	# allo1
	vertbarplots_energy_by_lig_allo1site <- ggplot(data=subset(data, data$bindsin_allo1 == 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ylim(0, counts.max) +
		ggtitle("Binding Affinity Frequencies by Ligand (allo1 Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_allo1site

	graph_name <- "vertbarplots_energy_by_lig_allo1site"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))

	# allo2
	vertbarplots_energy_by_lig_allo2site <- ggplot(data=subset(data, data$bindsin_allo2 == 1), aes(x=E, fill=lig, group=lig)) +
		geom_bar(width=0.1) +
		coord_flip() +
		scale_fill_hue(guide=FALSE) +
		xlab("Binding energy (kcal/mol)") +
		scale_x_reverse(limits=c(max(data$E), min(data$E))) +
		ylim(0, counts.max) +
		ggtitle("Binding Affinity Frequencies by Ligand (allo2 Binding Site)") +
		theme(legend.title=element_text(face="bold")) +
		facet_grid(. ~ lig, drop=F)
	vertbarplots_energy_by_lig_allo2site

	graph_name <- "vertbarplots_energy_by_lig_allo2site"
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=(ligset_length / 10 * height)*2, height=height*1.5)
	print(paste0("Created ", graph_name))

}
####################



#	Multiple plot function
#
#	ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
#	- cols:   Number of columns in layout
#	- layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
#	If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
#	then plot 1 will go in the upper left, 2 will go in the upper right, and
#	3 will go all the way across the bottom.
#

# multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
# 	library(grid)
#
# 	# Make a list from the ... arguments and plotlist
# 	plots <- c(list(...), plotlist)
#
# 	numPlots = length(plots)
#
# 	# If layout is NULL, then use 'cols' to determine layout
# 	if (is.null(layout)) {
# 		# Make the panel
# 		# ncol: Number of columns of plots
# 		# nrow: Number of rows needed, calculated from # of cols
# 		layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
#                      ncol = cols, nrow = ceiling(numPlots/cols))
# 	}
#
# 	if (numPlots==1) {
# 		print(plots[[1]])
#
# 	} else {
# 		# Set up the page
# 		grid.newpage()
# 		pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
#
# 		# Make each plot, in the correct location
# 		for (i in 1:numPlots) {
# 			# Get the i,j matrix positions of the regions that contain this subplot
# 			matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
#
# 			print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
#                                       layout.pos.col = matchidx$col))
# 		}
# 	}
# }



# barplot_bindingdist_by_lig_combinedsites
# vertbarplots_energy_by_lig_allsites
# densities_energy_by_lig_overlay

# combined_bar_bySite_and_density_byLig <- multiplot(barplot_bindingdist_by_lig_combinedsites,
#                                                    densities_energy_by_lig_overlay, cols=2)
#	print(paste0(dock, "_", "combined_bar_bySite_and_density_byLig", ".pdf"))#, width=long_width, height=height)

# combined_bar_bySite_and_histograms_byLig <- multiplot(barplot_bindingdist_by_lig_combinedsites,
#                                                       vertbarplots_energy_by_lig_allsites, cols=2)
#	print(paste0(dock, "_", "combined_bar_bySite_and_histograms_byLig", ".pdf"))#, width=long_width, height=height)












####################
### Save data tables for % Distribution
distrib.table <- analysis[paste0("DistribFrac_", binding_sites)]
for(bs in binding_sites) {
	distrib.table[, bs] <- round(distrib.table[paste0("DistribFrac_", bs)] * 100, 2)
}
distrib.table <- distrib.table[binding_sites]
distrib_table_csv <- paste0(dock_dir, "/", dock, "_binding_site_distribution_table.csv")

write.csv(distrib.table, file=distrib_table_csv)
print(paste0("Created ", "binding_site_distribution_table"))

####################







################################################################################
print("All done, graphs can found in:")
print(graphs_dir, quote=F)

