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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Setting up library and uploading data                      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

library(tidyverse)
library(estimatr)     
library(modelsummary)
library(xfun)
library(tinytable)
library(mfx)


data <- read_csv('https://osf.io/download/5c3rf/')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Sample Selection and Cleaning                              #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Select variables used for analysis
data <- data %>% 
  dplyr::select(personid:perform11, age, male, second_technical, high_school, tertiary_technical, university,
                prior_experience, tenure, married, children, ageyoungestchild, rental,
                costofcommute, internet, bedroom, basewage, bonus, grosswage, phonecalls1 )

# Modify variable
# Age of youngest child is coded as 0 if the person has no children. 
# We need to fix this. 
data$ageyoungestchild <- ifelse(data$children == 0, NA, data$ageyoungestchild)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Code for homework answers                                  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
