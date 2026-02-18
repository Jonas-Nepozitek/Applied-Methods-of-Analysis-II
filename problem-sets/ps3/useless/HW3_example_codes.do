****************************************************
* Homework 3: The Effect of Working from Home on Productivity
* Jackson School of Global Affairs
* Ardina Hasanbasri (GLBL 5021)
* Additional reference code and data used:        
* Békés & Kézdi (2021) see more code below         
* https://gabors-data-analysis.com/               
*                                                 
****************************************************

clear all
set more off

* This code has 2 examples: (1) Creating a balance table (2) creating bar graphs

*------------------------------------------------------*
* Load a data that we can play around with. 
*------------------------------------------------------*

use "https://users.nber.org/~rdehejia/data/nsw_dw.dta"

*------------------------------------------------------*
* Label treatment groups 
*------------------------------------------------------*
label define treatlbl 0 "Control" 1 "Treated", replace
label values treat treatlbl

*======================================================*
* 1) Balance table (Table 1 style)
*======================================================*

* There are several new packages that you can use. Here we will use balancetable. 
* Only need to do once. 
* ssc install balancetable

balancetable treat age education black hispanic married nodegree re74 re75 re78 using "BalanceTable.xlsx", replace

* You can open the file now in excel. 

*======================================================*
* 2) Bar graph: Share married by treatment group
*======================================================*

preserve

* Create the share (mean of married) by treatment group
collapse (mean) share_married=married, by(treat)

* Create a percent label for plotting
gen share_pct = 100*share_married
gen share_lab = string(share_pct, "%4.0f") + "%"

* Bar chart with labels
graph bar share_married, over(treat, label(angle(0))) ///
    blabel(bar, format(%4.2f) position(outside)) ///
    ytitle("Share Married") ///
    title("Share of Married Individuals by Treatment Status") ///
    legend(off)

* If you want the label to show as 0–100% style instead of decimals,
* you can plot share_pct instead:
graph bar share_pct, over(treat, label(angle(0))) ///
    blabel(bar, format(%4.0f) position(outside)) ///
    ytitle("Percent Married") ///
    title("Percent Married by Treatment Status") ///
    legend(off)

restore
