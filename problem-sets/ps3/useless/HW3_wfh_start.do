****************************************************
* Homework 3: The Effect of Working from Home on Productivity
* Jackson School of Global Affairs
* Ardina Hasanbasri (GLBL 5021)
* Additional reference code and data used:        
* Békés & Kézdi (2021) see more code below         
* https://gabors-data-analysis.com/               
*                                                 
****************************************************

*--------------------------------------------------*
* Load data from OSF 
*--------------------------------------------------*

copy "https://osf.io/download/jrydb/" "workfile.dta"
use "workfile.dta", clear
erase "workfile.dta"

*--------------------------------------------------*
* Sample Selection 
*--------------------------------------------------*

order personid treatment ordertaker type quitjob phonecalls0 phonecalls1 ///
  perform10 perform11 age male second_techn high_school tertiary_tec university ///
  prior_experi tenure married children ageyoungestc rental costofcommut ///
  bedroom internet basewage bonus grosswage 

drop phonecalls0

replace ageyoungest = . if children==0
* These were coded as 0 but should be missing if they have no kids. 

*--------------------------------------------------*
* Code for homework answers
*--------------------------------------------------*
