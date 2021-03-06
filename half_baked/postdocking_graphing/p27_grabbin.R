p27 <- read.csv("/Users/zarek/lab/Docking/p300/p27/p27_alldata.csv")
p27$key[p27$E < -6.25 & p27$E > -6.75 & p27$LIG == "Garcinol" & p27$resis_score_coa > .1]
side.binders <- data[data$binds.in.side & data$LIG != "C646",]


p27.egcg <- p27[p27$LIG == "EGCG",]
p27.garc <- p27[p27$LIG == "Garcinol",] 
p27.ctb <- p27[p27$LIG == "CTB",]
p27.ctpb <-  p27[p27$LIG == "CTPB",]
p27.c646 <-  p27[p27$LIG == "C646",]

library("RColorBrewer")
brewer.pal(20, "Greys")
rainbow(8)
