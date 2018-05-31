
#' Create a log-likelihood function for a bamdata object. 
#' 
#' @param bamdata A bamdata object, as returned by \code{bam_data}
bam_llfun <- function(bamdata) {
  
  out <- function(params) {
    
    d
    
  }
}

bam_errmatfun <- function(bamdata) {
  logW <- log(bamdata$Wobs)
  logS <- log(bamdata$Sobs)
  
  nx <- nrow(logW)
  nt <- ncol(logW)
  
  dA <- bamdata$dA
  dA_adj <- dA - swot_vec2mat
}