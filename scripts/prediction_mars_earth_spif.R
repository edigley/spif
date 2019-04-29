install.packages("rsample")
install.packages("earth")
devtools::install_github("koalaverse/vip")
install.packages("pdp")
install.packages("AmesHousing")
library(rsample)   # data splitting 
library(ggplot2)   # plotting
library(earth)     # fit MARS models
library(caret)     # automating the tuning process
library(vip)       # variable importance
library(pdp)       # variable relationships
library("AmesHousing")
install.packages("pls")
install.packages("glmnet")
install.packages("kableExtra")
library("pls")
library("glmnet")
library("kableExtra")

set.seed(1984)

# loads individuals run results data set
ds <- read.table('https://raw.githubusercontent.com/edigley/spif/master/results/farsite_individuals_runtime_jonquera.txt', header=T)
ds <- subset(ds, select=c("individual", paste("p", 0:9, sep=""), "runtime", "maxRSS"))

params <- c("p_1h", "p_10h", "p_100h", "p_herb", "p_1000h", "p_ws", "p_wd", "p_th", "p_hh", "p_adj")
colnames(ds) <- c("id", params, "runtime", "maxRSS")

# selects only attributes used in MARS model
ds <- subset(ds, select=c(params, "runtime"))
head(ds)

ds_split <- initial_split(ds, prop = .7, strata = "runtime")
ds_train <- training(ds_split)
ds_test  <- testing(ds_split)
mars1 <- earth(
  runtime ~ .,
  data = ds_train
)
print(mars1)
summary(mars1) %>% .$coefficients %>% head(10)
plot(mars1, which = 1)

mars2 <- earth(
  runtime ~ .,  
  data = ds_train,
  degree = 2
)
print(mars2)
summary(mars2) %>% .$coefficients %>% head(10)
plot(mars2, which = 1)

hyper_grid <- expand.grid(
  degree = 1:3, 
  nprune = seq(2, 100, length.out = 10) %>% floor()
)

head(hyper_grid)
summary(hyper_grid)

# for reproducibiity
set.seed(123)

# cross validated model
tuned_mars <- train(
  x = subset(ds_train, select = -runtime),
  y = ds_train$runtime,
  method = "earth",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  tuneGrid = hyper_grid
)

# best model
tuned_mars$bestTune
##    nprune degree
## 14     34      2

# plot results
ggplot(tuned_mars)

# multiple regression
set.seed(123)
cv_model1 <- train(
  runtime ~ ., 
  data = ds_train, 
  method = "lm",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  preProcess = c("zv", "center", "scale")
)

# principal component regression
set.seed(123)
cv_model2 <- train(
  runtime ~ ., 
  data = ds_train, 
  method = "pcr",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  preProcess = c("zv", "center", "scale"),
  tuneLength = 20
)

# partial least squares regression
set.seed(123)
cv_model3 <- train(
  runtime ~ ., 
  data = ds_train, 
  method = "pls",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  preProcess = c("zv", "center", "scale"),
  tuneLength = 20
)

# regularized regression
set.seed(123)
cv_model4 <- train(
  runtime ~ ., 
  data = ds_train,
  method = "glmnet",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  preProcess = c("zv", "center", "scale"),
  tuneLength = 10
)

# extract out of sample performance measures
summary(resamples(list(
  Multiple_Regression = cv_model1, 
  PCR = cv_model2, 
  PLS = cv_model3,
  Elastic_Net = cv_model4,
  MARS = tuned_mars
)))$statistics$RMSE # %>%
#   kableExtra::kable() %>%
#   kableExtra::kable_styling(bootstrap_options = c("striped", "hover"))

p1 <- vip(tuned_mars, num_features = 10, bar = FALSE, value = "gcv") + ggtitle("GCV")
p2 <- vip(tuned_mars, num_features = 10, bar = FALSE, value = "rss") + ggtitle("RSS")

gridExtra::grid.arrange(p1, p2, ncol = 2)

coef(tuned_mars$finalModel) %>%
  tidy() %>%
  dplyr::filter(stringr::str_detect(names, "\\*"))

p1 <- partial(tuned_mars, pred.var = "p_ws", grid.resolution = 10) %>% autoplot()
p2 <- partial(tuned_mars, pred.var = "p_hh", grid.resolution = 10) %>% autoplot()
p3 <- partial(tuned_mars, pred.var = c("p_ws", "p_hh"), grid.resolution = 25) %>% 
  plotPartial(levelplot = FALSE, zlab = "runtime_hat", drape = TRUE, colorkey = TRUE, screen = list(z = -20, x = -60))
#plot.engine = "ggplot2"
gridExtra::grid.arrange(p1, p2, p3, ncol = 2)

partial(tuned_mars, pred.var = c("p_ws", "p_hh"), grid.resolution = 25) %>% 
  plotPartial(levelplot = FALSE, zlab = "runtime_hat", drape = TRUE, colorkey = TRUE, screen = list(z = 100, x = -60))
