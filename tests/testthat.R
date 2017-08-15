library(testthat)
library(bamr)

options("mc.cores" = 2) # Because build doesn't let you use more than 2 cores
test_check("bamr")
