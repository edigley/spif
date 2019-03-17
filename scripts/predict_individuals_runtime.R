# https://mybinder.org/v2/gh/binder-examples/r/master?filepath=index.ipynb
library(tidyverse)
set.seed(1984)

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")

# loads random individuals data set
individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
#individuals$id <- seq.int(nrow(individuals))
individuals <- tibble::rowid_to_column(individuals, "id")
individuals$id <- (individuals$id - 1)
head(individuals)
fmsColor <- "red";
windColor <- "green";
weatherColor <- "#e69f00";
individuals.long <- gather(individuals, param, value, params, factor_key=TRUE)
p <- ggplot(individuals.long, aes(x=param, y=value, fill=param)) + geom_violin() # geom_boxplot() + geom_jitter()
p + scale_fill_manual(values=c(fmsColor, fmsColor, fmsColor, fmsColor, "grey", windColor, windColor, weatherColor, weatherColor,"grey"))


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

# histograms and density function for all cases
results12hours <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_12_hours.txt', header=T)
results12hours <- subset(results12hours, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(results12hours) <- c("id", params, "runtime", "maxRSS")
head(results12hours)

results18hours <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_18_hours.txt', header=T)
results18hours <- subset(results18hours, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(results18hours) <- c("id", params, "runtime", "maxRSS")
head(results18hours)

results30hours <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera_30_hours.txt', header=T)
results30hours <- subset(results30hours, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))
colnames(results30hours) <- c("id", params, "runtime", "maxRSS")
head(results30hours)

library(ggplot2)
library("tidyr")

cases <- c(12,18,30)
cases <- paste(cases, "hours", sep="")
results12hours$case <- "12hours"
results12hours$hours <- 12
results18hours$case <- "18hours"
results18hours$hours <- 18
results30hours$case <- "30hours"
results30hours$hours <- 30

results <- rbind(results12hours, results18hours, results30hours)
head(results)

results1 <- subset(results, case %in% cases, select=c("case", "id", "runtime"))
results.long <- gather(results1, param, value, runtime, factor_key=TRUE)
head(results.long)

# plots a histogram with three box, one for each case
ggplot(results.long, aes(x=value, fill=case)) + 
    geom_histogram(binwidth=60, color="grey30", fill="white") +
    facet_grid(case ~ .) + 
    xlim(0, 3600) +    
    ylim(0, 200)

# plots a density function overlaying all the cases on the same plot
ggplot(results.long, aes(x=value, fill=case)) + 
    geom_density(alpha=0.5) +  
    xlim(0, 300) + 
    ylim(0, .15)

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

ggplot(results.long, aes(value, colour = case)) + stat_ecdf()

ggplot(filter(results.long, id >= 0 & id < 5), aes(x = id, y = value, fill = case)) +
  geom_bar(stat = "identity", position = "dodge")
ggplot(filter(results.long, id >= 0 & id < 5), aes(x = id, y = value, fill = case)) +
  geom_bar(stat = "identity", position = "stack")
ggplot(filter(results.long, id >= 0 & id < 5), aes(x = id, y = value, fill = case)) +
  geom_bar(stat = "identity", position = "fill")

p <- ggplot(results.long, aes(x = id, y = value)) 
p + geom_point(position = position_jitter(0.2)) +
aes(colour = factor(case)) +
aes( shape = factor(case)) 


p <- ggplot(results.long, aes(x = id, y = value)) 
p + geom_point(position = position_jitter(0.2), alpha=0.7) +
aes(colour = factor(hours)) +
aes( shape = factor(hours)) +
scale_shape_manual(values = c(1,3,5)) +
scale_size_manual(values = c(.1,.1,.1))


p + geom_point(aes(color = hours)) + 
scale_size_manual(values = c(2.5,2,1.5)) + 
scale_y_time() +
ylab("Runtime") + 
xlab("Individual") + 
labs(colour = "Hours") + 
labs(title = "Individuals's Runtime", subtitle = NULL)  
# + geom_rug()
# + scale_color_brewer(palette = "Dark2") + theme_minimal()

# Coorelation matrix
require("GGally")
source("https://raw.githubusercontent.com/briatte/ggcorr/master/ggcorr.R")
mydata <- mtcars[, c(1,3,4,5,6,7)]
results2 <- subset(results, select=c(params, "hours", "runtime"))
head(results2)
ggcorr(results2, palette = "Set3", label = TRUE)


install.packages("GGally")
require("GGally")
ggpairs(results2)

p1 <- ggplot(results, aes(x=p_ws, y=runtime)) + geom_point() + geom_smooth(method = "lm")
p1


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
