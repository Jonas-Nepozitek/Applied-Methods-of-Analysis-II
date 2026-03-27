############################################################
# Lecture 3.1 Supplemental Code (R version)
# Jackson School of Global Affairs
# Ardina Hasanbasri (GLBL 5021)
# Reference: Békés & Kézdi (2021) https://gabors-data-analysis.com/
############################################################

library(tidyverse)      

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

# Step 1: split data once into train and test
set.seed(13505)
train_idx  <- sample(1:nrow(data), size = 0.8 * nrow(data))
train_data <- data[train_idx, ]
test_data  <- data[-train_idx, ]

# Step 2: fit all models on training data
models <- list(model1, model2, model3, model4, model5)

summary <- data.frame(
  model        = 1:5,
  insample_rmse = sapply(models, function(f) {
    fit <- lm(f, data = train_data)
    sqrt(mean(residuals(fit)^2))
  }),
  test_rmse = sapply(models, function(f) {
    fit   <- lm(f, data = train_data)
    preds <- predict(fit, newdata = test_data)
    sqrt(mean((test_data$price - preds)^2, na.rm = TRUE))
  })
)

# Step 3: plot
ggplot(summary, aes(x = model)) +
  geom_line(aes(y = insample_rmse, color = "In-sample RMSE"), linewidth = 1) +
  geom_point(aes(y = insample_rmse, color = "In-sample RMSE"), size = 3) +
  geom_line(aes(y = test_rmse, color = "Test RMSE"), linewidth = 1) +
  geom_point(aes(y = test_rmse, color = "Test RMSE"), size = 3) +
  scale_x_continuous(breaks = 1:5, labels = paste("Model", 1:5)) +
  scale_color_manual(values = c("In-sample RMSE" = "steelblue", "Test RMSE" = "tomato")) +
  labs(title = "Bias-Variance Trade-off", x = "Model Complexity", y = "RMSE", color = NULL) +
  theme_minimal()


# Another way to do this. Calculating the bias and variance of each model.  
# The more complex the model, the more likely you will be able to get close to a particular point (reduce error average). 
# But this can come with a trade-off that the variance of the prediction is much larger. 

bv_summary <- data.frame(
  model    = 1:5,
  bias     = sapply(models, function(f) {
    fit   <- lm(f, data = train_data)
    preds <- predict(fit, newdata = test_data)
    mean(preds - test_data$price, na.rm = TRUE)   # avg prediction error
  }),
  variance = sapply(models, function(f) {
    fit   <- lm(f, data = train_data)
    preds <- predict(fit, newdata = test_data)
    var(preds - test_data$price, na.rm = TRUE)    # spread of prediction errors
  }),
  test_rmse = sapply(models, function(f) {
    fit   <- lm(f, data = train_data)
    preds <- predict(fit, newdata = test_data)
    sqrt(mean((test_data$price - preds)^2, na.rm = TRUE))
  })
)

print(bv_summary)