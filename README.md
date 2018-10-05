# bamr - Bayesian AMHG + Manning estimation using R

<img src="https://raw.githubusercontent.com/markwh/mcfli-swotr/master/logos/bamr/logo.png" width=200 alt="bamr Logo"/>

[![Build Status](https://travis-ci.org/markwh/bamr.svg?branch=master)](https://travis-ci.org/markwh/bamr) 
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/markwh/bamr?branch=master&svg=true)](https://ci.appveyor.com/project/markwh/bamr) 
[![Coverage Status](https://img.shields.io/codecov/c/github/markwh/bamr/master.svg)](https://codecov.io/github/markwh/bamr?branch=master)

## Overview

The bamr package facilitates Bayesian AMHG + Manning discharge estimation using stream slope, width, and partial cross-section area. It includes functions to preprocess and visualize data, perform Bayesian inference using Hamiltonian Monte Carlo (via models pre-written in the Stan language), and analyze the results. 

## Installation

As of version 0.1.6, the recommended installation method is to use the **drat** package, which facilitates using `install.packages()` to get the latest release of **bamr**. Windows users get the added benefit of having a pre-compiled binary installation, saving a significant amount of compilation time and memory overhead. 

The following commands will get the **drat** package, give R access to the repository containing **bamr**, and install the **bamr** package from that repository.

```
install.packages("drat") # Get the drat package
drat::addRepo("markwh") # Add the repository containing the bamr package
install.packages("bamr")
```

More information about **drat** is available [here](https://eddelbuettel.github.io/drat/DratForPackageUsers.html).


### Installation from github

The old way of installing **bamr** from github still works. To do that, run the following. 

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

