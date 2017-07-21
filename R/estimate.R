
#' Estimate BAM 
#' 
#' Fits a BAM model of one of several variants using Hamiltonian Monte Carlo.
#' 
#' @param variant Which BAM variant to use: amhg, manning_amhg, or manning
#' @param bamdata A bamdata object, as produced by \code{bam_data()}
#' @param bampriors A bampriors object. If none is supplied, defaults from calling
#'   \code{bam_priors(bamdata)} (with no other arguments).
#' @export

bam_estimate <- function(bamdata, variant, bampriors = NULL) {
  
  stopifnot(is(bamdata, "bamdata"))
  
  if (is.null(bampriors)) {
    bampriors <- bam_priors(bamdata)
  }
  stopifnot(is(bampriors, "bampriors"))
  
  
}
