# https://mybinder.org/v2/gh/binder-examples/r/master?filepath=index.ipynb
library(tidyverse)
library(ggplot2)
library(tidyr)
library(GGally)

set.seed(1984)

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")

# loads random individuals data set
individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
##individuals$id <- seq.int(nrow(individuals))
individuals <- tibble::rowid_to_column(individuals, "id")
individuals$id <- (individuals$id - 1)
#head(individuals)
setdiff(0:1000, individuals$id)

# plots a violin-like plot showing how gene values are distributed
fmsColor <- "red";
windColor <- "green";
weatherColor <- "#e69f00";
individuals.long <- gather(individuals, param, value, params, factor_key=TRUE)
ggplot(individuals.long, aes(x=param, y=value, fill=param)) + 
    geom_violin() + # geom_boxplot() + geom_jitter()
    scale_fill_manual(values=c(fmsColor, fmsColor, fmsColor, fmsColor, "grey", windColor, windColor, weatherColor, weatherColor,"grey")) +
    coord_cartesian(ylim = c(0, 120)) #scale_y_log10(breaks=c(1,10,100,400))

# loads individuals run results data set
individualsResults <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera.txt', header=T)
individualsResults <- subset(individualsResults, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(individualsResults) <- c("id", params, "runtime", "maxRSS")
#head(individualsResults)
setdiff(0:1000, individualsResults$id)

# generates the multiple linear regression model for runtime based on individuals run results
runtimeModel <- lm(runtime ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=individualsResults)
summary(runtimeModel)$coefficient 
#summary(runtimeModel)
#summary(runtimeModel)$coefficient 
#confint(runtimeModel)

# predicts runtime for the last 10 individuals
#tail(individuals, 10)
predict(runtimeModel, tail(individuals, 10))

# generates the multiple linear regression model for maxRSS based on individuals run results
maxRSSModel <- lm(maxRSS ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=individualsResults)
summary(maxRSSModel)$coefficient 
#summary(maxRSSModel)
#summary(maxRSSModel)$coefficient 
#confint(maxRSSModel)

# predicts maximum memory consumption for the last 10 individuals
#tail(individuals, 10)
predict(maxRSSModel, tail(individuals, 10))

# basic functions to compute a linear model based on estimates
predictRuntime <- function(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) {
    return (1053.9430 - 6.4106*p0 - 28.0236*p1 + 8.2743*p2 - 0.7945*p3 - 0.7570*p4 + 80.7271*p5 + 0.1784*p6 + 5.0583*p7 - 21.2987*p8 - 65.2531*p9)
}

predictMaxRSS <- function(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9) {
    return (1053.9430 - 6.4106*p0 - 28.0236*p1 + 8.2743*p2 - 0.7945*p3 - 0.7570*p4 + 80.7271*p5 + 0.1784*p6 + 5.0583*p7 - 21.2987*p8 - 65.2531*p9)
}

predictForIndividual <- function(regModel, individual) {
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

predictForIndividual(runtimeModel, individuals[1000,])

predictForIndividual(maxRSSModel, individuals[1000,])

# analyses the quality of the prediction
ds <- individualsResults
ds$prediction <- predict(runtimeModel, head(individuals, 1001))
ds$prediction <- ifelse(ds$prediction<1, 1, ds$prediction)
summary(ds$prediction)
summary(ds$runtime)
head(ds)
plot(ds$prediction, ds$runtime, xlab="predicted", ylab="actual", xlim=c(0,88600), ylim=c(0,88600))
abline(a=0, b=1)

qqplot(ds$prediction, ds$runtime)
abline(a=0, b=1)

# histograms and density function for all cases
metricsOfInterest <- c("runtime") #, "maxRSS")
columnsOfInterest <- c("id", params, metricsOfInterest)

results12hours <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_12_hours.txt', header=T)
results12hours <- subset(results12hours, select=c("individual", paste("p", 0:9, sep=""), metricsOfInterest))
colnames(results12hours) <- columnsOfInterest

results18hours <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_18_hours.txt', header=T)
results18hours <- subset(results18hours, select=c("individual", paste("p", 0:9, sep=""), metricsOfInterest))
colnames(results18hours) <- columnsOfInterest

results24hours <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_24_hours.txt', header=T)
results24hours <- subset(results24hours, select=c("individual", paste("p", 0:9, sep=""), metricsOfInterest))
colnames(results24hours) <- columnsOfInterest

results30hours <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_30_hours.txt', header=T)
results30hours <- subset(results30hours, select=c("individual", paste("p", 0:9, sep=""), metricsOfInterest))
colnames(results30hours) <- columnsOfInterest

cases <- c(12,18,24,30)
cases <- paste(cases, "hours", sep="")
results12hours$case <- "12hours"
results12hours$hours <- 12
results18hours$case <- "18hours"
results18hours$hours <- 18
results24hours$case <- "24hours"
results24hours$hours <- 24
results30hours$case <- "30hours"
results30hours$hours <- 30

results <- rbind(results12hours, results18hours, results24hours, results30hours)
head(results)

results.long <- gather(
    subset(results, case %in% cases, select=c("case", "id", "runtime")),
    param, value, runtime, factor_key=TRUE
)
head(results.long)

# plots a histogram with three box, one for each case
# binwidth = 60 seconds
ggplot(results.long, aes(x=value, fill=case)) + 
    geom_histogram(binwidth=60, color="grey30", fill="white") +
    facet_grid(case ~ .) + 
    xlim(0, 3600) +    
    ylim(0, 200)

# plots a histogram with three box, one for each case
# binwidth = 1 second
ggplot(results.long, aes(x=value, fill=hours)) + 
    geom_histogram(binwidth=1, color="grey30", fill="white") +
    facet_grid(case ~ .) + 
    xlim(0, 3600) + ## xlim(0, 300) 
    ylim(0, 250) ## ylim(0, .15)

# density plot (transform x-axis to log 10)
ggplot(results.long, aes(x=value, fill=case)) + 
    geom_density(alpha=0.5) + 
    scale_x_log10(breaks=c(1,10,30,60,300,900,1800,3600))

# plots a cumulative distribution for all the cases
ggplot(results.long, aes(value, colour = case)) + 
    stat_ecdf() + 
    scale_x_log10(breaks=c(1,10,30,60,300,900,1800,3600))

# plots the runtime for all individuals, with different shapes and colors for each case (solid colors)
p <- ggplot(results.long, aes(x = id, y = value)) 
p + geom_point(position = position_jitter(0.2)) +
aes(colour = factor(case)) +
aes( shape = factor(case)) 

# plots the runtime for all individuals, with different shapes and colors for each case (with light and transparent colors)
p <- ggplot(results.long, aes(x = id, y = value)) 
p + geom_point(position = position_jitter(0.2), alpha=0.7) +
aes(colour = factor(case)) +
aes( shape = factor(case)) +
scale_shape_manual(values = c(1,3,5)) +
scale_size_manual(values = c(.1,.1,.1))

# scatter plot the runtime for all individuals, with same shape and different colors for each case (with light solid colors)
p + geom_point(aes(color = case)) + 
scale_size_manual(values = c(2.5,2,1.5)) + 
scale_y_time() +
ylab("Runtime") + 
xlab("Individual") + 
labs(colour = "Hours") + 
labs(title = "Individuals's Runtime", subtitle = NULL)   
# + geom_rug()
# + scale_color_brewer(palette = "Dark2") + theme_minimal()

# ---------------------------------------------------------------
# Correlation matrix
#source("https://raw.githubusercontent.com/briatte/ggcorr/master/ggcorr.R")
mydata <- mtcars[, c(1,3,4,5,6,7)]
results2 <- subset(results, select=c(params, "hours", "runtime"))
head(results2)
ggcorr(results2, palette = "Set3", label = TRUE)

# An overview with all correlation coeficients
ggpairs(results2)

cor(subset(individualsResults, select=c(params,"runtime")), method="pearson")
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# Plots a regression line considering only wind speed effect
ggplot(results, aes(x=p_ws, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm")
ggplot(results, aes(x=p_ws, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm") + 
    scale_y_log10()

# Plots a regression line considering only wind humidity effect
ggplot(results, aes(x=p_hh, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm")
ggplot(results, aes(x=p_hh, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm") + 
    scale_y_log10()
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# A multidimensional plot considering th, hh, ws and fms
results <- individualsResults
filteredResults <- subset(results, runtime > 5 & runtime < 13600)
customShape <- function(v){round(v/6)}
filteredResults$shape <- as.factor(customShape(filteredResults$p_10h)+1)
ggplot(filteredResults) +
    aes(x=p_ws, y=runtime, color=p_hh) + 
    geom_point(aes(shape=shape, size=p_th)) +
    geom_smooth(method = "lm") + 
    scale_y_log10() 
# ---------------------------------------------------------------

# ---------------------------------------------------------------
simplerRuntimeModel <- lm(runtime ~ p_ws + p_wd + p_hh, data=individualsResults)
coefficients(simplerRuntimeModel)
confint(simplerRuntimeModel, level=0.95)
head(fitted(simplerRuntimeModel))
subset(head(individualsResults), select=c("id", "runtime"))
head(residuals(simplerRuntimeModel))
plot(sort(residuals(simplerRuntimeModel)))
plot(density(residuals(adjustedRuntimeModel)))
names(summary(adjustedRuntimeModel))
summary(adjustedRuntimeModel)$r.squared
summary(adjustedRuntimeModel)$adj.r.squared
# ---------------------------------------------------------------
rSquared <- function(m) {print(paste("r2:",format(summary(m)$r.squared, digits=2), "/ Adj r2:",format(summary(m)$adj.r.square, digits=2)))}
adjustedResults <- subset(results, runtime > 5 & runtime < 3600)
slrm1 <- lm(runtime ~ p_ws, data=adjustedResults)
slrm2 <- lm(runtime ~ p_hh, data=adjustedResults)
slrm3 <- lm(runtime ~ p_th, data=adjustedResults)
slrm4 <- lm(runtime ~ p_10h, data=adjustedResults)
mlrm1 <- lm(runtime ~ p_ws + p_hh, data=adjustedResults)
mlrm2 <- lm(runtime ~ p_ws + p_hh + p_10h, data=adjustedResults)
mlrm3 <- lm(runtime ~ p_ws + p_hh + p_10h + p_th, data=adjustedResults)
mlrm4 <- lm(runtime ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=adjustedResults)
rSquared(slrm1)
rSquared(slrm2)
rSquared(slrm3)
rSquared(slrm4)
rSquared(mlrm1)
rSquared(mlrm2)
rSquared(mlrm3)
rSquared(mlrm4)
qqnorm(rstandard(mlrm4))
qqline(rstandard(mlrm4))
abline(a=0, b=1)
# ---------------------------------------------------------------
# Polynomial Regression Multipla
# y ~ polym(x1, x2, degree=2, raw=TRUE)
#mlrm4 <- lm(runtime ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=adjustedResults)
mprm1 <- lm(runtime ~ polym(p_ws, p_hh, degree=20, raw=TRUE), data=adjustedResults)
mprm2 <- lm(runtime ~ polym(p_ws, p_hh, p_10h, degree=20, raw=TRUE), data=adjustedResults)
mprm3 <- lm(runtime ~ polym(p_ws, p_hh, p_th, p_10h, degree=20, raw=TRUE), data=adjustedResults)
rSquared(mprm1)
rSquared(mprm2)
rSquared(mprm3)
qqnorm(rstandard(mprm3))
qqline(rstandard(mprm3))
plot(residuals(mprm3))
# ---------------------------------------------------------------
ggplot(filteredResults) + 
    aes(x=p_ws, y=p_hh, color=runtime/60) +
    geom_point(aes(size=runtime/60))
# ---------------------------------------------------------------

# plots all runtime sorted
plot(sort(individualsResults$runtime))
plot(sort(subset(individualsResults, runtime < 3600)$runtime))

barplot(sort(subset(individualsResults, runtime >= 3600)$p_ws))
barplot(sort(subset(individualsResults, runtime >= 3600)$p_wd))
barplot(sort(subset(individualsResults, runtime >= 3600)$p_hh))
barplot(sort(subset(individualsResults, runtime >= 3600)$p_adj))
barplot(sort(subset(individualsResults, runtime >= 3600)$p_1h))
barplot(sort(subset(individualsResults, runtime >= 3600)$p_10h))
barplot(sort(subset(individualsResults, runtime >= 3600)$p_100h))
quantile(individualsResults$runtime/60,probs = c(0.1,0.25,0.50,0.75,0.90,0.95,0.955))
# ---------------------------------------------------------------
params
cor(subset(individualsResults, select=c(params,"runtime")), method="pearson") 
cases <- c("0a30hours","12a30hours","18a30hours","24a30hours")

results0a30hours <- results30hours
results0a30hours$case <- "0a30hours"
results0a30hours$hours <- 30
results0a30hours$runtime <- results30hours$runtime

results12a30hours <- results30hours
results12a30hours$case <- "12a30hours"
results12a30hours$hours <- 18
results12a30hours$runtime <- results30hours$runtime - results12hours$runtime

results18a30hours <- results30hours
results18a30hours$case <- "18a30hours"
results18a30hours$hours <- 12
results18a30hours$runtime <- results30hours$runtime - results18hours$runtime

results24a30hours <- results30hours
results24a30hours$case <- "24a30hours"
results24a30hours$hours <- 6
results24a30hours$runtime <- results30hours$runtime - results24hours$runtime

resultsDeltas <- rbind(results0a30hours, results12a30hours, results18a30hours, results24a30hours)
cases = c("0a30hours","12a30hours","18a30hours","24a30hours");
resultsDeltas.long <- gather(
    subset(resultsDeltas, case %in% cases, select=c("case", "id", "runtime")),
    param, value, runtime, factor_key=TRUE
)
head(resultsDeltas.long)

# histogram for all 4 cases
ggplot(resultsDeltas.long, aes(x=value, fill=hours)) + 
    geom_histogram(binwidth=1, color="grey30", fill="white") +
    facet_grid(case ~ .) + 
    xlim(0, 3600) + ## xlim(0, 300) 
    ylim(0, 18) ## ylim(0, .15)

# density plot (transform x-axis to log 10)
ggplot(resultsDeltas.long, aes(x=value, fill=case)) + 
    geom_density(alpha=0.5) + 
    scale_x_log10(breaks=c(1,10,30,60,300,900,1800,3600))

# ---------------------------------------------------------------

DF <- read.table(text="Rank F1     F2     F3
1    500    250    50
2    400    100    30
3    300    155    100
4    200    90     10", header=TRUE)

library(reshape2)
DF1 <- melt(DF, id.var="Rank")
DF1
p <- ggplot(DF1, aes(x = Rank, y = value, fill = variable)) +
  geom_bar(stat = "identity")

filter(results.long, id >= 0 & id < 5)
ggplot(filter(results.long, id >= 0 & id < 5), aes(x = id, y = value, fill = case)) +
  geom_bar(stat = "identity")
# ---------------------------------------------------------------

ggplot(filter(results.long, id >= 0 & id < 5), aes(x = id, y = value, fill = case)) +
  geom_bar(stat = "identity", position = "dodge")
ggplot(filter(results.long, id >= 0 & id < 5), aes(x = id, y = value, fill = case)) +
  geom_bar(stat = "identity", position = "stack")
ggplot(filter(results.long, id >= 0 & id < 5), aes(x = id, y = value, fill = case)) +
  geom_bar(stat = "identity", position = "fill")
# ---------------------------------------------------------------

# Separate regressions of mpg on weight for each number of cylinders
## qplot(d$p_ws, d$runtime, data=d, geom=c("point", "smooth"), 
##   method="lm", formula=runtime~p_ws, 
##   main="Regression of Runtime on Wind Speed", 
##   xlab="Wind Speed", ylab="Runtime")

#ggplot(d, aes(x=p_ws, y=runtime)) + geom_point() + geom_smooth(method = "lm")

#plot(runtime ~ p_ws, data = d)
#abline(runtimeModel)

ggplot(d, aes(x=p_ws, y=runtime)) + geom_point() + 
stat_function(fun = function(x) predict(runtimeModel, newdata = data.frame(DepDelay=x)))

https://mybinder.org/
https://github.com/edigley/spif
master
notebooks/quality_of_prediction.ipynb
https://mybinder.org/v2/gh/edigley/spif/master?filepath=notebooks%2Fquality_of_prediction.ipynb
Loading repository: edigley/spif/master
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/edigley/spif/master?filepath=notebooks%2Fquality_of_prediction.ipynb)


https://hub.mybinder.org/user/edigley-spif-t135e6u1/notebooks/notebooks/quality_of_prediction.ipynb
https://hub.mybinder.org/user/edigley-spif-vcpdreuo/notebooks/notebooks/quality_of_prediction.ipynb