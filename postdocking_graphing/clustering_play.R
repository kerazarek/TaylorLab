library(igraph)

cld <- read.csv("/Users/zarek/GitHub/TaylorLab/zvina/hepi/h11/h11_clustering.csv")

cldm <- as.matrix(cld[,2:ncol(cld)])
head(cldm)
am <- cldm < .8
graph(cld)
g <- graph_from_adjacency_matrix(am)

plot(g)

library(network)
cg <- cluster_edge_betweenness(g)
plot(as.network(am), displaylabels = T, displayisolates = F)
?plot.network()


plot(as.network(as_edgelist(clpyg)))
?plot.igraph

kmeans(as.matrix(clpy[,1:2]), 2)

?edge.betweenness.community
plot(as.dendrogram(cluster_edge_betweenness(clpyg, weights=clpy$aiad)))
cluster_fast_greedy(clpyg)


####
library(igraph)
clpy <- read.csv("/Users/zarek/Desktop/h11_cluster_test.csv")
clpyg <- graph_from_data_frame(clpy, directed = F)


groups <- cluster_edge_betweenness(clpyg, weights=clpy$aiad)
groups <- cluster_walktrap(clpyg, weights=clpy$aiad)
groups <- cluster_leading_eigen(clpyg, weights=clpy$aiad)
groups <- cluster_label_prop(clpyg, weights=clpy$aiad)
groups <- cluster_louvain(clpyg, weights=clpy$aiad)

modularity(groups)

plot(clpyg, vertex.size = 5, vertex.color = "red2", vertex.label.cex = .75,
     vertex.label.color = "black", edge.color = "black", 
     edge.arrow.size = clpy$aiad,
     mark.groups = groups)