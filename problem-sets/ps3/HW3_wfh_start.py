"""
Homework 2 Who tends to exercise more?
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

# Feel free to add or delete
import os
import sys
import warnings
import numpy as np
import pandas as pd
import pyfixest as pf
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.formula.api as smf
from typing import List
warnings.filterwarnings("ignore") 

data = pd.read_csv("https://osf.io/jvgrf/download")

#-----------------------------------------------------------#
# Sample Selection and Cleaning                             #
# ----------------------------------------------------------#

data["ageyoungestchild"] = np.where(
    data["children"] == 0, None, data["ageyoungestchild"]
)
data["ageyoungestchild"] = pd.to_numeric(data["ageyoungestchild"])
data["ordertaker"] = data["ordertaker"].astype(int)

data = data.drop(columns=["phonecalls0"])

#-----------------------------------------------------------#
# Code for homework answers                                 #
# ----------------------------------------------------------#
