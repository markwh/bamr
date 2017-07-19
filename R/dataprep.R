
# Using advice from read-and-delete-me:
# "Be sure to add useDynLib(mypackage, .registration = TRUE) to the NAMESPACE file
# which you can do by placing the line   #' @useDynLib rstanarm, .registration = TRUE
# in one of your .R files
# see rstanarm's 'rstanarm-package.R' file"

#' Preprocess data for BAM estimation
#' 
#' Produces a bamdata object that can be passed to bam_estimate function
#' 
#' @useDynLib bamr, .registration = TRUE
#' @param w Matrix (or data frame) of widths: time as rows, space as columns
#' @param s Matrix of slopes: time as rows, space as columns
#' @param dA Matrix of area above base area: time as rows, space as columns
#' @param Qhat Vector of Q estimates. Needed to create prior on Q. 
#' @export

bam_data <- function(w, s, dA, Qhat, missing = c("omit", "impute")) {
  
  if (! (dim(w) == dim(s) && dim(w) == dim(dA)))
    stop("All data must have same dimensions")
  
  missing = match.arg(missing)

  logW <- log(w)
  logS <- log(s)
  logQ_hat <- log(Qhat)
  # dA <- dA
  
  if (missing == "omit") {
    nainds <- which(is.na(logW) | is.na(logS) | is.na(dA), arr.ind = TRUE)[, 1]
    if (length(nainds) > 0) {
      message(sprintf("Omitting %s missing rows", length(nainds)))
      
      logW <- logW[-nainds, ]
      logS <- logS[-nainds, ]
      dA <- dA[-nainds, ]
      logQ_hat <- logQ_hat[-nainds]
    }
  } else {
    stop("Missing value treatment other than 'omit' currently not implemented.\n")
  }

  nx <- ncol(logW)
  nt <- nrow(logW)
  
  out <- structure(list(logW = logW,
                        logS = logS,
                        dA = dA,
                        logQ_hat = logQ_hat,
                        nx = nx, 
                        nt = nt), 
                   class = c("bamdata"))
}


#' Establish prior hyperparameters for BAM estimation
#' 
#' Produces a bampriors object that can be passed to bam_estimate function
#' 
#' @useDynLib bamr, .registration = TRUE
#' @param w Matrix (or data frame) of widths: time as rows, space as columns
#' @param s Matrix of slopes: time as rows, space as columns
#' @param dA Matrix of area above base area: time as rows, space as columns
#' @export

bam_priors <- function(bamdata, ...) {
  force(bamdata)
  myparams <- settings::clone_and_merge(bam_settings, ...)
  
  charparams <- lapply(myparams(), as.character)
  out <- lapply(charparams, function(x) eval(parse(text = x)))
  out
}

compose_bam_inputs <- function(bamdata, priors = bam_priors(bamdata)) {
  
  out <- c(bamdata, priors)
  out
  
}

