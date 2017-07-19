# utility functions

#' Convert coefficient of variation to sigma parameter of lognormal diistribution
#' 
#' @param cv Coefficient of variation
#' @export

cv2sigma <- function (cv) {
  sqrt(log(cv^2 + 1))
}



# functions for getting Q bounds.

#' Minimum across xs of max across time of width
minmax <- function(x)
  min(apply(x, 1, max))

#' Maximum across xs of min across time of width
maxmin <- function(x) {
  max(apply(x, 1, min))
}
