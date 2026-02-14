"""
Lecture 1.7 Supplemental Code

Jackson School of Global Affairs                 
                                                 
 Created by Ardina Hasanbasri for GLBL 5021      
                                                 
Additional reference code and data used:        
Békés & Kézdi (2021) see more code below         
https://gabors-data-analysis.com/               
                                            
"""

# Part I explains how the data was cleaned, but can be skipped. 
# The main data exercise is in part II, running LPM, logit, and probit models. 

#------------------------------------------------#
# Setting Up and Load Data                       #
# -----------------------------------------------#

import os
import sys
import warnings
import numpy as np
import pandas as pd
import pyfixest as pf
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.api as sm
from sklearn.metrics import mean_squared_error, r2_score, log_loss
import pyreadstat
from statsmodels.nonparametric.smoothers_lowess import lowess
import statsmodels.formula.api as smf
from typing import List
warnings.filterwarnings("ignore") 

share = pd.read_csv("https://osf.io/download/kbjzp/")

#------------------------------------------------#
# Part I Data Cleaning                           #
# -----------------------------------------------#

share["healthy"] = 0
share.loc[(share["sphus"] == 1) | (share["sphus"] == 2), "healthy"] = 1
share.loc[~((share["sphus"] > 0) & (share["sphus"] <= 5)), "healthy"] = np.nan

share["baseline"] = 0
share.loc[share["wave"] == 4, "baseline"] = 1
share["endline"] = 0
share.loc[share["wave"] == 6, "endline"] = 1

share["temp"] = np.where(
    share["endline"] == 1, np.where(share["healthy"] == 1, 1, 0), np.nan
)

share["stayshealthy"] = share.groupby("mergeid")["temp"].transform(np.nanmax)

share = share.drop("temp", axis=1)

# keep if endline health outcome non-missing
share = share.loc[lambda x: (x["stayshealthy"] == 1) | (x["stayshealthy"] == 0)]

# keep baseline observations (endline outcome already defined for them)
share = share.loc[lambda x: x["baseline"] == 1]

# keep age 50-60 at baseline
share = share.loc[lambda x: (x["age"] >= 50) & (x["age"] <= 60)]

# keep healthy individuals at baseline
share = share.loc[lambda x: x["healthy"] == 1]

# keep those with non-missing observations for smoking at baseline
# and re-define smoking to be 0-1
share.loc[lambda x: x["smoking"] == 5, "smoking"] = 0
share = share.loc[lambda x: (x["smoking"] == 0) | (x["smoking"] == 1)]

share.loc[lambda x: x["ever_smoked"] == 5, "ever_smoked"] = 0
share = share.loc[lambda x: (x["ever_smoked"] == 0) | (x["ever_smoked"] == 1)]

share["exerc"] = np.where(
    share["br015"] == 1,
    1,
    np.where((share["br015"] > 0) & (share["br015"] != 1), 0, np.nan),
)

share["bmi"] = np.where(share["bmi"] < 0, np.nan, share["bmi"])

share["bmi"].describe().round(2)

share = share.rename(columns={"income_pct_w4": "income10"})

share["married"] = np.where((share["mar_stat"] == 1) | (share["mar_stat"] == 2), 1, 0)

share["eduyears"] = np.where(share["eduyears_mod"] < 0, np.nan, share["eduyears_mod"])

share["eduyears"].describe().round(2)

share = share.drop("eduyears_mod", axis=1)

share = share.loc[
    lambda x: (x["bmi"].notnull()) & (x["eduyears"].notnull()) & (x["exerc"].notnull())
]

#------------------------------------------------#
# Part II LPM, Logit, and Probit                 #
# -----------------------------------------------#

# Create splines 
x = share["eduyears"].to_numpy()

share["edu_years1"] = np.minimum(x, 8.0)
share["edu_years2"] = np.minimum(np.maximum(x - 8.0, 0.0), 18.0 - 8.0)  
share["edu_years3"] = np.maximum(x - 18.0, 0.0)

x = share["bmi"].to_numpy()
share["bmi1"] = np.minimum(x, 35)
share["bmi2"] = np.minimum(np.maximum(x - 35.0, 0.0), 35.0) 

# Create a model formula so you do not need to always type it out. 
model_formula = "stayshealthy ~ smoking + ever_smoked + female + age + edu_years1 + edu_years2 + edu_years3 + income10 + bmi1 +bmi2 + exerc +  C(country)"

# We will use smf since it is easier to get logit and probit models this way
# And easier to combine them. 

lpm   = smf.ols(model_formula, data=share).fit(cov_type="HC1")
logit = smf.logit(model_formula, data=share).fit(cov_type="HC1")
probit= smf.probit(model_formula, data=share).fit(cov_type="HC1")

from statsmodels.iolib.summary2 import summary_col

results = [lpm, logit, probit]  # list of fitted results
table = summary_col(
    results,
    stars=True,
    model_names=["(1)", "(2)", "(3)"],
    info_dict={"N": lambda x: f"{int(x.nobs)}"},
)
table

# From logit results created above, get the marginal effects
logit_marg = logit.get_margeff(at="overall") 
probit_marg = probit.get_margeff(at="overall") 

# We can manually check since making it pretty will take some more work
logit_marg.summary()
probit_marg.summary()

#-------------------------------------------
# PART III Goodness to Fit
#-------------------------------------------

share["pred_lpm"]    = lpm.predict(share)
share["pred_logit"]  = logit.predict(share)
share["pred_probit"] = probit.predict(share)

preds = {
    "LPM": share["pred_lpm"].astype(float),
    "Logit": share["pred_logit"].astype(float),
    "Probit": share["pred_probit"].astype(float),
}

# clip to avoid log_loss issues (and to make LPM usable as probs)
eps = 1e-15
preds_clip = {k: v.clip(eps, 1 - eps) for k, v in preds.items()}
y = share["stayshealthy"].astype(float)

metrics = pd.DataFrame(
    {
        "R-squared": {
            "LPM": float(lpm.rsquared),  
            "Logit": r2_score(y, preds["Logit"]),
            "Probit": r2_score(y, preds["Probit"]),
        },
        "Brier-score": {k: mean_squared_error(y, v) for k, v in preds.items()},
        "Pseudo R-squared": {
            "LPM": np.nan,
            "Logit": float(logit.prsquared),   
            "Probit": float(probit.prsquared),
        },
        "Log-loss": {k: log_loss(y, v) for k, v in preds_clip.items()},
    }
).T.round(3)

metrics

#-------------------------------------------
# PART IV Comparing means and medians of the predicted values
#-------------------------------------------

# Compare means and medians of predicted values
share.groupby("stayshealthy")[
    [ "pred_lpm", "pred_logit", "pred_probit"]
].mean().round(3)

share.groupby("stayshealthy")[
    ["pred_lpm", "pred_logit", "pred_probit"]
].median().round(3)
