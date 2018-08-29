# main.R
# 7/17/2017
# package deals

library(devtools)
library(testthat)
library(rstantools)
library(dplyr)

# Adheres to best-practices laid out here:
# https://cran.r-project.org/web/packages/rstantools/vignettes/developer-guidelines.html

# Set up Stan skeleton
# rstan_package_skeleton()

# Package dependencies
use_package("dplyr")
use_package("reshape2")
use_package("ggplot2")
use_package("settings")
use_package("Rcpp")
use_package("methods")
use_package("parallel")
use_package("stats")
use_package("testthat", type = "suggests")
use_package("rlang")

# document
devtools::document()

# tests
devtools::use_testthat()
devtools::use_coverage(type = "codecov")
devtools::test()

# Vignettes
devtools::use_vignette("BAM_Sacramento") # BAM discharge estimation on Po river


# Datasets ----------------------------------------------------------------
# dir.create("data")
use_data(Sacramento, Sacramento_sm, overwrite = TRUE) # See inst/oneoff/datasets.R

# internal, for functions
# use_data(scTable, olsonTbl, tzTable, no3Flow,
#          internal = TRUE, overwrite = TRUE)


# load and install package ------------------------------------------------
devtools::install()


