###############################################################################
# Supplementary Code for PNAS Paper                                           #
# Title: Global Subnational Estimates of Migration of Scientists              #
#        Reveal Large Disparities in Internal and International Flows         #
#                                                                             #
# Author:  Maciej J. Danko                                                    #
# Affiliation: Max Planck Institute for Demographic Research                  #
# Contact: danko@demogr.mpg.de | maciej.danko@gmail.com                       #
# Date: 2025-01-30                                                            #
###############################################################################

rm(list=ls())
graphics.off()
closeAllConnections()
Sys.setenv(LANG = "en")
gc()

required_packages <- c("brms", "data.table", "deming", "DescTools", "dplyr", "Kendall", 
              "lava", "magicaxis", "mgcv", "openxlsx", "parallel", "purrr", 
              "splines", "stats")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}
z<-lapply(required_packages, require, character.only = TRUE); rm(z)


options(bitmapType="cairo")
ncores <- round(parallel::detectCores()/2-1)
set.seed(123)

Recalcualte_all <- FALSE
source('prepare_data.R')
source('calc_plot_gini.R')
source('fit_plot_GAMM.R')

source('fit_Kendall.R')
source('fit_slopes.R')
source('load_World_Bank_data.R')

Recalcualte_all <- FALSE
source('fit_internal_international_slopes.R')
source('plotting_functions.R')
source('plot_slopes.R')
source('plot_Kendall.R')
source('make_tables.R')

