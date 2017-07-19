
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
#' @export

bam_data <- function(w, s, dA, Qhat) {
  
  if (! (dim(w) == dim(s) && dim(w) == dim(dA)))
    stop("All data must have same dimensions")
  
  logW <- as.data.frame(w)
  logS <- as.data.frame(s)
  dA <- as.data.frame(dA)
  
  nx <- ncol(logW)
  nt <- nrow(logW)
  
  
  out <- structure(list(logW = logW,
                        logS = logS,
                        dA = dA,
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
  
  out <- lapply(myparams, eval)
  out
}

compose_bam_inputs <- function(bamdata, priors = bam_priors(bamdata)) {
  
  out <- c(bamdata, priors)
  
}

