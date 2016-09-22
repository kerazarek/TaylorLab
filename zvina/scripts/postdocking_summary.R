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

args <- commandArgs()
script_path <- args[4]
script_path <- sub("--file=", "", script_path)

base_dir <- sub("/scripts/postdocking_graphs.R", "", script_path)
if(is.na(base_dir)) {
  base_dir <- "/Users/zarek/lab/zvina"
}

dock <- args[6]
dock <- "h11"


### Sourcing docking parameters from .../Dockings.csv
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

### Sourcing ligset list parameters from .../ligsets/LIGSET/LIGSET_list.txt
ligset_list_txt <- paste0(base_dir, "/ligsets/", ligset, "/", ligset, "_list.txt")
ligset_list <- read.delim(ligset_list_txt, header = F, sep = "\n")
ligset_list <- as.character(unlist(ligset_list))
ligset_list <- factor(ligset_list, levels = ligset_list)

### Read in alldata.csv to a data frama called 'data'
dock_dir <- paste0(base_dir, "/", prot, "/", dock)
dock_alldata_csv <- paste0(dock_dir, "/", dock, "_alldata.csv")
data <- read.csv(dock_alldata_csv)

### Recode variables with more convenient names (specifically added for particular ligsets)
if(ligset == "pls1a") {
	pls1a_coded <- c("ng", "s2", "ne", "s1", "s3")
	pls1a_renamed <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
	data$lig <- pls1a_renamed[match(data$lig, pls1a_coded)]
	data$lig <- factor(data$lig, levels = pls1a_renamed)
	ligset_list <- pls1a_renamed
}

### Source list of binding sites by looking at what files are in .../PROT/binding_sites/
binding_sites_dir <- paste0(base_dir, "/binding_sites/", prot_file)
binding_sites <- list.files(path = binding_sites_dir)
binding_sites <- sub(".pdb", "", binding_sites)

### Create binds_in_SITE rows (T/F depending on score fraction)
binding.threshold <- 0.10 # threshold for binding fraction
for(bs in binding_sites) {
	bindsin_bs <- paste0("bindsin_", bs)
	fraction_bs <- paste0("fraction_", bs)
	data[, bindsin_bs][data[,fraction_bs] == 1] <- T
	data[, bindsin_bs][data[,fraction_bs] == 0] <- F
}

######################################################################

### Create analysis data frame
analysis <- data.frame(row.names = ligset_list)

#	Build column headers for averages, minimums, standard deviations, distribution fractions
analysis.columns <- c("AvgE", "MinE", "StdevE", paste("Num_", binding_sites, sep = ""),
                      paste("DistribFrac_", binding_sites, sep = ""),
                      paste("AvgE_", binding_sites, sep = ""), paste("MinE_", binding_sites, sep = ""))

for(c in analysis.columns) {
	analysis[,c] <- rep(NA, length(ligset_list))
}

#	Fill in analysis data
for(l in ligset_list) {
	# print(l)
	analysis[l, "lig"] <- l
	analysis[l, "AvgE"] <- mean(data$E[data$lig == l]) # Overall average energy for lig
	analysis[l, "MinE"] <- min(data$E[data$lig == l]) # Overall minimum energy for lig
	analysis[l, "StdevE"] <- sd(data$E[data$lig == l]) # Overall standard deviation of energies for lig
	DistribFrac_Denom <- 0
	for(bs in binding_sites) {
		Num_bs <- paste0("Num_", bs)
		AvgE_bs <- paste0("AvgE_", bs)
		MinE_bs <- paste0("MinE_", bs)
		DistribFrac_bs <- paste0("DistribFrac_", bs)
		bindsin_bs <- paste0("bindsin_", bs)
		
		bindsin_count <- length(data$E[data$lig == l & data[, bindsin_bs] == T])
		analysis[l, Num_bs] <- bindsin_count # Number binding in each site
		
		DistribFrac_Denom <- DistribFrac_Denom + bindsin_count
		if(analysis[l, Num_bs] > 0) {
			analysis[l, AvgE_bs] <-  # Average energy for ligs binding in site
				mean(data$E[data$lig == l & data[, bindsin_bs] == T])
			analysis[l, MinE_bs] <- # Minimum energy for ligs binding in site
				min(data$E[data$lig == l & data[, bindsin_bs] == T])
		} else { # otherwise it will return Inf's
			analysis[l, AvgE_bs] <- NA
			analysis[l, MinE_bs] <- NA
		}
		print(analysis[l, Num_bs])

	}
}
# print(DistribFrac_Denom)
for(l in ligset_list) {
	for(bs in binding_sites) { # fraction of bindings in site from count
		print(analysis[l, Num_bs])
		DistribFrac <- analysis[l, Num_bs] / DistribFrac_Denom
		# print(DistribFrac)
		analysis[l, DistribFrac_bs] <- DistribFrac
	}
}

analysis_csv = paste0(dock_dir, "/", dock, "_summary_from_graphing.csv")

write.csv(analysis, file = analysis_csv)
print(paste0("Created summary CSV"))

analysis_csv = paste0(dock_dir, "/", dock, "_summary.csv")
analysis <- read.csv(analysis_csv)

################################################################################
################################################################################
################################################################################


### Graphs!!!!!!!
#	setwd(graphs_dir) # needed for pdf names below
#	bs.colors <- brewer.pal(length(binding_sites), "Set1")
#	lig.colors <- brewer.pal(length(ligset_list), "Set2")
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
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
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
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
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
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
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
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=6, height=4)
print(paste0("Created ", graph_name))

####################

####################
### Create a new melted data frame for energies with one unique entry per bidning site placement
data.E.bs.melted <- melt(data,
                         id.vars=c("key", "E", "lig"), # ID variables - all the variables to keep but not split apart on
                         measure.vars=paste0("binds_in_", binding_sites) # The source columns
)
#	This new variable will simply be name of the site
data.E.bs.melted$binding.placement <-  rep(NA, nrow(data.E.bs.melted))
data.E.bs.melted$binding.placement <- sub("binds_in_", "", data.E.bs.melted$variable) # data.E.bs.melted$variable is binds_in_SITE
data.E.bs.melted <- data.E.bs.melted[data.E.bs.melted$value, c("key", "E", "lig", "binding.placement")] # data.E.bs.melted$value is T/F
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
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
print(paste0("Created ", graph_name))

### A grid of density plots (lig vs. site) with single energy traces for each box
densities_energy_by_lig_and_site_grid <- ggplot(data=data.E.bs.melted, aes(x=E, color=binding.placement, group=lig)) +
	geom_density() +
	facet_grid(binding.placement ~ lig) +
	scale_color_hue(name="Binding Site", labels=binding_sites) +
	xlab("Binding energy (kcal/mol)") +
	ggtitle("Density of Dockings versus Binding Energy by Binding Site and Ligand") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
densities_energy_by_lig_and_site_grid

graph_name <- "densities_energy_by_lig_and_site_grid"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=1.75*(length(ligset_list)+2), height=2*length(binding_sites))
print(paste0("Created ", graph_name))

####################












#	*A*
data$combined.sites <- rep(NA, nrow(data))
binding_sites.capitalized <- c("Lys", "CoA", "Side", "Allo1", "Allo2")

for(r in 1:nrow(data)) {
	combined.sites <- NA
	# for(bs in binding_sites) {
	for(bs in binding_sites.capitalized) {
		# if(data[r, paste0("binds_in_", bs)]) {combined.sites <- c(combined.sites, bs) }
		if(data[r, paste0("binds_in_", tolower(bs))]) {combined.sites <- c(combined.sites, bs) }
	}
	data[r, "combined.sites"] <- paste(na.omit(combined.sites), collapse=" + ")
}
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
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=6, height=4)
print(paste0("Created ", graph_name))








####################
### Bar plot of binding distribution in each binding site by ligand
#	Make a data frame with only the binding site numbers
analysis.bindingsites <- analysis[c(paste("Num_", binding_sites, sep=""))]
analysis.bindingsites$bs_cat <- row.names(analysis.bindingsites)
#	Melt this data frame for graphing
melted.analysis.bindingsites <- melt(analysis.bindingsites, id.vars = "bs_cat")
barplot_bindingdist_by_lig <- ggplot(data=melted.analysis.bindingsites, aes(x=bs_cat, y=value, fill=variable)) +
	geom_bar(stat="identity", color="black") +
	scale_x_discrete(limits=ligset_list) +
	scale_fill_hue(name="Binding Site", labels=binding_sites) +
	xlab("Ligand") +
	ylab("Number of Ligands in Site") +
	ggtitle("Binding Distribution by Ligand") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
barplot_bindingdist_by_lig

graph_name <- "barplot_bindingdist_by_lig"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
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
	scale_x_discrete(limits=ligset_list) +
	scale_fill_hue(name="Binding Site", labels=binding_sites) +
	xlab("Ligand") +
	ylab("Binding energy (kcal/mol)") +
	ggtitle("Average Energy by Binding Site") +
	theme(legend.title=element_text(face="bold"),
				plot.title=element_text(face="bold"))
barplot_avge_vs_lig_by_bs

graph_name <- "barplot_avge_vs_lig_by_bs"
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
print(paste0("Created ", graph_name))

####################

####################

counts.max <- max(analysis[, paste0("Num_", binding_sites)])
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
ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
print(paste0("Created ", graph_name))

### For each binding site
#	HepI:
if(prot == "hepi") {
	# ADPH
	vertbarplots_energy_by_lig_adphsite <- ggplot(data=subset(data, binds_in_adph), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
	print(paste0("Created ", graph_name))

	# FDLA
	vertbarplots_energy_by_lig_fdlasite <- ggplot(data=subset(data, binds_in_fdla), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
	print(paste0("Created ", graph_name))

	# ALLO
	vertbarplots_energy_by_lig_allosite <- ggplot(data=subset(data, binds_in_allo), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
	print(paste0("Created ", graph_name))



	### Dan's Percent Inhibition data
	dan.data <- read.csv("/Users/zarek/lab/Resources/Dans_Percent_Inhib_Data.csv", header = T)
	dan.data$Ligand <- factor(dan.data$Ligand, levels = ncs.sugargrouped)
	dan_percent_inhib_barplot <- ggplot(data=dan.data, aes(x=Ligand, y=Percent.Inhibition, fill=Ligand)) +
		geom_bar(stat="identity") +
		scale_fill_discrete(guide=F) +
		xlab("Ligand") +
		ylab("Percent Inhibition") +
		ggtitle("In Vitro Percent Inhibition by Ligand (from Dan)") +
		theme(legend.title=element_text(face="bold"))
	dan_percent_inhib_barplot
	ggsave("dan_percent_inhib_barplot.pdf", width=12, height=8)
}
#	p300:
if(prot == "p300") {
	# lys
	vertbarplots_energy_by_lig_lyssite <- ggplot(data=subset(data, binds_in_lys), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
	print(paste0("Created ", graph_name))

	# coa
	vertbarplots_energy_by_lig_coasite <- ggplot(data=subset(data, binds_in_coa), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
	print(paste0("Created ", graph_name))

	# side
	vertbarplots_energy_by_lig_sidesite <- ggplot(data=subset(data, binds_in_side), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
	print(paste0("Created ", graph_name))

	# allo1
	vertbarplots_energy_by_lig_allo1site <- ggplot(data=subset(data, binds_in_allo1), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
	print(paste0("Created ", graph_name))

	# allo2
	vertbarplots_energy_by_lig_allo2site <- ggplot(data=subset(data, binds_in_allo2), aes(x=E, fill=lig, group=lig)) +
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
	ggsave(paste0(dock, "_", graph_name, ".pdf"), width=12, height=8)
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
#	print(paste0(dock, "_", "combined_bar_bySite_and_density_byLig", ".pdf"))#, width=12, height=4)

# combined_bar_bySite_and_histograms_byLig <- multiplot(barplot_bindingdist_by_lig_combinedsites,
#                                                       vertbarplots_energy_by_lig_allsites, cols=2)
#	print(paste0(dock, "_", "combined_bar_bySite_and_histograms_byLig", ".pdf"))#, width=12, height=4)












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

