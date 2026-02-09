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
import pyreadstat
from statsmodels.nonparametric.smoothers_lowess import lowess
import statsmodels.formula.api as smf
from typing import List
warnings.filterwarnings("ignore") 

share = pd.read_csv("https://osf.io/download/kbjzp/")

#-----------------------------------------------------------#
# Sample Selection and Creating New Data                    #
# ----------------------------------------------------------#

share = share.query("wave==4 & age>=50 & age<=64")

# Some reminder code to help explore data. 
share["br015"].unique()
share["mar_stat"].value_counts()
share["bmi"].describe()

#-----------------------------------------------------------#
# Code for homework answers                                 #
# ----------------------------------------------------------#
