# IN
# docks_read <- "~/lab/Docking/docks.xlsx"
home_dir <- commandArgs(trailingOnly = TRUE)
# home_dir <- "~/lab"
docking <- paste(sep = "/", home_dir, "Docking")
docks_read <- paste(sep = "/", docking, "docks.xlsx" )
# docks_read

# OUT
docks_csvs <- paste(sep = "/", docking, "docks_csvs" )
docks_ligsets_csv <- paste(sep = "/", docks_csvs, "docks_ligsets.csv")
docks_gridboxes_csv <- paste(sep = "/", docks_csvs, "docks_gridboxes.csv")
docks_pdbs_csv <- paste(sep = "/", docks_csvs, "docks_pdbs.csv")
docks_p300_csv <- paste(sep = "/", docks_csvs, "docks_p300.csv")
docks_hepi_csv <- paste(sep = "/", docks_csvs, "docks_hepi.csv")

# library(xlsx)
require(xlsx)

docks_ligsets <- read.xlsx(docks_read, sheetName = "ligsets", colIndex = 1:5)
docks_gridboxes <- read.xlsx(docks_read, sheetName = "gridboxes", colIndex = 1:11)
docks_pdbs <- read.xlsx(docks_read, sheetName = "pdbs", colIndex = 1:6)
docks_p300 <- read.xlsx(docks_read, sheetName = "p300", colIndex = 1:12)
docks_hepi <- read.xlsx(docks_read, sheetName = "hepi", colIndex = 1:12)

write.csv(docks_ligsets, file = docks_ligsets_csv)
write.csv(docks_gridboxes, file = docks_gridboxes_csv)
write.csv(docks_pdbs, file = docks_pdbs_csv)
write.csv(docks_p300, file = docks_p300_csv)
write.csv(docks_hepi, file = docks_hepi_csv)

# print(docks_p300)


# if (dock == "p0") {
#   dock_sheet <- docks_p300
# }
# 
# dock_docks <- dock_sheet["DOCK"]
# # print(dock_docks)
# 
# # grep(dock, dock_docks)
# print(dock)
# cbind