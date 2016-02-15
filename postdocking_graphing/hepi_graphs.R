### Docking data graphs (hepi)
#   2/14/16 Zarek Siegel

rm(list=ls(all=TRUE)) # clear out old variables
library(foreign) # for reading csv

### Basic parameters
dock <- "h29" # docking id
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
ligset.list <- c("adph", "fdla", "ab", "gb", "aam", 
                 "abm", "gam", "gbm", "ab3", "gb3", 
                 "ab6", "gb6", "ab7", "gb7", "aa8", 
                 "ab8", "ga8", "gb8", "gb8y", "aa10", 
                 "ab10", "ga10", "gb10")
### Look up ligset
# ** add this**, this (below) is temporary
binding.sites <- c("adph", "fdla")#, "allo")

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
colors <- c("lightskyblue1", "orange")#, "red3") # gotta make it pretty, you know

# Box plot of binding energies (in all sites) by ligand
pdf(paste(dock, "boxplots_bindingenergy_by_lig_ALL.pdf", sep="_"), width=14)
boxplot(E ~ LIG, data=data, main="Binding Energies by Ligand (all binding sites)",
        xlab="Ligand", ylab="Binding energy (kcal/mol)",
        col=c("darkred", "navy"))
dev.off()

# Strip chart to show energy frequency by ligand
pdf(paste(dock, "stripcharts_bindingenergy_by_lig_ALL.pdf", sep="_"), width=14)
stripchart(E ~ LIG, data=data, method = "stack", offset=1/40,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (all binding sites)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()

# Density to show energy frequency by ligand
pdf(paste(dock, "binding_energy_density_by_lig.pdf", sep="_"))
c <- 1
c.list <- c
plot(density(data$E), ylim=c(0,10), col=c[1],
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
binding.distrib.plot <- data.frame(row.names = ligset.list)
for(nbs in paste("Num.", binding.sites, sep="")) {
  binding.distrib.plot[, nbs] <- analysis[, nbs]
}
binding.distrib.plot <- t(as.matrix(binding.distrib.plot))

pdf(paste(dock, "binding_distrib_by_lig.pdf", sep="_"))
barplot(binding.distrib.plot,  main="Binding Distribution by Ligand",
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

pdf(paste(dock, "avgE_by_site.pdf", sep="_"), width=14)
barplot(AvgE.bysite.plot, main="Average Energy in Each Binding Site",
        xlab="Ligand", ylab="Binding energy (kcal/mol)",
        legend.text = binding.sites, beside = T,
        col=colors)
dev.off()

# Strip charts for each binding site
# ADPH
pdf(paste(dock, "stripcharts_bindingenergy_by_lig_adph.pdf", sep="_"), width=14)
stripchart(data$E[data$binds.in.adph] ~ data$LIG[data$binds.in.adph], method = "stack", offset=1/20,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (ADPH Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()
# FDLA
pdf(paste(dock, "stripcharts_bindingenergy_by_lig_fdla.pdf", sep="_"), width=14)
stripchart(data$E[data$binds.in.fdla] ~ data$LIG[data$binds.in.fdla], method = "stack", offset=1/20,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (FDLA Binding Site)",
           xlab="Ligand", ylab="Binding energy (kcal/mol)")
dev.off()
# ALLO
pdf(paste(dock, "stripcharts_bindingenergy_by_lig_allo.pdf", sep="_"), width=14)
stripchart(data$E[data$binds.in.allo] ~ data$LIG[data$binds.in.allo], method = "stack", offset=1/20,
           vertical=T, col=c("darkred", "navy"),
           main="Binding Affinity Frequencies by Ligand (Allosteric Binding Site)",
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



##############################
print("All done, graphs can found in:")
print(graphs.dir)