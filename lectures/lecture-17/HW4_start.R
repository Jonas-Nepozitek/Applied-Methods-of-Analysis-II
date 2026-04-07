# ==============================================================================

# 3.2 Airbnb Price Prediction — Predictive Analysis Pipeline
# Jackson School of Global Affairs
# Ardina Hasanbasri (GLBL 5021)
# Reference: Békés & Kézdi (2021) https://gabors-data-analysis.com/

# ==============================================================================
# Stages:
#   1. Create holdout and working samples
#   2. Build and Estimate 5 OLS candidate models via 4-fold CV
#   3. Select the best model by CV RMSE, R-squared, and BIC
#   4. Evaluate the final model on the holdout sample
# ==============================================================================

rm(list = ls())

library(tidyverse)
library(rsample)   # commands used: initial_split, vfold_cv, analysis, assessment
library(glmnet)    # LASSO

options(digits = 3)

# Since you learned how to make functions, here are some helper functions. 
mse_lev  <- function(pred, y) mean((pred - y)^2, na.rm = TRUE)
rmse_lev <- function(pred, y) mse_lev(pred, y)^(1/2)


# ==============================================================================
# 0.  Load data
# ==============================================================================

data <- read_csv("airbnb_hackney_workfile_adj_book1.csv") %>%
  mutate_if(is.character, factor)

# Some additional cleaning: 
data <- data %>%
  mutate(
    flag_days_since=ifelse(is.na(n_days_since),1, 0),
    n_days_since =  ifelse(is.na(n_days_since), median(n_days_since, na.rm = T), n_days_since),
    flag_review_scores_rating=ifelse(is.na(n_review_scores_rating),1, 0),
    n_review_scores_rating =  ifelse(is.na(n_review_scores_rating), median(n_review_scores_rating, na.rm = T), n_review_scores_rating),
    flag_reviews_per_month=ifelse(is.na(n_reviews_per_month),1, 0),
    n_reviews_per_month =  ifelse(is.na(n_reviews_per_month), median(n_reviews_per_month, na.rm = T), n_reviews_per_month)
  )

# ==============================================================================
# 1.  List all models we will build in this exercise. 
# ==============================================================================

# Model choices are decided through domain knowledge and exploratory data analysis. 

# --- Predictor groups --------------------------------------------------------
basic_lev  <- c("n_accommodates", "n_beds", "f_property_type", "f_room_type",
                "n_days_since", "flag_days_since")
basic_add  <- c("f_bathroom", "f_cancellation_policy", "f_bed_type")
reviews    <- c("f_number_of_reviews", "n_review_scores_rating",
                "flag_review_scores_rating")
poly_lev   <- c("n_accommodates2", "n_days_since2", "n_days_since3")
amenities  <- grep("^d_.*", names(data), value = TRUE)

X1 <- c("f_room_type*f_property_type", "f_room_type*d_familykidfriendly")
X2 <- c("d_airconditioning*f_property_type", "d_cats*f_property_type",
        "d_dogs*f_property_type")
X3 <- c(paste0("(f_property_type + f_room_type + f_cancellation_policy + f_bed_type) * (",
               paste(amenities, collapse = " + "), ")"))

# --- Model formulas (right-hand side strings) --------------------------------
model1 <- as.formula(paste("price ~ n_accommodates"))
model2 <- as.formula(paste("price ~", paste(basic_lev, collapse = " + ")))
model3 <- as.formula(paste("price ~", paste(c(basic_lev, basic_add, reviews), collapse = " + ")))
model4 <- as.formula(paste("price ~", paste(c(basic_lev, basic_add, reviews, poly_lev), collapse = " + ")))
model5 <- as.formula(paste("price ~", paste(c(basic_lev, basic_add, reviews, poly_lev, X1), collapse = " + ")))
model6 <- as.formula(paste("price ~", paste(c(basic_lev, basic_add, reviews, poly_lev, X1, X2), collapse = " + ")))
model7 <- as.formula(paste("price ~", paste(c(basic_lev, basic_add, reviews, poly_lev, X1, X2, amenities), collapse = " + ")))
model8 <- as.formula(paste("price ~", paste(c(basic_lev, basic_add, reviews, poly_lev, X1, X2, amenities, X3), collapse = " + ")))

model_formulas <- list(
  model1 = model1,
  model2 = model2,
  model3 = model3,
  model4 = model4,
  model5 = model5,
  model6 = model6,
  model7 = model7,
  model8 = model8
  
)