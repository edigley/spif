library(tidyverse)
library(tidyr)
library(ggplot2)
library(GGally)
library(caret)

set.seed(1984)

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")
# loads random individuals data set
individualHeader <- c(params, paste("p", seq(11,21), sep=""))
individuals <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals.txt', skip=1, col.names=individualHeader)
individuals <- subset(individuals, select=params)
individuals <- tibble::rowid_to_column(individuals, "id")
individuals$id <- (individuals$id - 1)

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

ds <- individualsResults

#We first set up the number of folds for cross-validation by defining the training control.
data_ctrl <- trainControl(method = "cv", number = 10)
#Next, we run our regression model: ACT ~ gender + age + SATV + SATQ.
# runtime ~ p_ws + p_hh + p_th + p_10h
runtimeLMModel <- train(
    runtime ~ p_ws + p_hh + p_th + p_10h,
    data = ds,
    trControl = data_ctrl,
    method = "lm",
    na.action = na.pass
)

maxRSSLMModel <- train(
    maxRSS ~ p_ws + p_hh + p_th + p_10h,
    data = ds,
    trControl = data_ctrl,
    method = "lm",
    na.action = na.pass
)

maxRSSLMModel
maxRSSLMModel$finalModel
maxRSSLMModel$resample
sd(maxRSSLMModel$resample$Rsquared)

runtimeLMModel
runtimeLMModel$finalModel
runtimeLMModel$resample
sd(runtimeLMModel$resample$Rsquared)


runtime ~ polym(p_ws, p_hh, p_th, p_10h, degree=20, raw=TRUE)

#Generalized Linear Model (method = 'glm'), For classification and regression with no tuning parameters 
method <- "glm"
#Generalized Linear Model with Stepwise Feature Selection (method = 'glmStepAIC'), For classification and regression using package MASS with no tuning parameters 
method <- "glmStepAIC"
# Robust Linear Model (method = 'rlm'), For regression using package MASS with no tuning parameters 
method <- "rlm"
runtimeLMModel <- train(
    runtime ~ polym(p_ws, p_hh, p_th, p_10h, degree=2, raw=TRUE),
    #    runtime ~ p_ws + p_hh + p_th + p_10h,
    data = ds,
    trControl = data_ctrl,
    method = method,
    na.action = na.pass
)






knots <- quantile(ds$p_ws, p = c(0.25, 0.5, 0.75))
model <- lm(runtime ~ bs(p_ws, knots = knots), data = ds)
ggplot(ds, aes(p_ws, runtime) ) +
  geom_point() +
  stat_smooth(method = lm, formula = y ~ splines::bs(x, df = 3))