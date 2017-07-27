# BAMR - Bayesian AMHG + Manning estimation using R

[![Build Status](https://travis-ci.org/markwh/bamr.svg?branch=master)](https://travis-ci.org/markwh/bamr)
[![Coverage Status](https://img.shields.io/codecov/c/github/markwh/bamr/master.svg)](https://codecov.io/github/markwh/bamr?branch=master)


This package is currently under development. But it *can* be used. To install, run the following:

```
# First get devtools package
if (!require("devtools")) {
  install.packages("devtools")
  library("devtools")
}

# Then install from github
install_github("markwh/bamr", args = "--preclean", build_vignettes = FALSE, local = FALSE)
```

The bamr package facilitates Bayesian AMHG + Manning discharge estimation using stream slope, width, and partial cross-section area. It includes functions to preprocess and visualize data, perform Bayesian inference using Hamiltonian Monte Carlo (via models pre-written in the Stan language), and analyze the results. 

### Example dataset from Po River

The `Po` dataset contains all data required to perform BAM estimation of discharge. To attach the requisite items it contains, run:

```
data(Po)
attach(Po)
```

This will put the following objects in the global environment:

- Po_w: a matrix of widths (cross-sections as rows, days as columns)
- Po_s: a matrix of widths (cross-sections as rows, days as columns)
- Po_dA: a matrix of widths (cross-sections as rows, days as columns)
- Po_QWBM: a vector of water-balance-model discharge estimates for the days represented in the other matrices. This is required as a prior parameter for BAM. In this case, the estimates are all the same, representing the average water-balance-model discharge for the Po, and could be supplied as a single number rather than a vector. But it is also possible to specify time-varying prior estimates.

### 1. Preprocessing Data

The `bam_data` function takes width, slope, partial area, and best-guess flow as arguments.

```
Po_data <- bam_data(w = Po_w, s = Po_s, dA = Po_dA, Qhat = Po_QWBM)
```

This returns an object of class "bamdata" that will be used to create prior parameters via `bam_priors` and perform Bayesian inference via `bam_estimate`.

It is a good idea to plot the data; this can be done by simply calling

```
plot(Po_data)
```

As the `plot` function returns a ggplot object, it can be modified, for example to make the y-axis be log scale:

```
library(ggplot2)
plot(Po_data) + scale_y_log10()
```


#### Width-only datasets

The AMHG-only BAM variant relies on width data only, and so it is possible to specify a `bamdata` object containing width-only data. (An *a priori* discharge estimate is still required.)

```
Po_amhg <- bam_data(w = Po_w, Qhat = Po_QWBM)

plot(Po_amhg)
```


### 2. Specifying prior parameters

**bamr** uses a set of default prior parameters, which can be displayed by calling `bam_settings()`

Individual settings can also be viewed, e.g.

```
bam_settings("lowerbound_A0", "upperbound_A0")
bam_settings("logQc_hat")
```

These settings are used to generate a set of BAM prior parameters for a particular analysis, using the `bam_priors` function:

```
Po_priors <- bam_priors(bamdata = Po_data)
```

`bam_priors` has an additional argument, `variant`, which can be changed to select the BAM variant. This can be either `manning_amhg` (the default, which includes all parameters), `manning`, or `amhg`. 

If you wish to use a different prior, you can specify it. For example:

```
Po_priors_mod1 <- bam_priors(bamdata = Po_data, lowerbound_A0 = 20)
```

Data-dependent priors can also be specified using quoted expression. These must reference an object called "bamdata". For example:

```
Po_priors_mod2 <- bam_priors(bamdata = Po_data, 
                             logQc_hat = "median(bamdata$logQ_hat)")
```


### 3. Estimation via Bayesian inference

Once data and priors have been established, we are ready to make BAM estimates using `bam_estimate`. Although this has been optimized as much as possible, it is still computationally intensive and may take on the order of several minutes to run. 

In order to demonstrate the inference step, we will use a small dataset, `Po_sm`, that is a subset of the days and cross-sections in `Po`. 

```{r, eval = FALSE}
data(Po_sm)
attach(Po_sm)
Po_data_sm <- bam_data(w = Po_w_sm, s = Po_s_sm, dA = Po_dA_sm, Qhat = Po_QWBM_sm)
plot(Po_data_sm)
```

```
Po_est <- bam_estimate(bamdata = Po_data_sm,
                       variant = "manning")
```

Note that in this example I haven't touched the `bam_priors` function. The default behavior for `bam_estimate` is to use `bampriors = bam_priors(bamdata)`, which uses the default priors as discussed above. An estimate using different priors could be performed using 

```{r, eval = FALSE}
bam_estimate(bamdata = Po_data_sm, 
             bampriors = bam_priors(bamdata = Po_data_sm, lowerbound_logQ = 3),
             variant = "manning")
```

or some such.

### 4. Analyzing results. 

Once a BAM estimate has been computed, a hydrograph can be generated using `bam_hydrograph`. 

```
bam_hydrograph(fit = Po_est)
```