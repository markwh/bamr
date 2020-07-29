# utility functions

# functions for getting Q bounds.

#' Minimum across xs of max across time of width
#' 
#' @param x a numeric matrix
minmax <- function(x)
  min(apply(x, 1, max))

#' Maximum across xs of min across time of width
#' 
#' @param x a numeric matrix
maxmin <- function(x) {
  max(apply(x, 1, min))
}
