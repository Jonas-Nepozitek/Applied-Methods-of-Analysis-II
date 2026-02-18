#-------------------------------------------------#
#                                                 # 
# Homework 3 The Effect of Working from Home      #
# Jackson School of Global Affairs                # 
#                                                 # 
# Created by Ardina Hasanbasri for GLBL 5021      # 
#                                                 # 
# Additional reference code and data used:        #
# Békés & Kézdi (2021) see more code below        # 
# https://gabors-data-analysis.com/               #
#                                                 #
#-------------------------------------------------#

# The code provides examples for 
# (1) Create a balance table 
# (2) Create bar graphs 


#-----------------------------
# 1) Create a Balance Table 
#-----------------------------

library(modelsummary)
data("lalonde", package = "MatchIt") # Running this code allows us to use data lalonde
# Lalonde is a famous dataset that is used to see whether receiving job training (treatment)
# affects wages or not. 

# You can use the code below to label your treatment variable. Without this, 
# it still works but will say 0 and 1. 
lalonde$treat <- factor(lalonde$treat, levels = c(0,1),
                        labels = c("Control", "Treated"))

# Below is the code to create a balance table. You just need to input the variables 
# you care about and end with ~ treat. Meaning its by treatment group. 
datasummary_balance(
  age + educ + black + hispan + married + nodegree + re74 + re75 ~ treat,
  data = lalonde,
  fmt = 3, 
  stars = TRUE
)

#-----------------------------
# 2) Creating Bar Graphs 
#-----------------------------

# There are different types of bar graphs. 
# Bar graph to graph the means/shares, or a stacked bar graph. 
# Typically you will need to create the numbers first and then you can graph it. 

# Suppose we want a bar graph of the share of people who are married in the treatment 
# and control group. 

# First create the share that you want to graph. 
marriage_summary <- data %>%
  group_by(treatment) %>%
  summarise(share_married = mean(married, na.rm = TRUE))

# Note: you'll notice that this isn't good experiment data since the two groups
#       have very different marriage rates. 

# Then include it ggplot. 
ggplot(marriage_summary,
       aes(x = factor(treatment),
           y = share_married,
           fill = factor(treatment)))+ 
  geom_col(width = 0.6, color = NA)

# Ask ChatGPT to beautify it  
ggplot(marriage_summary,
       aes(x = factor(treatment),
           y = share_married,
           fill = factor(treatment))) +
  geom_col(width = 0.6, color = NA) +
  geom_text(aes(label = scales::percent(share_married, accuracy = 1)),
            vjust = -0.5) +
  scale_fill_manual(values = c("#4C78A8", "#E45756")) +
  labs(x = "Treatment Group (0 = Control, 1 = Treated)",
       y = "Share Married",
       title = "Share of Married Individuals by Treatment Status") +
  theme_minimal() +
  theme(legend.position = "none")