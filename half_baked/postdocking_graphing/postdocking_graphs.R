### Docking data graphs (hepi and p300 - pls1a and hls1)
#   2/14/16 Zarek Siegel
#   2/21/16 up to full ggplot2 replacement
#   2/23/16 more density plots, p300 and hepi compatible

rm(list=ls(all=TRUE)) # clear out old variables
library(foreign) # for reading csv
library(xlsx)
library(ggplot2)
library(reshape2)

### Basic parameters
dock <- "p5b" # docking id
if(substr(dock,0,1) == "p") {prot <- "p300"} # p300 dockings are labeled p##
if(substr(dock,0,1) == "h") {prot <- "hepi"} # hepi dockings are labeled h##
# assumptions
#   -dockings have a docking id of the form d##, 
#     where d represents the protein and ## is a number
#   -inallo the home docking directory, 
#     there is a directory with the protein's name (e.g. .../p300/).
#     (this is what I mean by 'dock directory')
#   -inallo the protein directory directory, 
#     there is a directory with the docking id (e.g. .../p300/p27/)
#   -inallo the docking directory,
#     threre is a CSV file called d##_alldata.csv (** see zarek or a sample for details)

# docks.xlsx <- "/Users/zarek/lab/Docking/docks.xlsx"
# dock.params <- read.xlsx2(docks.xlsx, sheetName = prot)
# 
# ligset <- as.character(dock.params$LIGSET[dock.params$DOCK == dock])
# 
# all.ligsets <- read.xlsx2(docks.xlsx, sheetName = "ligsets")
# ligset_list <- as.character(all.ligsets$lig_list[all.ligsets$name == ligset])
# ligset_list <- unlist(strsplit(ligset_list, "[ ]"))

# ### System directories
# docking.base.dir <- "/Users/zarek/lab/Docking/" 
# dock.dir <- paste(docking.base.dir, prot, "/", dock, "/", sep = "")
# graphs.dir <- paste(dock.dir, "graphs/", sep="")
# if(dir.exists(graphs.dir)) {
#   print("graphs directory was not created because it already exists")
# } else {dir.create(graphs.dir)}
# 
# ### Read in alldata.csv
# alldata.csv <- paste(dock.dir, dock, "_alldata.csv", sep="")
# data <- read.csv(alldata.csv)
# 
# ### Look up ligset
# # ** add this**, this (below) is temporary
# 
# # ligset_list <- c("adph", "fdla", "ab", "gb", "aam", 
# #                  "abm", "gam", "gbm", "ab3", "gb3", 
# #                  "ab6", "gb6", "ab7", "gb7", "aa8", 
# #                  "ab8", "ga8", "gb8", "gb8y", "aa10", 
# #                  "ab10", "ga10", "gb10")
# 
# ### Look up ligset
# #**KLUDGE* ** add this**, this (below) is temporary
# if(prot == "hepi") {
#   binding.sites <- c("adph", "fdla", "allo")
#   #***# Order levels
#   ncs.sugargrouped <- c("adph", "fdla", 
#                         "ab", "aam", "abm", "ab3", "ab6", 
#                         "ab7", "aa8", "ab8", "aa10", "ab10",
#                         "gb", "gam", "gbm", "gb3", "gb6", 
#                         "gb7", "ga8", "gb8", "gb8y", 
#                         "ga10", "gb10")
#   ligset_list <- ncs.sugargrouped
# }
# if(prot == "p300") {
#   binding.sites <- c("lys", "coa", "side", "allo1", "allo2") # "coa_adpp", "coa_pant",
#   ligset_list <- c("Garcinol", "CTB", "EGCG", "CTPB", "C646")
# }
# ##**##
# 
# ### Recode variables with more convenient names
# if(is.element(dock, c("p28", "p29", "p30"))) {
#   ligset.coded <- c("ng", "s2", "ne", "s1", "s3")
#   ligset.names <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
#   data$LIG <- ligset.names[match(data$LIG, ligset.coded)] 
#   data$LIG <- factor(data$LIG, levels = ligset.names)
# }
# if(is.element(dock, c("p27", "p31"))) {
#   ligset.names <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
#   data$LIG <- factor(data$LIG, levels = ligset.names)
# }

base_dir <- "/Users/zarek/GitHub/TaylorLab/zvina"
dock_dir <- paste0(base_dir, "/", prot, "/", dock)

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

### Read in alldata.csv
dock_alldata_csv <- paste0(dock_dir, "/", dock, "_alldata.csv")
data <- read.csv(dock_alldata_csv)

### Recode variables with more convenient names
if(ligset == "pls1a") {
#   ligset.coded <- c("ng", "s2", "ne", "s1", "s3")
#   ligset.names <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
  pls1a_renamed <- factor(c("Garcinol", "CTB", "EGCG", "CTPB", "C646"))
  data$lig <- ligset.names[match(data$LIG, ligset.coded)] 
  data$lig <- factor(data$LIG, levels = ligset.names)
  data$lig <- factor(data$lig, levels = pls1a_renamed)
}



### Look up ligset ***

### Create binds.in.SITE rows (T/F depending on score fraction)
binding.threshold <- 0.10 # threshold for binding fraction
for(bs in binding.sites) {
#   data[, paste("binds.in.", bs, sep = "")] <- rep(NA, nrow(data))
#   data[, paste("binds.in.", bs, sep = "")][data[,paste("resis_score_fraction_", bs, sep = "")] >= binding.threshold] <- T
#   data[, paste("binds.in.", bs, sep = "")][data[,paste("resis_score_fraction_", bs, sep = "")] < binding.threshold] <- F
  bindsin_bs <- paste0("binds.in.", bs)
  bs_fraction <- paste0(bs, "_fraction")
  data[, bindsin_bs] <- rep(NA, nrow(data))
  data[, bindsin_bs][data[,bs_fraction] >= binding.threshold] <- T
  data[, bindsin_bs][data[,bs_fraction] < binding.threshold] <- F
}

### Create analysis data frame
analysis <- data.frame(row.names = ligset_list)

# Build column headers for averages, minimums, standard deviations, distribution fractions
analysis.columns <- c("AvgE", "MinE", "StdevE", paste("Num.", binding.sites, sep = ""),
                      paste("DistribFrac.", binding.sites, sep = ""),
                      paste("AvgE.", binding.sites, sep = ""), paste("MinE.", binding.sites, sep = ""))
for(c in analysis.columns) {
  analysis[,c] <- rep(NA, length(ligset_list))
}

# Fill in analysis data
for(l in ligset_list) {
  analysis[l, "LIG"] <- l
  analysis[l, "AvgE"] <- mean(data$E[data$LIG == l]) # Overall average energy for lig
  analysis[l, "MinE"] <- min(data$E[data$LIG == l]) # Overall minimum energy for lig
  analysis[l, "StdevE"] <- sd(data$E[data$LIG == l]) # Overall standard deviation of energies for lig
  DistribFrac.Denom <- 0
  for(bs in binding.sites) {
    num.in.site <- length(data$E[data$LIG == l & data[, paste("binds.in.", bs, sep = "")] == T])
    analysis[l, paste("Num.", bs, sep = "")] <- num.in.site # Number binding in each site
    DistribFrac.Denom <- DistribFrac.Denom + num.in.site
    if(analysis[l, paste("Num.", bs, sep = "")] > 0) {
      analysis[l, paste("AvgE.", bs, sep = "")] <-  # Average energy for ligs binding in site
        mean(data$E[data$LIG == l & data[, paste("binds.in.", bs, sep = "")] == T])
      analysis[l, paste("MinE.", bs, sep = "")] <- # Minimum energy for ligs binding in site
        min(data$E[data$LIG == l & data[, paste("binds.in.", bs, sep = "")] == T])
    } else { # otherwise it will return Inf's
      analysis[l, paste("AvgE.", bs, sep = "")] <- NA
      analysis[l, paste("MinE.", bs, sep = "")] <- NA
    }
  }
  for(bs in binding.sites) { # fraction of bindings in site from count
    analysis[l, paste("DistribFrac.", bs, sep = "")] <-
      analysis[l, paste("Num.", bs, sep = "")] / DistribFrac.Denom
  }
}

################################################################################
################################################################################
################################################################################


# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


### Graphs!!!!!!!
setwd(graphs.dir) # needed for pdf names below
# bs.colors <- brewer.pal(length(binding.sites), "Set1")
# lig.colors <- brewer.pal(length(ligset_list), "Set2")

lig.palette <- "Greys"
 
####################
### Box plot of binding energies (in all sites) by ligand
boxplots_energy_vs_lig_allsites <- ggplot(data=data, aes(x=LIG, y=E)) +
  geom_boxplot(aes(fill=LIG)) +
  scale_fill_hue(name="Ligands") + # legend
  scale_x_discrete(limits=ligset_list) +
  xlab("Ligand") +
  ylab("Binding energy (kcal/mol)") +
  ggtitle("Binding Energies by Ligand (All binding sites)") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold"))
boxplots_energy_vs_lig_allsites
ggsave(paste0(dock, "_", "boxplots_energy_vs_lig_allsites", ".pdf"), width=12, height=8)
####################

####################
### Density of dockings over energy range
# All ligands combined
densities_energy_by_lig_allcombined <- ggplot(data=data, aes(x=E)) +
  geom_density() +
  xlab("Binding energy (kcal/mol)") +
  ggtitle("Overall Density of Dockings versus Binding Energy") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold"))
densities_energy_by_lig_allcombined
ggsave(paste0(dock, "_", "densities_energy_by_lig_allcombined", ".pdf"), width=12, height=8)
# Separate charts for each ligand, arranged in a grid
#   OK fine it actually wraps but whatever
densities_energy_by_lig_grid <- ggplot(data=data, aes(x=E, color=LIG, group=LIG)) +
  geom_density() +
  scale_color_hue(name="Ligands") + 
  xlab("Binding energy (kcal/mol)") +
  ggtitle("Density of Dockings versus Binding Energy by Ligand (All Binding Sites)") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold")) +
  facet_wrap(~LIG)
densities_energy_by_lig_grid
ggsave(paste0(dock, "_", "densities_energy_by_lig_grid", ".pdf"), width=12, height=8)
# *A*
# Same thing but overlayed
densities_energy_by_lig_overlay <- ggplot(data=data, aes(x=E, color=LIG)) +
  geom_density() +
  scale_color_hue(name="Ligands") + 
  scale_x_reverse(limits=c(max(data$E), min(data$E))) +
  xlab("Binding energy (kcal/mol)") +
  ylab("Probability density") +
  ggtitle("Density of Dockings versus Binding Energy (All Binding Sites)") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold"))
densities_energy_by_lig_overlay
ggsave(paste0(dock, "_", "densities_energy_by_lig_overlay", ".pdf"), width=6, height=4)
####################

####################
### Create a new melted data frame for energies with one unique entry per bidning site placement
data.E.bs.melted <- melt(data,
                         id.vars=c("key", "E", "LIG"), # ID variables - all the variables to keep but not split apart on
                         measure.vars=paste0("binds.in.", binding.sites) # The source columns
)
# This new variable will simply be name of the site
data.E.bs.melted$binding.placement <-  rep(NA, nrow(data.E.bs.melted))
data.E.bs.melted$binding.placement <- sub("binds.in.", "", data.E.bs.melted$variable) # data.E.bs.melted$variable is binds.in.SITE
data.E.bs.melted <- data.E.bs.melted[data.E.bs.melted$value, c("key", "E", "LIG", "binding.placement")] # data.E.bs.melted$value is T/F
### A density plot for all ligands with separate traces for each binding site
densities_energy_by_site_overlay <- ggplot(data=data.E.bs.melted, aes(x=E, color=binding.placement)) +
  geom_density() +
  scale_color_hue(name="Binding Site", labels=binding.sites) + 
  xlab("Binding energy (kcal/mol)") +
  ggtitle("Density of Dockings versus Binding Energy by Binding Site (All Ligands)") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold")) 
densities_energy_by_site_overlay
ggsave(paste0(dock, "_", "densities_energy_by_site_overlay", ".pdf"), width=12, height=8)
### A grid of density plots (lig vs. site) with single energy traces for each box
densities_energy_by_lig_and_site_grid <- ggplot(data=data.E.bs.melted, aes(x=E, color=binding.placement, group=LIG)) +
  geom_density() +
  facet_grid(binding.placement ~ LIG) +
  scale_color_hue(name="Binding Site", labels=binding.sites) + 
  xlab("Binding energy (kcal/mol)") +
  ggtitle("Density of Dockings versus Binding Energy by Binding Site and Ligand") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold")) 
densities_energy_by_lig_and_site_grid
ggsave(paste0(dock, "_", "densities_energy_by_lig_and_site_grid", ".pdf"), width=1.75*(length(ligset_list)+2), height=2*length(binding.sites))
####################












# *A*
data$combined.sites <- rep(NA, nrow(data))
binding.sites.capitalized <- c("Lys", "CoA", "Side", "Allo1", "Allo2")

for(r in 1:nrow(data)) {
  combined.sites <- NA
  # for(bs in binding.sites) {
  for(bs in binding.sites.capitalized) {
    # if(data[r, paste0("binds.in.", bs)]) {combined.sites <- c(combined.sites, bs) }
    if(data[r, paste0("binds.in.", tolower(bs))]) {combined.sites <- c(combined.sites, bs) }
  }
  data[r, "combined.sites"] <- paste(na.omit(combined.sites), collapse=" + ")
}
data$combined.sites[data$combined.sites == ""] <- "No site placement"

barplot_bindingdist_by_lig_combinedsites <- ggplot(data=data) +
  geom_bar(aes(x=LIG, fill=combined.sites), color="black", width=0.8) +
  scale_x_discrete(limits=ligset_list) +
  # scale_fill_hue(name="Binding Site(s)") +
  scale_fill_manual(values=c("orchid", "mediumpurple", "greenyellow", "mediumaquamarine", "grey"), 
  # scale_fill_brewer(palette="Set2", 
                    name="Binding Site(s)") + 
  xlab("Ligand") +
  ylab("Number of Ligands in Site") +
  ggtitle("Binding Site Placement Distribution by Ligand") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold"))
barplot_bindingdist_by_lig_combinedsites
ggsave(paste0(dock, "_", "barplot_bindingdist_by_lig_combinedsites", ".pdf"), width=6, height=4)







####################
### Bar plot of binding distribution in each binding site by ligand
# Make a data frame with only the binding site numbers
analysis.bindingsites <- analysis[c(paste("Num.", binding.sites, sep=""))]
analysis.bindingsites$bs_cat <- row.names(analysis.bindingsites)
# Melt this data frame for graphing
melted.analysis.bindingsites <- melt(analysis.bindingsites, id.vars = "bs_cat")
barplot_bindingdist_by_lig <- ggplot(data=melted.analysis.bindingsites, aes(x=bs_cat, y=value, fill=variable)) +
  geom_bar(stat="identity", color="black") +
  scale_x_discrete(limits=ligset_list) +
  scale_fill_hue(name="Binding Site", labels=binding.sites) +
  xlab("Ligand") +
  ylab("Number of Ligands in Site") +
  ggtitle("Binding Distribution by Ligand") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold"))
barplot_bindingdist_by_lig
ggsave(paste0(dock, "_", "barplot_bindingdist_by_lig", ".pdf"), width=12, height=8)
####################

####################
### Bar plot of average binding energy in each binding site per ligand
# Make a data frame with only the binding site numbers
analysis.avgenergies <- analysis[c(paste("AvgE.", binding.sites, sep=""))]
analysis.avgenergies$bs_cat <- row.names(analysis.avgenergies)
# Melt this data frame for graphing
melted.analysis.avgenergies <- melt(analysis.avgenergies, id.vars = "bs_cat")
barplot_avge_vs_lig_by_bs <- ggplot(data=melted.analysis.avgenergies, aes(x=bs_cat, y=value, fill=variable, width=0.75)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  scale_x_discrete(limits=ligset_list) +
  scale_fill_hue(name="Binding Site", labels=binding.sites) +
  xlab("Ligand") +
  ylab("Binding energy (kcal/mol)") +
  ggtitle("Average Energy by Binding Site") +
  theme(legend.title=element_text(face="bold"),
        plot.title=element_text(face="bold"))
barplot_avge_vs_lig_by_bs
ggsave(paste0(dock, "_", "barplot_avge_vs_lig_by_bs", ".pdf"), width=12, height=8)
####################

####################
counts.max <- 60
### 'Stripcharts' for energy by ligand
# Overall
vertbarplots_energy_by_lig_allsites <- ggplot(data=data, aes(x=E, fill=LIG, group=LIG)) +
  geom_bar(width=0.1) +
  coord_flip() +
  scale_fill_hue(guide=FALSE) + 
  xlab("Binding energy (kcal/mol)") +
  scale_x_reverse(limits=c(max(data$E), min(data$E))) +
  ylim(0, counts.max) +
  ggtitle("Binding Affinity Frequencies by Ligand (All binding sites)") +
  theme(plot.title=element_text(face="bold"),
         legend.title=element_text(face="bold")) +
  facet_grid(. ~ LIG, drop=F)
vertbarplots_energy_by_lig_allsites
ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_allsites", ".pdf"), width=12, height=8)
### For each binding site
# HepI:
if(prot == "hepi") {
  # ADPH
  vertbarplots_energy_by_lig_adphsite <- ggplot(data=subset(data, binds.in.adph), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ylim(0, counts.max) +
    ggtitle("Binding Affinity Frequencies by Ligand (ADPH Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_adphsite
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_adphsite", ".pdf"), width=12, height=8)
  # FDLA
  vertbarplots_energy_by_lig_fdlasite <- ggplot(data=subset(data, binds.in.fdla), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ylim(0, counts.max) +
    ggtitle("Binding Affinity Frequencies by Ligand (FDLA Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_fdlasite
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_fdlasite", ".pdf"), width=12, height=8)
  # ALLO
  vertbarplots_energy_by_lig_allosite <- ggplot(data=subset(data, binds.in.allo), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ylim(0, counts.max) +
    ggtitle("Binding Affinity Frequencies by Ligand (ALLO Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_allosite
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_allosite", ".pdf"), width=12, height=8)
  
  
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
# p300:
if(prot == "p300") {
  # lys
  vertbarplots_energy_by_lig_lyssite <- ggplot(data=subset(data, binds.in.lys), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    ylim(0, counts.max) +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ggtitle("Binding Affinity Frequencies by Ligand (lys Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_lyssite
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_lyssite", ".pdf"), width=12, height=8)
  # coa
  vertbarplots_energy_by_lig_coasite <- ggplot(data=subset(data, binds.in.coa), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ylim(0, counts.max) +
    ggtitle("Binding Affinity Frequencies by Ligand (coa Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_coasite
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_coasite", ".pdf"), width=12, height=8)
  # side
  vertbarplots_energy_by_lig_sidesite <- ggplot(data=subset(data, binds.in.side), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ylim(0, counts.max) +
    ggtitle("Binding Affinity Frequencies by Ligand (side Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_sidesite
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_sidesite", ".pdf"), width=12, height=8)
  # allo1
  vertbarplots_energy_by_lig_allo1site <- ggplot(data=subset(data, binds.in.allo1), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ylim(0, counts.max) +
    ggtitle("Binding Affinity Frequencies by Ligand (allo1 Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_allo1site
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_allo1site", ".pdf"), width=12, height=8)
  # allo2
  vertbarplots_energy_by_lig_allo2site <- ggplot(data=subset(data, binds.in.allo2), aes(x=E, fill=LIG, group=LIG)) +
    geom_bar(width=0.1) +
    coord_flip() +
    scale_fill_hue(guide=FALSE) +
    xlab("Binding energy (kcal/mol)") +
    scale_x_reverse(limits=c(max(data$E), min(data$E))) +
    ylim(0, counts.max) +
    ggtitle("Binding Affinity Frequencies by Ligand (allo2 Binding Site)") +
    theme(legend.title=element_text(face="bold")) +
    facet_grid(. ~ LIG, drop=F)
  vertbarplots_energy_by_lig_allo2site
  ggsave(paste0(dock, "_", "vertbarplots_energy_by_lig_allo2site", ".pdf"), width=12, height=8)
}
####################



barplot_bindingdist_by_lig_combinedsites
vertbarplots_energy_by_lig_allsites
densities_energy_by_lig_overlay

combined_bar_bySite_and_density_byLig <- multiplot(barplot_bindingdist_by_lig_combinedsites, 
                                                   densities_energy_by_lig_overlay, cols=2)
print(paste0(dock, "_", "combined_bar_bySite_and_density_byLig", ".pdf"))#, width=12, height=4)

combined_bar_bySite_and_histograms_byLig <- multiplot(barplot_bindingdist_by_lig_combinedsites, 
                                                      vertbarplots_energy_by_lig_allsites, cols=2)
print(paste0(dock, "_", "combined_bar_bySite_and_histograms_byLig", ".pdf"))#, width=12, height=4)












####################
### Save data tables for % Distribution
distrib.table <- analysis[paste("DistribFrac.", binding.sites, sep = "")]
for(bs in binding.sites) {
  distrib.table[, bs] <- round(distrib.table[paste("DistribFrac.", bs, sep = "")] * 100, 2)
} 
distrib.table <- distrib.table[binding.sites]
distrib.table.csv <- paste(dock, "bs_distribution_table.csv", sep="_")
write.csv(distrib.table, file=distrib.table.csv)
####################

g <- data.E.bs.melted
list <- g$key[g$E < -6.25 & g$E > -6.75 & g$LIG == "Garcinol" & g$binding.placement == "coa"]

write.table(list, file = "/Users/zarek/Desktop/list.txt",
            col.names=F, row.names=F, quote=F)





################################################################################
print("All done, graphs can found in:")
print(graphs.dir, quote=F)

