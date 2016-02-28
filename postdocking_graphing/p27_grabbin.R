p27 <- read.csv("/Users/zarek/lab/Docking/p300/p27/p27_alldata.csv")
p27$key[p27$E < -6.25 & p27$E > -6.75 & p27$LIG == "Garcinol" & p27$resis_score_coa > .1]
