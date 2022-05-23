#!/usr/bin/Rscript

load("dist.RData")

h <- hclust(d, method="average")
rm(d)

save.image("hclust.RData")
