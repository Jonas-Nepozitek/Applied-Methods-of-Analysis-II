############################################################
# Lecture 3.1 Supplemental Code (R version)
# Jackson School of Global Affairs
# Ardina Hasanbasri (GLBL 5021)
# Reference: Békés & Kézdi (2021) https://gabors-data-analysis.com/
############################################################

library(tidyverse)      
library(modelsummary)   
library(fixest)         
library(rsample)        # used for k-fold cross-validation 

data <- read.csv("usedcars_work.csv", stringsAsFactors = FALSE)

# These are 5 models that we want to choose from. 
model1 <- price ~ age + agesq
model2 <- price ~ age + agesq + odometer
model3 <- price ~ age + agesq + odometer + odometersq + LE + cond_excellent + cond_good + dealer
model4 <- price ~ age + agesq + odometer + odometersq + LE + XLE + SE +
  cond_likenew + cond_excellent + cond_good + cylind6 + dealer
model5 <- price ~ age + agesq + agecu +
  odometer + odometersq +
  LE*age + XLE*age + SE*age +
  cond_likenew*age + cond_excellent*age + cond_good*age +
  cylind6*age + odometer*age + dealer*age

#-------------------
# Task 1: Graphing
#-------------------
# The very first model uses age and age-squared as a key model. 
# The last fifth model also interacts age with all car characteristics. 
# For fun, let's create a scatterplot and lowess curve for price of a car and age. 
# Does the pattern justify the importance of age?  

xxx

#-------------------
# Task 2: Comparing Models using Adjusted R-Squared, AIC, BIC, and RMSE. 
#-------------------

 models <- list(
   "Model 1" = model1,
   "Model 2" = model2,
   "Model 3" = model3,
   "Model 4" = model4,
   "Model 5" = model5
 )
 
 regs <- lapply(models, function(m) feols(m, data = data, vcov = "hetero"))
 
 modelsummary(
   regs,
   stars = TRUE,
   gof_map = c("aic", "bic", "rmse", "r.squared", "adj.r.squared", "nobs")
 )
 
#-------------------
# Task 3: Comparing Models using Cross-validation (CV) and MSE.  
#-------------------
 
# Make comments on what each of the lines mean. 
 
set.seed(13505)
 
# Number of folds
k_folds <- 4
 
# Create 4-fold cross-validation splits
folds <- vfold_cv(data, v = k_folds)
 
run_cv <- function(formula, folds) {
   sapply(folds$splits, function(split) {
     train_data <- analysis(split)    
     test_data  <- assessment(split)  
     fit        <- lm(formula, data = train_data)
     preds      <- predict(fit, newdata = test_data)
     actual     <- test_data$price
     sqrt(mean((preds - actual)^2, na.rm = TRUE))
   })
 }
 
# Run CV for each model
cv1_rmse <- run_cv(model1, folds)
cv2_rmse <- run_cv(model2, folds)
cv3_rmse <- run_cv(model3, folds)
cv4_rmse <- run_cv(model4, folds)
cv5_rmse <- run_cv(model5, folds)
 
# Build summary table: RMSE per fold + average across folds
cv_mat <- data.frame(
   Resample  = c(paste0("Fold", 1:k_folds), "Average"),
   Model1    = c(cv1_rmse, mean(cv1_rmse)),
   Model2    = c(cv2_rmse, mean(cv2_rmse)),
   Model3    = c(cv3_rmse, mean(cv3_rmse)),
   Model4    = c(cv4_rmse, mean(cv4_rmse)),
   Model5    = c(cv5_rmse, mean(cv5_rmse)), 
   stringsAsFactors = FALSE
 )
 
print(cv_mat)
 
#-------------------
# Task 4: Get Prediction Point and Interval  
#-------------------

# Suppose below is our live data that we want to use. 

# --- Define the new car -------------------------------------------------------
# A 10-year-old LE trim with excellent condition, 12k miles, no dealer, 4-cyl.
new_car <- tibble(
  age          = 10,
  agesq        = 10^2,
  odometer     = 12,
  odometersq   = 12^2,
  SE           = 0,
  XLE          = 0,
  LE           = 1,
  cond_likenew = 0,
  cond_excellent = 1,
  cond_good    = 0,
  dealer       = 0,
  cylind6      = 0,
  price        = NA   # unknown — this is what we are predicting
)

# Choose the model that we want to use for prediction. 
model_chosen <- feols(model3, data = data, vcov = "hetero")
 
# Can calculate prediction point interval using predit()! 
pred_new95 <- predict(model_chosen, newdata = new_car, se.fit = TRUE,
                       interval = "prediction", level = 0.95)

# What do the numbers from pred_new95 mean? Now do one for 85% interval?