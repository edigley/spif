# https://mybinder.org/v2/gh/binder-examples/r/master?filepath=index.ipynb
library(tidyverse)
set.seed(1984)

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")

# loads random individuals data set
individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals<-read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
#individuals$id <- seq.int(nrow(individuals))
individuals <- tibble::rowid_to_column(individuals, "id")
individuals$id <- (individuals$id - 1)
head(individuals)

# loads individuals run results data set
individualsResults <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera.txt', header=T)
individualsResults <- subset(individualsResults, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(individualsResults) <- c("id", params, "runtime", "maxRSS")
head(individualsResults)

# generates the multiple linear regression model for runtime based on individuals run results
runtimeModel <- lm(runtime ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=individualsResults)
summary(runtimeModel)$coefficient 
#summary(runtimeModel)
#summary(runtimeModel)$coefficient 
#confint(runtimeModel)

# predicts runtime for the last 10 individuals
tail(individuals, 10)
predict(runtimeModel, tail(individuals, 10))

# generates the multiple linear regression model for maxRSS based on individuals run results
maxRSSModel <- lm(maxRSS ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=individualsResults)
summary(maxRSSModel)$coefficient 
#summary(maxRSSModel)
#summary(maxRSSModel)$coefficient 
#confint(maxRSSModel)

# predicts maximum memory consumption for the last 10 individuals
tail(individuals, 10)
predict(maxRSSModel, tail(individuals, 10))

# basic functions to compute a linear model based on estimates
predictRuntime <- function(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) {
    return (1053.9430 - 6.4106*p0 - 28.0236*p1 + 8.2743*p2 - 0.7945*p3 - 0.7570*p4 + 80.7271*p5 + 0.1784*p6 + 5.0583*p7 - 21.2987*p8 - 65.2531*p9)
}

predictMaxRSS <- function(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) {
    return (1053.9430 - 6.4106*p0 - 28.0236*p1 + 8.2743*p2 - 0.7945*p3 - 0.7570*p4 + 80.7271*p5 + 0.1784*p6 + 5.0583*p7 - 21.2987*p8 - 65.2531*p9)
}

predictForIndividual <- function(individual, regModel) {
    coefficients <- summary(regModel)$coefficient
    b0 <- coefficients['(Intercept)', 'Estimate']
    b1 <- coefficients['p_1h', 'Estimate']
    b2 <- coefficients['p_10h', 'Estimate']
    b3 <- coefficients['p_100h', 'Estimate']
    b4 <- coefficients['p_herb', 'Estimate']
    b5 <- coefficients['p_1000h', 'Estimate']
    b6 <- coefficients['p_ws', 'Estimate']
    b7 <- coefficients['p_wd', 'Estimate']
    b8 <- coefficients['p_th', 'Estimate']
    b9 <- coefficients['p_hh', 'Estimate']
    b10 <- coefficients['p_adj', 'Estimate']
    p_1h <- individual$p_1h
    p_10h <- individual$p_10h
    p_100h <- individual$p_100h
    p_herb <- individual$p_herb
    p_1000h <- individual$p_1000h
    p_ws <- individual$p_ws
    p_wd <- individual$p_wd
    p_th <- individual$p_th
    p_hh <- individual$p_hh
    p_adj <- individual$p_adj
    return (b0 + b1*p_1h + b2*p_10h + b3*p_100h + b4*p_herb + b5*p_1000h + b6*p_ws + b7*p_wd + b8*p_th + b9*p_hh + b10*p_adj)
}

individuals[1000,]

predictForIndividual(individuals[1000,], runtimeModel)

predictForIndividual(individuals[1000,], maxRSSModel)

