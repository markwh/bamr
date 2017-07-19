# Prior calculation

#' Estimate AHG b exponent using bam data
#' 
#' @param bamdata a bamdata object, created with bam_data()
#' @export
estimate_b <- function(bamdata) {
  if (!is(bamdata, "bamdata"))
    stop("bamdata must be a bamdata object, as created with bam_data function")
  lwsd <- apply(bamdata$logW, 2, sd)
  
  b_hat <- 0.02161 + 0.4578 * lwsd
  
  assertthat::are_equal(length(b_hat), bamdata$nx)
  b_hat
}

#' Estimate AHG b exponent using bam data
#' 
#' @param bamdata a bamdata object, created with bam_data()
#' @export
estimate_A0 <- function(bamdata) {
  if (!is(bamdata, "bamdata"))
    stop("bamdata must be a bamdata object, as created with bam_data function")
  lwbar <- apply(bamdata$logW, 2, mean)
  lwsd <- apply(bamdata$logW, 2, sd)
  
  logA0hat <- -1.782 + 1.438 * lwbar - 2.268 * lwsd
  A0hat <- exp(logA0hat)
  
  assertthat::are_equal(length(A0hat), bamdata$nx)
  
  A0hat
}