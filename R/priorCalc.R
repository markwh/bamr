# Prior calculation

#' Estimate AHG b exponent using bam data
#' 
#' @param Wobs Observed W,as a space-down, time-across matrix.
#' @export
estimate_b <- function(Wobs) {
  lwsd <- apply(log(Wobs), 1, sd)
  
  b_hat <- 0.02161 + 0.4578 * lwsd
  b_hat
}

#' Estimate base cross-sectional area using bam data
#' 
#' @param Wobs Observed W,as a space-down, time-across matrix.
#' @export
estimate_logA0 <- function(Wobs) {
  lwbar <- apply(log(Wobs), 1, mean)
  lwsd <- apply(log(Wobs), 1, sd)
  
  logA0hat <- -1.782 + 1.438 * lwbar - 2.268 * lwsd

  logA0hat
}
