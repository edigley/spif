install.packages("rsample")
install.packages("earth")
#install.packages("vip")
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
# Create training (70%) and test (30%) sets for the AmesHousing::make_ames() data.
# Use set.seed for reproducibility
install.packages("pls")
install.packages("glmnet")
install.packages("kableExtra")
library("pls")
library("glmnet")
library("kableExtra")


set.seed(123)



head(ds)

set.seed(123)
print(params)
ds <- subset(ds, select=c(params, "runtime"))
head(ds)


ames_split <- initial_split(ds, prop = .7, strata = "runtime")
ames_train <- training(ames_split)
ames_test  <- testing(ames_split)
mars1 <- earth(
  runtime ~ .,
  data = ames_train
)
print(mars1)
summary(mars1) %>% .$coefficients %>% head(10)

plot(mars1, which = 1)

mars2 <- earth(
  runtime ~ .,  
  data = ames_train,
  degree = 2
)
summary(mars2) %>% .$coefficients %>% head(10)

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
  x = subset(ames_train, select = -runtime),
  y = ames_train$runtime,
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
  data = ames_train, 
  method = "lm",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  preProcess = c("zv", "center", "scale")
)

# principal component regression
set.seed(123)
cv_model2 <- train(
  runtime ~ ., 
  data = ames_train, 
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
  data = ames_train, 
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
  data = ames_train,
  method = "glmnet",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  preProcess = c("zv", "center", "scale"),
  tuneLength = 10
)

# extract out of sample performance measures
summary(resamples(list(
  Multiple_regression = cv_model1, 
  PCR = cv_model2, 
  PLS = cv_model3,
  Elastic_net = cv_model4,
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

gridExtra::grid.arrange(p1, p2, p3, ncol = 2)

partial(tuned_mars, pred.var = c("p_ws", "p_hh"), grid.resolution = 25) %>% 
  plotPartial(levelplot = FALSE, zlab = "runtime_hat", drape = TRUE, colorkey = TRUE, screen = list(z = 100, x = -60))