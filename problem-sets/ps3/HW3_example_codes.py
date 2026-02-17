# -------------------------------------------------#
#                                                  #
# Homework 3 The Effect of Working from Home       #
# Jackson School of Global Affairs                 #
#                                                  #
# Created by Ardina Hasanbasri for GLBL 5021       #
#                                                  #
# Python translation of the R example              #
# (1) Balance table                                #
# (2) Bar graphs                                   #
# -------------------------------------------------#

# This code provides an example for (1) creating balance tables 
# (2) creating bar graphs

import numpy as np
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt

# -----------------------------
# 0) Load data (Lalonde)
# -----------------------------
# We will use data from lalonde. You will need to install it from causaldata

url = "https://users.nber.org/~rdehejia/data/nsw_dw.dta"
data = pd.read_stata(url)
# This is a famous data that is used to see the effect of job training (treatment). People call it lalonde data. 

# Label the treatment -> "Control"/"Treated"
data["treat_label"] = np.where(data["treat"] == 1, "Treated", "Control")

# -----------------------------
# 1) Create a Balance Table
# -----------------------------

vars_to_balance = ["age", "education", "black", "hispanic", "married", "nodegree", "re74", "re75"]

def star_from_p(p):
    if p < 0.01:
        return "***"
    if p < 0.05:
        return "**"
    if p < 0.10:
        return "*"
    return ""

# Here, I create my own command to create a balance table. 
# The function accepts the data, column names, variables, and number of decimals. 
def balance_table(df, group_col, variables, decimals=3):
    rows = []

    # split groups
    g0 = df[df[group_col] == "Control"]
    g1 = df[df[group_col] == "Treated"]

    for v in variables:
        x0 = pd.to_numeric(g0[v], errors="coerce").dropna()
        x1 = pd.to_numeric(g1[v], errors="coerce").dropna()

        mean0, mean1 = x0.mean(), x1.mean()
        sd0, sd1 = x0.std(ddof=1), x1.std(ddof=1)
        n0, n1 = x0.shape[0], x1.shape[0]

        # Welch's t-test (robust to unequal variances)
        tstat, pval = stats.ttest_ind(x1, x0, equal_var=False, nan_policy="omit")

        diff = mean1 - mean0
        stars = star_from_p(pval)

        rows.append({
            "Variable": v,
            "Control mean (sd)": f"{mean0:.{decimals}f} ({sd0:.{decimals}f})",
            "Treated mean (sd)": f"{mean1:.{decimals}f} ({sd1:.{decimals}f})",
            "Diff (T-C)": f"{diff:.{decimals}f}{stars}",
            "p-value": round(pval, decimals)
        })

    out = pd.DataFrame(rows)
    return out

# Now I can use my function and input the data in. 
bt = balance_table(data, "treat_label", vars_to_balance, decimals=3)

# Print nicely (console)
print("\nBALANCE TABLE (Control vs Treated)")
print(bt.to_string(index=False))


# -----------------------------
# 2) Creating Bar Graphs
# -----------------------------
# Let's try to get the share of married individuals by treatment group

# First, we can create the numbers that we want to graph. 
# If needed, you can label the group. 
marriage_summary = (
    data.groupby("treat_label", as_index=False)["married"]
        .mean()
        .rename(columns={"married": "share_married"})
)

# Ensure order Control then Treated
order = ["Control", "Treated"]
marriage_summary["treat_label"] = pd.Categorical(marriage_summary["treat_label"], categories=order, ordered=True)
marriage_summary = marriage_summary.sort_values("treat_label")

# Plot
colors = {"Control": "#4C78A8", "Treated": "#E45756"}

fig, ax = plt.subplots()

bars = ax.bar(
    marriage_summary["treat_label"].astype(str),
    marriage_summary["share_married"],
    color=[colors[g] for g in marriage_summary["treat_label"].astype(str)]
)

# If you want to get fancy, sdd labels above bars (percent)
for b, val in zip(bars, marriage_summary["share_married"]):
    ax.text(
        b.get_x() + b.get_width() / 2,
        val + 0.01,
        f"{val:.0%}",
        ha="center",
        va="bottom"
    )

ax.set_xlabel("Treatment Group (0 = Control, 1 = Treated)")
ax.set_ylabel("Share Married")
ax.set_title("Share of Married Individuals by Treatment Status")

# Make it look clean (similar to theme_minimal)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

plt.ylim(0, max(marriage_summary["share_married"]) + 0.10)
plt.show()
