# bamr - Bayesian AMHG + Manning estimation using R

<img src="https://raw.githubusercontent.com/markwh/mcfli-swotr/master/logos/bamr/logo.png" width=200 alt="bamr Logo"/>

[![Build Status](https://travis-ci.org/markwh/bamr.svg?branch=master)](https://travis-ci.org/markwh/bamr) 
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/markwh/bamr?branch=master&svg=true)](https://ci.appveyor.com/project/markwh/bamr) 
[![Coverage Status](https://img.shields.io/codecov/c/github/markwh/bamr/master.svg)](https://codecov.io/github/markwh/bamr?branch=master)

## Overview

The bamr package facilitates Bayesian AMHG + Manning discharge estimation using stream slope, width, and partial cross-section area. It includes functions to preprocess and visualize data, perform Bayesian inference using Hamiltonian Monte Carlo (via models pre-written in the Stan language), and analyze the results. 

## Installation

**bamr** can be installed from github as follows:

```
# First get devtools package
if (!require("devtools")) {
  install.packages("devtools")
  library("devtools")
}

# Then install from github
install_github("markwh/bamr", local = FALSE)
```

## Usage

The best way to get started is to follow the examples in the included vignettes, now located at the [**bamr** website](https://markwh.github.io/bamr/index.html)

Also check out the companion [**swotr**](https://markwh.github.io/swotr/) package.

