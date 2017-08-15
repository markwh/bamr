# validation functions
# Copied / adapted from SWOT project

## Model performance metrics used in Pepsi Challenge paper --------------------

#' Create a data.frame for BAM validation
#' 
#' @param fit A stanfit object, as returned from \code{bam_estimate()}
#' @param qobs a vector of observed flow.
#' 
#' @export
bam_valdata <- function(fit, qobs) {
  stopifnot(is(fit, "stanfit"))
  stopifnot(is.numeric(qobs))
  qpred <- bam_qpred(fit = fit, chain = "all") %>% 
    dplyr::transmute(time, qpred = mean)
  stopifnot(length(qobs) == nrow(qpred))
  out <- cbind(qpred, qobs = qobs)
  out
}

#' Calculate validation metrics and plots
#' 
#' @param fit A stanfit object, as returned from \code{bam_estimate()}
#' @param qobs a vector of observed flow.
#' 
#' @export
bam_validate <- function(fit, qobs, stats = c("RRMSE", "MRR", "SDRR", 
                                              "NSE", "NRMSE", "rBIAS",
                                              "CoV", "logNSE", "Ej")) {
  stats <- match.arg(stats, several.ok = TRUE)
  valdata <- bam_valdata(fit = fit, qobs = qobs)
  pred <- valdata$qpred
  obs <- valdata$qobs
  
  statvals <- vapply(stats, do.call, numeric(1),
                     args = list(pred = pred, meas = obs))
  
  out <- structure(list(valdata = valdata,
                        stats = statvals), 
                   class = c("bamval"))
}

#' Plot a bamval object to show predictive performance
#' @import ggplot2
#' @export
plot.bamval <- function(bamval) {
  valdata <- bamval$valdata
  ggplot(valdata, aes(x = qobs, y = qpred)) + 
    geom_point() +
    geom_abline(aes(intercept = 0, slope = 1))
}


#' Relative root-mean-square error
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @export
RRMSE <- function(pred, meas) 
  sqrt(mean((pred - meas)^2 / meas^2))

#' Mean relativ residual
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @export
MRR <- function(pred, meas)
  mean((meas - pred) / meas)

#' Standard deviation of relative residual
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @export
SDRR <- function(pred, meas)
  sd((meas - pred) / meas)

#' Nash-Sutcliffe efficiency
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @importFrom stats var
#' @export
NSE <- function(pred, meas)
  1 - var(meas - pred) / var(meas)

#' Normalized root-mean-square error
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @export
NRMSE <- function(pred, meas)
  sqrt(mean((meas - pred)^2)) / mean(meas)

#' Relative bias
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @export
rBIAS <- function(pred, meas)
  mean(pred - meas) / mean(meas)

#' Coefficient of variation
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @importFrom stats sd
#' @export
#' 
CoV <- function(pred, meas)
  sd(pred - meas) / mean(meas)

#' E_j general efficiency statistic from Criss and Winston (2008)
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @param j j parameter from general efficiency statistic.
#' @export
Ej <- function(pred, meas, j = 1, bench = mean(meas))
  1 - mean(abs(meas - pred)) / mean(abs(pred - bench))

#' NSE, computed on log-transformed residuals
#' 
#' @param pred vector of predictions
#' @param meas vector of measurements
#' @export
logNSE <- function(pred, meas)
  1 - var(log(meas / pred)) / var(log(meas / mean(meas)))


