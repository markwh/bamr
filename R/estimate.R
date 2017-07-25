
#' Estimate BAM 
#' 
#' Fits a BAM model of one of several variants using Hamiltonian Monte Carlo.
#' 
#' @param bamdata A bamdata object, as produced by \code{bam_data()}
#' @param variant Which BAM variant to use: amhg, manning_amhg, or manning
#' @param bampriors A bampriors object. If none is supplied, defaults are used 
#'   from calling \code{bam_priors(bamdata)} (with no other arguments).
#' @param cores Number of processing cores for running chains in parallel. 
#'   See \code{?rstan::sampling}. Defaults to \code{parallel::detectCores}.
#' @param chains A positive integer specifying the number of Markov chains. 
#'   The default is 3.
#' @param iter Number of iterations per chain (including warmup). Defaults to 1000. 
#' @param ... Other arguments passed to rstan::sampling() for customizing the 
#'   Monte Carlo sampler
#' @import rstan
#' @export

bam_estimate <- function(bamdata, 
                         variant = c("manning", "amhg", "manning_amhg"), 
                         bampriors = NULL, 
                         cores = parallel::detectCores(),
                         chains = 3L,
                         iter = 1000L,
                         ...) {
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
