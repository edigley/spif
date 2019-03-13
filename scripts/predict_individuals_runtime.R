# https://mybinder.org/v2/gh/binder-examples/r/master?filepath=index.ipynb
library(tidyverse)
set.seed(1984)

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")

# loads individuals run results data set
ds <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera.txt', header=T)
ds <- subset(ds, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(ds) <- c("id", params, "runtime", "maxRSS")
head(ds)

# loads random individuals data set
individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals<-read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
#individuals$id <- seq.int(nrow(individuals))
individuals <- tibble::rowid_to_column(individuals, "id")
head(individuals)

# generates the multiple linear regression model for runtime based on individuals run results
model <- lm(runtime ~ p_1h + p_10h+ p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=ds)
summary(model)$coefficient 
#summary(model)
#summary(model)$coefficient 
#confint(model)

# predicts runtime for the last 10 individuals
tail(individuals, 10)
predict(model, tail(individuals, 10))
