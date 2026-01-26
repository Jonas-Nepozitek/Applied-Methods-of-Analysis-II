"""
Homework 1 Gender Wage Gap
Jackson School of Global Affairs                 
                                                 
 Created by Ardina Hasanbasri for GLBL 5021      
                                                 
Additional reference code and data used:        
Békés & Kézdi (2021) see more code below         
https://gabors-data-analysis.com/               
                                            
"""

# Note: Feel free to move this code to jupyter notebook if you prefer. 

#-----------------------------------#
# SETTING UP YOUR WORKSPACE #
# ----------------------------------#

# These imports are similar to lecture 1.2 code (feel free to add or delete)
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

cps= pd.read_csv("https://osf.io/download/4ay9x/")

#-----------------------------------------------------------#
# Sample Selection and Creating New Data                    #
# ----------------------------------------------------------#

cps = cps.query("uhours>=20 & earnwke>0 & age>=24 & age<=64")

# Create variables 
cps["female"] = (cps.sex == 2).astype(int)
cps["w"] = cps["earnwke"] / cps["uhours"]
cps["lnw"] = np.log(cps["w"])

# Add demographic variables 
cps["white"] = (cps["race"] == 1).astype(int)
cps["afram"] = (cps["race"] == 2).astype(int)
cps["asian"] = (cps["race"] == 4).astype(int)
cps["hisp"] = (cps["ethnic"].notna()).astype(int)
cps["othernonw"] = (
    (cps["white"] == 0) & (cps["afram"] == 0) & (cps["asian"] == 0) & (cps["hisp"] == 0)
).astype(int)
cps["nonUSborn"] = (
    (cps["prcitshp"] == "Foreign Born, US Cit By Naturalization")
    | (cps["prcitshp"] == "Foreign Born, Not a US Citizen")
).astype(int)

cps["married"] = ((cps["marital"] == 1) | (cps["marital"] == 2)).astype(int)
cps["divorced"] = ((cps["marital"] == 3) & (cps["marital"] == 5)).astype(int)
cps["wirowed"] = (cps["marital"] == 4).astype(int)
cps["nevermar"] = (cps["marital"] == 7).astype(int)

cps["child0"] = (cps["chldpres"] == 0).astype(int)
cps["child1"] = (cps["chldpres"] == 1).astype(int)
cps["child2"] = (cps["chldpres"] == 2).astype(int)
cps["child3"] = (cps["chldpres"] == 3).astype(int)
cps["child4pl"] = (cps["chldpres"] >= 4).astype(int)

# Now let's select an industry to work with. 
# The code below shows the industry codes and their counts for first 25 rows. 
cps["ind02"].value_counts(dropna=False).to_frame()[1:25]
cps = cps.query('ind02=="Banking and related activities (521, 52211,52219)"')

#-----------------------------------------------------------#
# Code for homework answers                                 #
# ----------------------------------------------------------#
