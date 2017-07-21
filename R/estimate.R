
#' Estimate BAM 
#' 
#' Fits a BAM model of one of several variants using Hamiltonian Monte Carlo.
#' 
#' @param variant Which BAM variant to use: amhg, manning_amhg, or manning
#' @param bamdata A bamdata object, as produced by \code{bam_data()}
#' @param bampriors A bampriors object. If none is supplied, defaults from calling
#'   \code{bam_priors(bamdata)} (with no other arguments).
#' @param ... Other arguments passed to rstan::sampling() for customizing the 
#'   Monte Carlo sampler
#' @import rstan
#' @export

bam_estimate <- function(bamdata, 
                         variant = c("manning", "amhg", "manning_amhg"), 
                         bampriors = NULL, ...) {
  variant <- match.arg(variant)
  stopifnot(is(bamdata, "bamdata"))
  if (is.null(bampriors))
    bampriors <- bam_priors(bamdata, variant = variant)
  stopifnot(is(bampriors, "bampriors"))
  
  baminputs <- compose_bam_inputs(bamdata, bampriors)
  
  stanfit <- stanmodels[[variant]]
  
  out <- sampling(stanfit, data = baminputs, ...)
  
  out
}
