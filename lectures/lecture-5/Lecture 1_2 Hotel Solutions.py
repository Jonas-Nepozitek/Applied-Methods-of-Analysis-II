"""
Lecture 1.2 Supplemental Code

Jackson School of Global Affairs                 
                                                 
 Created by Ardina Hasanbasri for GLBL 5021      
                                                 
Additional reference code and data used:        
Békés & Kézdi (2021) see more code below         
https://gabors-data-analysis.com/               
                                            

This code focuses on three things: 

1) Basic Regression & Visualization Code

2) Interpreting Binary Variables in Regression

3) Transforming Variables and More Visualization Practice
"""

#-----------------------------------#
# Setting Up                        #
# ----------------------------------#

import warnings
import numpy as np
import pandas as pd
import pyfixest as pf
import seaborn as sns
import matplotlib.pyplot as plt
import pyreadstat
from statsmodels.nonparametric.smoothers_lowess import lowess
import statsmodels.formula.api as smf
from typing import List


warnings.filterwarnings("ignore") 

hotels = pd.read_csv("https://osf.io/download/y6jvb/") # Option 1: Download if link is available. 

#-----------------------------------#
# Cleaning & Sample Selection       #
# ----------------------------------#

hotels = hotels[
    (hotels["accommodation_type"] == "Hotel") &
    (hotels["city_actual"] == "Vienna") &
    (hotels["stars"] >= 3) &
    (hotels["stars"] <= 4) &
    (hotels["price"] <= 600) &
    (hotels["stars"].notnull())
]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Part I Interpreting Binary Variables in Regressions       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# A binary variable is created for you here. 
hotels["star4"] = hotels["stars"] == 4

# Calculating means 
a = hotels["price"].mean()
b = hotels.loc[hotels["star4"] == 1, "price"].mean()
c = hotels.loc[hotels["star4"] == 0, "price"].mean()

# Task 1: Run a basic regression here and show the results. 

reg1 = pf.feols("price ~ star4", data=hotels)
pf.etable([reg1])

# Task 2: Explain how the intercept and the coefficient on star4 
# relate to the means we calculated before?

# c is the intercept, the mean when the binary is 0.  
# You can get the coefficient on star4 by taking the difference of the two group means. 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Part II Basic Visualization & Regression Code #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

plt.scatter(hotels['distance'], hotels['price'])      # Create scatter plot
plt.show()                                            # Display the plot

# To get a smooth line in python, you need to manually create the lowess points. 
lowess_fit = lowess(
    endog=hotels['price'],
    exog=hotels['distance'],
    frac=0.3   # smoothing parameter 
) 

# Plot scatter with lowess line
plt.scatter(hotels['distance'], hotels['price'])      # Create scatter plot
plt.plot(lowess_fit[:, 0], lowess_fit[:, 1], linewidth=2)
plt.show()                                            # Display the plot

# Task 3: Create a scatterplot with a fit line with seaborn (much easier).   

# Using seaborn instead of matplotlib can be easier for linear fit (lowess also works but requires another dependency). 
sns.regplot(x=hotels['distance'], y=hotels['price'])
plt.show()

# Task 4 (optional): In ChatGPT ask the following prompt
# "In the code above, how do I add an vertical and horizontal line 
#  that shows the mean of my x and y using ggplot?" 

sns.regplot(x=hotels['distance'], y=hotels['price'])
plt.axvline(hotels['distance'].mean(), linestyle="--")
plt.axhline(hotels['price'].mean(), linestyle="--")
plt.show()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Part III Transforming Variables & More Visualization Practice #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Run basic model 
model1 = pf.feols("price ~ distance", data=hotels)
pf.etable([model1])

# Create log variables. 
hotels["lnprice"] = np.log(hotels["price"])
hotels["distance2"] = hotels["distance"]  # Create a new variable to keep raw column untouched. 
hotels.loc[hotels["distance2"] < 0.05, "distance2"] = 0.05 # Only change for specific values.  
hotels["lndistance"] = np.log(hotels["distance2"])

# Task 5: Graph one of the new variables that you created (log price vs distance), 
#         are you able to replicate some of the graphs from class?

sns.regplot(x=hotels['lndistance'], y=hotels['lnprice'])
plt.show()

# Replicate the regression table from the slides. 

reg0 = pf.feols("price ~ distance", data=hotels)
reg1 = pf.feols("lnprice ~ distance", data=hotels)
reg2 = pf.feols("price ~ lndistance", data=hotels)
reg3 = pf.feols("lnprice ~ lndistance", data=hotels, vcov="hetero")

pf.etable([reg0,reg1,reg2, reg3])

# Task 6: If time permits, We are going to do a regression with splines.  
#         the code is lm(lnprice ~ lspline(distance, c(...,...)), data=hotels)
#         Fill in the ... with where you think the knots should be. 
#         See if the R-square is much better, even though we do not log distance. 
#         R-squared will be briefly reviewed in Lecture 1.3

# Python unfortunately does not have an easy way to create splines. 
# Because of this we need to create our own function defined as lspline.
# But for now, we will just create the variables manually. 

x = hotels["distance"].to_numpy()

hotels["s1"] = np.minimum(x, 1.0)
hotels["s2"] = np.minimum(np.maximum(x - 1.0, 0.0), 4.0 - 1.0)  
hotels["s3"] = np.maximum(x - 4.0, 0.0)

reg4 = pf.feols("lnprice ~ s1 + s2 + s3", data=hotels)

pf.etable([reg0, reg1, reg2, reg3, reg4])

