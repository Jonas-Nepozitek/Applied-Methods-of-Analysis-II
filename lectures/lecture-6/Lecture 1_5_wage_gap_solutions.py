"""
Lecture 1.5 Case Study Multivariate Regression

Jackson School of Global Affairs                 
                                                 
 Created by Ardina Hasanbasri for GLBL 5021      
                                                 
Additional reference code and data used:        
Békés & Kézdi (2021) see more code below         
https://gabors-data-analysis.com/               
                                            
"""

#-----------------------------------#
# Setting Up                        #
# ----------------------------------#

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


# --------------------------------------------------#
# Load data (local .dta)
# --------------------------------------------------#

wage_data, meta = pyreadstat.read_dta("L15_wage_postgrad_clean.dta ")


# --------------------------------------------------#
# Exercise 1
# --------------------------------------------------#

reg1 = pf.feols("lnw ~ female", wage_data ,vcov="HC1")
reg2 = pf.feols("lnw ~ female + age", wage_data ,vcov="HC1")
reg3 = pf.feols("lnw ~ female + age + agesq", wage_data ,vcov="HC1")
reg4 = pf.feols("lnw ~ female + age + agesq + agecu + agequ", wage_data ,vcov="HC1")


pf.etable([reg1, reg2, reg3, reg4])

# --------------------------------------------------#
# Exercise 2
# --------------------------------------------------#

reg5 = pf.feols("lnw ~ female + edProf + edPhd", wage_data, vcov="HC1")
reg6 = pf.feols("lnw ~ female + edProf + edMA", wage_data, vcov="HC1")
reg7 = pf.feols("lnw ~ female + edMA + edPhd", wage_data, vcov="HC1")

pf.etable([reg5, reg6, reg7])

# --------------------------------------------------#
# Exercise 3 (Interactions)
# --------------------------------------------------#

wage_data = wage_data.assign(
    fXedMA=wage_data["edMA"] * wage_data["female"],
    fXedPhd=wage_data["edPhd"] * wage_data["female"],
    fXedProf=wage_data["edProf"] * wage_data["female"],
)

reg8 = pf.feols("lnw ~ female + age + edProf + edPhd + fXedPhd + fXedProf", wage_data, vcov="HC1")

pf.etable([reg1, reg3, reg8])

# --------------------------------------------------#
# Exercise 4 (Bonus): interactions with age polynomials
# --------------------------------------------------#

wage_data = wage_data.assign(
    fXagesq=wage_data["female"] * wage_data["agesq"],
    fXagecu=wage_data["female"] * wage_data["agecu"],
    fXagequ=wage_data["female"] * wage_data["agequ"],
)

reg_bonus = pf.feols("lnw ~ age + agesq + agecu + agequ + female + fXagesq + fXagecu + fXagequ", wage_data, vcov="HC1")

data_m = wage_data.query("female==0")
pred = reg_bonus.predict(data_m,interval="prediction")[["fit","se_fit"]]

data_m = data_m.reset_index(drop=True).join(pred)

data_m["CIup"] = data_m["fit"] + 1.96 * data_m["se_fit"]
data_m["CIlo"] = data_m["fit"] - 1.96 * data_m["se_fit"]


data_f = wage_data.query("female==1")
pred = reg_bonus.predict(data_f,interval="prediction")[["fit","se_fit"]]

data_f = data_f.reset_index(drop=True).join(pred)

data_f["CIup"] = data_f["fit"] + 1.96 * data_f["se_fit"]
data_f["CIlo"] = data_f["fit"] - 1.96 * data_f["se_fit"]

col_m = "maroon"
col_f = "navy"

sns.lineplot(data=data_m,x="age",y="fit",linewidth=1,estimator=None,ci=False)
sns.lineplot(data=data_m,x="age",y="CIup",linewidth=1,estimator=None,ci=False,color = col_m,linestyle = "dashed")
sns.lineplot(data=data_m,x="age",y="CIlo",linewidth=1,estimator=None,ci=False,color = col_m,linestyle = "dashed")

sns.lineplot(data=data_f,x="age",y="fit",linewidth=1,estimator=None,ci=False,color = col_f)
sns.lineplot(data=data_f,x="age",y="CIup",linewidth=1,estimator=None,ci=False,color = col_f,linestyle = "dashed")
sns.lineplot(data=data_f,x="age",y="CIlo",linewidth=1,estimator=None,ci=False,color = col_f,linestyle = "dashed")

plt.xlabel("Age (years)", fontsize=12)
plt.ylabel("ln(earnings per hour, US dollars)", fontsize=12)
plt.xlim(24,66)
plt.xticks(ticks=np.arange(25, 66, 5))
plt.ylim(2.7,3.82)
plt.yticks(ticks=np.arange(2.8, 3.9, 0.1))

plt.show()

# --------------------------------------------------#
# Replicate "final table from slides"
# --------------------------------------------------#

data40_60 = wage_data.loc[(wage_data["age"] >= 40) & (wage_data["age"] <= 60)].copy()

FAMILY = ["married", "divorced", "wirowed", "child1", "child2", "child3", "child4pl", "C(stfips)"]
WORK = ["hours", "fedgov", "stagov", "locgov", "nonprof", "union", "C(ind2dig)", "C(occ2dig)"]
DEMOG = ["age", "afram", "hisp", "asian", "othernonw", "nonUSborn", "edProf", "edPhd"]

f1 = "lnw ~ female"
f2 = "lnw ~ female + " + " + ".join(DEMOG)
f3 = "lnw ~ female + " + " + ".join(DEMOG + FAMILY + WORK)
f4 = "lnw ~ female + " + " + ".join(DEMOG + FAMILY + WORK + ["agesq", "agecu", "agequ", "hourssq", "hourscu", "hoursqu"])

reg1_slide = pf.feols(f1, data40_60)
reg2_slide = pf.feols(f2, data40_60)
reg3_slide = pf.feols(f3, data40_60)
reg4_slide = pf.feols(f4, data40_60)

pf.etable([reg1_slide, reg2_slide, reg3_slide, reg4_slide])

pf.etable([reg1_slide, reg2_slide, reg3_slide, reg4_slide], keep=["female"])