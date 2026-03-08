############################################################
# Lecture 2.6 Supplemental Code (R version)
# Jackson School of Global Affairs
# Ardina Hasanbasri (GLBL 5021)
# Reference: Békés & Kézdi (2021) https://gabors-data-analysis.com/
############################################################

# We will do a difference-in-difference exercise examining airline mergers! 
# The data from the textbook has been cleaned for you to save time. 

#--------------------------------------------------#
# Setup & Load Data 
#--------------------------------------------------#

library(tidyverse)
library(haven)
library(zoo)
library(cowplot)
library(fixest)

data_balanced <- read_rds("Lecture_2_6_airline1.rds")

#---------------------------------------
# Step 1) Create the first difference
#---------------------------------------

data_balanced <- data_balanced %>%
  mutate(lnavgp = ifelse(is.infinite(log(avgprice)), NA, log(avgprice))) %>%
  arrange(market, year) %>%
  group_by(market) %>%
  mutate(d_lnavgp = lnavgp - lag(lnavgp)) %>%
  ungroup()

#-------------------------------------------------------
# Step 2) Let's run the simple Diff-in-Diff regression  
#-------------------------------------------------------

did <- feols(d_lnavgp ~ xxx, data = data_balanced)
summary(fd)

#------------------------------------------------
# Step 3) Let's recreate the diff-in-diff table
#------------------------------------------------

data_balanced %>%
  filter(year == xxx & treated==xxx) %>%
  summarise(mean_price = weighted.mean(lnavgp, pass_bef, na.rm = TRUE))

#----------------------------------------------------------------------------------------
# Step 4) Diff-in-Diff (Two-way fixed effect regression with pooled cross-section data) 
#----------------------------------------------------------------------------------------

did2 <- feols(xxx ~ xxx, weights = data_balanced$pass_bef, data = data_balanced , cluster = 'market' )
summary(did2)
summary(did)

#--------------------------------------------------------------------
# Step 5) Let's check the graphs for the parallel trends assumption
#--------------------------------------------------------------------

data_graph <- read_rds("Lecture_2_6_airline2.rds")

color <- c("#d95f02", "#1b9e77", "#7570b3")

ggplot(data_graph, aes(x = date, y = lnavgprice, color = factor(treated))) +
  geom_line(data = filter(data_graph, treated==1), linewidth = 1.3) +
  geom_line(data = filter(data_graph, treated==0), linewidth = 1.3) +
  annotate("text", x = as.yearqtr("2013-1"), y = 5.14, label = "Treated markets", size=3, color = color[1]) + 
  annotate("text", x = as.yearqtr("2013-1"), y = 5.46, label = "Unreated markets", size=3, color = color[2]) +
  geom_vline(xintercept = as.yearqtr("2012-1"), color = color[3], linewidth = 0.9, linetype="longdash")+
  geom_vline(xintercept = as.yearqtr("2015-3"), color = color[3], linewidth = 0.9, linetype="longdash") +
  annotate("text", x = as.yearqtr("2011-1"), y = 5.57, label = "Announcement", size=2.5, color = color[3]) + 
  annotate("text", x = as.yearqtr("2014-3"), y = 5.58, label = "Merger happens", size=2.5, color = color[3]) +
  scale_y_continuous(limits = c(5, 5.6), breaks = seq(5, 5.6, 0.1)) +
  scale_color_manual(values=color[1:2], name="") +
  labs(y = "ln(average price)", x="") +
  scale_x_yearqtr(format = "%YQ%q") +
  theme_minimal() +
  theme(axis.text.x=element_text(size=9)) +
  theme(axis.text.y=element_text(size=9)) +
  theme(axis.title.x=element_text(size=9)) +
  theme(axis.title.y=element_text(size=9)) +
  theme(legend.position="none")

#--------------------------------------------------------------------
# Step 6) Diff-in-Diff with controls 
#--------------------------------------------------------------------
# Let's use the first difference as the y (diff-in-diff in step 2). 
# You can do this also for Step 4 diff-in-diff as well. 

data_balanced <- data_balanced %>%
  arrange(market, year) %>%
  group_by(market) %>%
  mutate(
    lnpass_bef = mean(ifelse(before == 1, log(passengers), NA), na.rm = TRUE), 
    share_bef = mean(ifelse(before == 1, shareAA + shareUS, NA), na.rm = TRUE),
    sharelarge_bef = mean(ifelse(before == 1, sharelargest, NA), na.rm = TRUE)
  ) %>%
  ungroup()

formula3 <- as.formula(d_lnavgp ~ xxx )
fd3 <- feols(formula3, weights = data_balanced$pass_bef, data = data_balanced , cluster = 'market')
summary(fd3)

