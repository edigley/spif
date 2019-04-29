Example from http://uc-r.github.io/mars

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

set.seed(123)
ames_split <- initial_split(AmesHousing::make_ames(), prop = .7, strata = "Sale_Price")
ames_train <- training(ames_split)
ames_test  <- testing(ames_split)





# Fit a basic MARS model
mars1 <- earth(
  Sale_Price ~ .,  
  data = ames_train   
)

# Print model summary
print(mars1)
summary(mars1) %>% .$coefficients %>% head(10)



plot(mars1, which = 1)



# create a tuning grid
hyper_grid <- expand.grid(
  degree = 1:3, 
  nprune = seq(2, 100, length.out = 10) %>% floor()
  )
head(hyper_grid)





# for reproducibiity
set.seed(123)

# cross validated model
tuned_mars <- train(
  x = subset(ames_train, select = -Sale_Price),
  y = ames_train$Sale_Price,
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






install.packages("pls")
install.packages("glmnet")
install.packages("kableExtra")
library("pls")
library("glmnet")
library("kableExtra")

# multiple regression
set.seed(123)
cv_model1 <- train(
  Sale_Price ~ ., 
  data = ames_train, 
  method = "lm",
  metric = "RMSE",
  trControl = trainControl(method = "cv", number = 10),
  preProcess = c("zv", "center", "scale")
  )

# principal component regression
set.seed(123)
cv_model2 <- train(
  Sale_Price ~ ., 
  data = ames_train, 
  method = "pcr",
  trControl = trainControl(method = "cv", number = 10),
  metric = "RMSE",
  preProcess = c("zv", "center", "scale"),
  tuneLength = 20
  )

# partial least squares regression
set.seed(123)
cv_model3 <- train(
  Sale_Price ~ ., 
  data = ames_train, 
  method = "pls",
  trControl = trainControl(method = "cv", number = 10),
  metric = "RMSE",
  preProcess = c("zv", "center", "scale"),
  tuneLength = 20
  )

# regularized regression
set.seed(123)
cv_model4 <- train(
  Sale_Price ~ ., 
  data = ames_train,
  method = "glmnet",
  trControl = trainControl(method = "cv", number = 10),
  metric = "RMSE",
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
#  kableExtra::kable() %>%
#  kableExtra::kable_styling(bootstrap_options = c("striped", "hover"))






# variable importance plots
p1 <- vip(tuned_mars, num_features = 40, bar = FALSE, value = "gcv") + ggtitle("GCV")
p2 <- vip(tuned_mars, num_features = 40, bar = FALSE, value = "rss") + ggtitle("RSS")

gridExtra::grid.arrange(p1, p2, ncol = 2)
coef(tuned_mars$finalModel) %>%
  tidy() %>%
  dplyr::filter(stringr::str_detect(names, "\\*"))

p1 <- partial(tuned_mars, pred.var = "Gr_Liv_Area", grid.resolution = 10) %>% autoplot()
p2 <- partial(tuned_mars, pred.var = "Year_Built", grid.resolution = 10) %>% autoplot()
p3 <- partial(tuned_mars, pred.var = c("Gr_Liv_Area", "Year_Built"), grid.resolution = 10) %>% 
  plotPartial(levelplot = FALSE, zlab = "yhat", drape = TRUE, colorkey = TRUE, screen = list(z = -20, x = -60))

gridExtra::grid.arrange(p1, p2, p3, ncol = 3)
