# main.R
# 7/17/2017
# package deals

library(devtools)
library(testthat)
library(rstantools)

# Adheres to best-practices laid out here:
# https://cran.r-project.org/web/packages/rstantools/vignettes/developer-guidelines.html

# Set up Stan skeleton
# rstan_package_skeleton()

# Set up todoList
library(todoList)
use_todo()

# Package dependencies
# use_package("tidyr")
use_package("reshape2")

# document
devtools::document()

# test
# devtools::use_testthat()
devtools::test()

# Vignettes
# devtools::use_vignette("discharge") # discharge estimation


# Datasets ----------------------------------------------------------------
# dir.create("data")
use_data(Po, Po_w, Po_s, Po_dA, overwrite = TRUE) # See inst/notebook20170717.Rmd

# internal, for functions
# use_data(scTable, olsonTbl, tzTable, no3Flow,
#          internal = TRUE, overwrite = TRUE)


# load and install package ------------------------------------------------
devtools::install()


