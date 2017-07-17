
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

bam_data <- function(w, s, dA) {
  
  if (! (dim(w) == dim(s) && dim(w) == dim(dA)))
    stop("All data must have same dimensions")
  
  w <- as.data.frame(w)
  s <- as.data.frame(s)
  dA <- as.data.frame(dA)
  
  w_long <- reshape2::melt(w)
  # w_long <- tidyr::gather_(data = w, key_col = "xs", value_col = "value",
                           # gather_cols = c())
  
  out <- structure(, class = c("bamdata", matrix))
}