### Docking data graphs (p300)
#   2/14/16 Zarek Siegel

rm(list=ls(all=TRUE)) # clear out old variables
library(foreign) # for reading csv

### Basic parameters
dock <- "p27" # docking id
if(substr(dock,0,1) == "p") {prot <- "p300"} # p300 dockings are labeled p##
if(substr(dock,0,1) == "h") {prot <- "hepi"} # hepi dockings are labeled h##
# assumptions
#   -dockings have a docking id of the form d##, 
#     where d represents the protein and ## is a number
#   -inside the home docking directory, 
#     there is a directory with the protein's name (e.g. .../p300/).
#     (this is what I mean by 'dock directory')
#   -inside the protein directory directory, 
#     there is a directory with the docking id (e.g. .../p300/p27/)
#   -inside the docking directory,
#     threre is a CSV file called d##_alldata.csv (** see zarek or a sample for details)

### System directories
docking.base.dir <- "/Users/zarek/lab/Docking/" 
dock.dir <- paste(docking.base.dir, prot, "/", dock, "/", sep = "")
graphs.dir <- paste(dock.dir, "graphs/", sep="")
if(dir.exists(graphs.dir)) {
  print("graphs directory was not created because it already exists")
} else {dir.create(graphs.dir)}

### Read in alldata.csv
alldata.csv <- paste(dock.dir, dock, "_alldata.csv", sep="")
data <- read.csv(alldata.csv)

### Look up ligset
# ** add this**, this (below) is temporary
ligset.list <- c("EGCG", "Garcinol", "CTPB", "CTB", "C646")
### Look up ligset
# ** add this**, this (below) is temporary
binding.sites <- c("lys", "coa", "side", "allo1", "allo2") # "coa_adpp", "coa_pant",

### Create binds.in.SITE rows (T/F depending on score fraction)
binding.threshold <- 0.10 # threshold for binding fraction
for(bs in binding.sites) {
  data[, paste("binds.in.", bs, sep = "")] <- rep(NA, nrow(data))
  data[, paste("binds.in.", bs, sep = "")][data[,paste("resis_score_fraction_", bs, sep = "")] >= binding.threshold] <- T
  data[, paste("binds.in.", bs, sep = "")][data[,paste("resis_score_fraction_", bs, sep = "")] < binding.threshold] <- F
}

### Create analysis data frame
analysis <- data.frame(row.names = ligset.list)

# Build column headers for averages, minimums, standard deviations, distribution fractions
analysis.columns <- c("AvgE", "MinE", "StdevE", paste("Num.", binding.sites, sep = ""),
                      paste("DistribFrac.", binding.sites, sep = ""),
                      paste("AvgE.", binding.sites, sep = ""), paste("MinE.", binding.sites, sep = ""))
for(c in analysis.columns) {
  analysis[,c] <- rep(NA, length(ligset.list))
}

# Fill in analysis data
for(l in ligset.list) {
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

### Graphs!!!!!!!
setwd(graphs.dir) # needed for pdf names below
colors <- c("lightskyblue1", "orange", "red3", "khaki1", "mediumslateblue") # gotta make it pretty, you know

# Box plot of binding energies (in all sites) by ligand
pdf("boxplots_bindingenergy_by_lig_ALL.pdf")
boxplot(E ~ LIG, data=data, main="Binding Energies by Ligand (all binding sites)",
        xlab="Ligand", ylab="Binding energy (kcal/mol)",
        col=c("darkred", "navy"))
dev.off()

# Strip chart to show energy frequency by ligand
pdf("stripcharts_bindingenergy_by_lig_ALL.pdf")
stripchart(E ~ LIG, data=data, method = "stack", offset=1/15,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (all binding sites)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()

# Density to show energy frequency by ligand
pdf("binding_energy_density_by_lig.pdf")
c <- 1
c.list <- c
plot(density(data$E), ylim=c(0,1.65), col=c[1],
     main="Density of Dockings versus Binding Energy",
     xlab="Binding energy (kcal/mol)", ylab="Density")
for(l in ligset.list) {
  c <- c+1
  c.list[c] <- c
  lines(density(data$E[data$LIG == l]), col=c)
}
legend("topleft", c("ALL", ligset.list), fill=c.list)
dev.off()

# Bar plot of binding distribution in each binding site per ligand
graph.in <- data.frame(row.names = ligset.list)
for(nbs in paste("Num.", binding.sites, sep="")) {
  graph.in[, nbs] <- analysis[, nbs]
}
graph.in <- t(as.matrix(graph.in))

pdf("binding_distrib_by_lig.pdf")
binding.distrib.plot <- barplot(graph.in,  main="Binding Distribution by Ligand",
        xlab="Ligand", ylab="Number of Ligands in Site",
        legend.text = binding.sites,
        col=colors)
dev.off()

# Bar plot of average binding energy in each binding site per ligand
AvgE.bysite.plot <- data.frame(row.names = ligset.list)
for(abs in paste("AvgE.", binding.sites, sep="")) {
  AvgE.bysite.plot[, abs] <- analysis[, abs]
}
AvgE.bysite.plot <- t(as.matrix(AvgE.bysite.plot))

pdf("avgE_by_site.pdf")
barplot(AvgE.bysite.plot, main="Average Energy in Each Binding Site",
        xlab="Ligand", ylab="Binding energy (kcal/mol)",
        legend.text = binding.sites, beside = T,
        col=colors)
dev.off()

###################################################

# Make data subsets for each binding site

# LYS
pdf("stripcharts_bindingenergy_by_lig_lys.pdf")
stripchart(data$E[data$binds.in.lys] ~ data$LIG[data$binds.in.lys], method = "stack", offset=1/15,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (Lysine Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()
# COA
pdf("stripcharts_bindingenergy_by_lig_coa.pdf")
stripchart(data$E[data$binds.in.coa] ~ data$LIG[data$binds.in.coa], method = "stack", offset=1/15,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (Acetyl-CoA Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()
# SIDE
pdf("stripcharts_bindingenergy_by_lig_all.pdf")
stripchart(data$E[data$binds.in.side] ~ data$LIG[data$binds.in.side], method = "stack", offset=1/15,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (Side Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()
# ALLO1
pdf("stripcharts_bindingenergy_by_lig_allo1.pdf")
stripchart(data$E[data$binds.in.allo1] ~ data$LIG[data$binds.in.allo1], method = "stack", offset=1/15,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (Allo1 Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()
# ALLO2
pdf("stripcharts_bindingenergy_by_lig_allo2.pdf")
stripchart(data$E[data$binds.in.allo2] ~ data$LIG[data$binds.in.allo2], method = "stack", offset=1/15,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (Allo2 Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()

###################################################

# Save data tables for % Distribution
distrib.table <- analysis[paste("DistribFrac.", binding.sites, sep = "")]
for(bs in binding.sites) {
  distrib.table[, bs] <- round(distrib.table[paste("DistribFrac.", bs, sep = "")] * 100, 2)
} 
distrib.table <- distrib.table[binding.sites]
distrib.table.csv <- paste(dock, "bs_distribution_table.csv", sep="_")
write.csv(distrib.table, file=distrib.table.csv)

plot(density(data$E[data$binds.in.side]))
           col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (Side Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")

##############################
print("All done, graphs can found in:")
print(graphs.dir)