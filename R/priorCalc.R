# Prior calculation

#' Estimate AHG b exponent using bam data
#' 
#' @param Wobs Observed W,as a space-down, time-across matrix.
#' @export
estimate_b <- function(Wobs) {
  Wobs[Wobs <= 0] <- NA # I replaced missing values with 0 so Stan will accept
  lwsd <- apply(log(Wobs), 1, function(x) sd(x, na.rm = TRUE))
  
  b_hat <- 0.02161 + 0.4578 * lwsd
  b_hat
}

#' Estimate base cross-sectional area using bam data
#' 
#' @param Wobs Observed W,as a space-down, time-across matrix.
#' @export
estimate_logA0 <- function(Wobs) {
  Wobs[Wobs <= 0] <- NA # I replaced missing values with 0 so Stan will accept
  lwbar <- apply(log(Wobs), 1, mean, na.rm = TRUE)
  lwsd <- apply(log(Wobs), 1, sd, na.rm = TRUE)
  
  logA0hat <- -1.4058 + 1.4931 * lwbar - 0.2293 * lwsd

  logA0hat
}
