
library(tidyverse)
library(tidyr)
library(ggplot2)
library(GGally)

set.seed(1984)

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")
# loads random individuals data set
individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
individuals <- tibble::rowid_to_column(individuals, "id")
individuals$id <- (individuals$id - 1)

# plots a violin-like plot showing how gene values are distributed
fmsColor <- "red";
windColor <- "green";
weatherColor <- "#e69f00";
individuals.long <- gather(individuals, param, value, params, factor_key=TRUE)
p <- ggplot(individuals.long, aes(x=param, y=value, fill=param)) + geom_violin() # geom_boxplot() + geom_jitter()
p + scale_fill_manual(values=c(fmsColor, fmsColor, fmsColor, fmsColor, "grey", windColor, windColor, weatherColor, weatherColor,"grey")) + coord_cartesian(ylim = c(0, 120))

# loads individuals run results data set
individualsResults <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera.txt', header=T)
individualsResults <- subset(individualsResults, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(individualsResults) <- c("id", params, "runtime", "maxRSS")

# generates the multiple linear regression model for runtime based on individuals run results
runtimeModel <- lm(runtime ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=individualsResults)
summary(runtimeModel)$coefficient 

# analyses the quality of the prediction
ds <- individualsResults
ds$prediction <- predict(runtimeModel, head(individuals, 1001))
ds$prediction <- ifelse(ds$prediction<1, 1, ds$prediction)
plot(ds$prediction, ds$runtime, xlab="predicted", ylab="actual", xlim=c(0,3600), ylim=c(0,3600))
abline(a=0, b=1)

qqplot(ds$prediction, ds$runtime)
abline(a=0, b=1)

qqnorm(residuals(runtimeModel))
abline(a=0, b=1)

qqnorm(rstandard(runtimeModel))
qqline(rstandard(runtimeModel))

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
# binwidth = 1 second
ggplot(results.long, aes(x=value, fill=hours)) + 
    geom_histogram(binwidth=1, color="grey30", fill="white") +
    facet_grid(case ~ .) + 
    xlim(0, 3600) + ## xlim(0, 300) 
    ylim(0, 250) ## ylim(0, .15)

# transform x-axis to log 10
ggplot(results.long, aes(x=value, fill=case)) + 
    geom_density(alpha=0.5) + 
    scale_x_log10(breaks=c(1,10,30,60,300,900,1800,3600))

ggplot(results.long, aes(value, colour = case)) + 
    stat_ecdf() + 
    scale_x_log10(breaks=c(1,10,30,60,300,900,1800,3600))

# plots the runtime for all individuals, with different shapes and colors for each case (solid colors)
p <- ggplot(results.long, aes(x = id, y = value)) 
p + geom_point(position = position_jitter(0.2)) +
aes(colour = factor(case)) +
aes( shape = factor(case)) 

# scatter plot the runtime for all individuals, with same shape and different colors for each case (with light solid colors)
p + geom_point(aes(color = case)) + 
scale_size_manual(values = c(2.5,2,1.5)) + 
scale_y_time() +
ylab("Runtime") + 
xlab("Individual") + 
labs(colour = "Hours") + 
labs(title = "Individuals's Runtime", subtitle = NULL)

# Correlation matrix
mydata <- mtcars[, c(1,3,4,5,6,7)]
results2 <- subset(results, select=c(params, "hours", "runtime"))
head(results2)
ggcorr(results2, palette = "Set3", label = TRUE)

# An overview with all correlation coeficients
ggpairs(results2)

ggplot(results, aes(x=p_ws, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm")

ggplot(results, aes(x=p_ws, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm") + 
    scale_y_log10()

ggplot(results, aes(x=p_hh, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm")

ggplot(results, aes(x=p_hh, y=runtime)) + 
    geom_point() + 
    geom_smooth(method = "lm") + 
    scale_y_log10()

cor(subset(results, select=c(params,"runtime")), method="pearson") 

results <- individualsResults
filteredResults <- subset(results, runtime > 5 & runtime < 13600)
customShape <- function(v){round(v/6)}
filteredResults$shape <- as.factor(customShape(filteredResults$p_10h)+1)
ggplot(filteredResults) +
    aes(x=p_ws, y=runtime, color=p_hh) + 
    geom_point(aes(shape=shape, size=p_th)) +
    geom_smooth(method = "lm") + 
    scale_y_log10()

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
    param, value, runtime, factor_key=TRUE)
head(resultsDeltas.long)

ggplot(resultsDeltas.long, aes(x=value, fill=hours)) + 
    geom_histogram(binwidth=1, color="grey30", fill="white") +
    facet_grid(case ~ .) + 
    xlim(0, 3600) + ## xlim(0, 300) 
    ylim(0, 18) ## ylim(0, .15)

# transform x-axis to log 10
ggplot(resultsDeltas.long, aes(x=value, fill=case)) + 
    geom_density(alpha=0.5) + 
    scale_x_log10(breaks=c(1,10,30,60,300,900,1800,3600))

rSquared <- function(m) {print(paste("r2:",format(summary(m)$r.squared, digits=2), "/ Adj r2:",format(summary(m)$adj.r.square, digits=2)))}
adjustedResults <- subset(resultsDeltas, case=="18a30hours")
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

#y ~ polym(x1, x2, degree=2, raw=TRUE)
#mlrm4 <- lm(runtime ~ p_1h + p_10h + p_100h + p_herb + p_1000h + p_ws + p_wd + p_th + p_hh + p_adj, data=adjustedResults)
mprm1 <- lm(runtime ~ polym(p_ws, p_hh, degree=11, raw=TRUE), data=adjustedResults)
mprm2 <- lm(runtime ~ polym(p_ws, p_hh, p_10h, degree=11, raw=TRUE), data=adjustedResults)
mprm3 <- lm(runtime ~ polym(p_ws, p_hh, p_th, p_10h, degree=11, raw=TRUE), data=adjustedResults)
rSquared(mprm1)
rSquared(mprm2)
rSquared(mprm3)

qqnorm(rstandard(mprm3))
qqline(rstandard(mprm3))

plot(residuals(mprm3))


