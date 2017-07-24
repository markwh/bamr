
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
#' @param w Matrix (or data frame) of widths: time as columns, space as rows
#' @param s Matrix of slopes: time as columns, space as rows
#' @param dA Matrix of area above base area: time as columns, space as rows
#' @param Qhat Vector of Q estimates. Needed to create prior on Q. 
#' @export

bam_data <- function(w, 
                     s = NULL, 
                     dA = NULL, 
                     Qhat, 
                     missing = c("omit", "impute")) {

  missing <- match.arg(missing)
  
  logS <- if(is.null(s)) NULL else log(s)
  
  datalist <- list(logW = log(w),
                logS = logS,
                dA = dA,
                logQ_hat = log(Qhat))
  
  datalist <- bam_check_args(datalist)
  datalist <- bam_check_nas(datalist, missing = missing)

  nx <- nrow(datalist$logW)
  nt <- ncol(datalist$logW)
  
  out <- structure(c(datalist,
                        nx = nx, 
                        nt = nt), 
                   class = c("bamdata"))
  out
}

bam_check_args <- function(datalist) {
  
  logQ_hat <- datalist$logQ_hat
  matlist <- datalist[names(datalist) != "logQ_hat"]
  
  # Remove NULLs
  matlist <- matlist[!vapply(matlist, is.null, logical(1))]
  
  # Check types
  if (!(is(logQ_hat, "numeric") && is(logQ_hat, "vector")))
    stop("Qhat must be a numeric vector.\n")
  if (!all(vapply(matlist, is, logical(1), "matrix")))
    stop("All data must be a supplied as a matrix.\n")
      

  # Check dims
  nr <- nrow(matlist[[1]])
  nc <- ncol(matlist[[1]])
  if (!(all(vapply(matlist, nrow, 0L) == nr) &&
        all(vapply(matlist, ncol, 0L) == nc)))
    stop("All data must have same dimensions.\n")
  if (!length(logQ_hat) == nc)
    logQ_hat <- rep(logQ_hat, length.out = nc)
  
  out <- c(matlist, list(logQ_hat = logQ_hat))
  out
}

bam_check_nas <- function(datalist, missing) {
  mats <- vapply(datalist, is.matrix, logical(1))
  if (missing == "omit") {
    nonas <- lapply(datalist[mats], function(x) !is.na(x))
    namat <- !Reduce(`*`, nonas, init = nonas[[1]])
    nainds <- which(namat, arr.ind = TRUE)[, 2]
    
    if (length(nainds) > 0) {
      message(sprintf("Omitting %s times with missing observations", length(nainds)))
      omitCols <- function(mat, which) mat[, -nainds]
      datalist[mats] <- lapply(datalist[mats], omitCols, which = nainds)
    }
  } else {
    stop("Missing value treatment other than 'omit' currently not implemented.\n")
  }
  out <- datalist
  out
}

#' Establish prior hyperparameters for BAM estimation
#' 
#' Produces a bampriors object that can be passed to bam_estimate function
#' 
#' @useDynLib bamr, .registration = TRUE
#' @param w Matrix (or data frame) of widths: time as rows, space as columns
#' @param s Matrix of slopes: time as rows, space as columns
#' @param dA Matrix of area above base area: time as rows, space as columns
#' @param ... Optional manually set parameters. Quoted expressions are allowed,
#'   e.g. \code{logQ_sd = "cv2sigma(0.8)"}. 
#' @export

bam_priors <- function(bamdata, 
                       variant = c("manning", "amhg", "manning_amhg"), 
                       ...) {
  variant <- match.arg(variant)
  if (variant != "amhg" && (is.null(bamdata$logS) || is.null(bamdata$dA)))
    stop("bamdata must have slope and dA data for non-amhg variants.")
  
  force(bamdata)
  paramset <- bam_settings(paste0(variant, "_params"))
  
  myparams <- settings::clone_and_merge(bam_settings, ...)
  
  charparams <- lapply(myparams(), as.character)[-1:-3] # first 3 are parameter sets
  params <- lapply(charparams, function(x) eval(parse(text = x)))
  
  out <- structure(params[paramset],
                   class = c("bampriors"))
  out
}

compose_bam_inputs <- function(bamdata, priors = bam_priors(bamdata)) {
  
  inps <- c(bamdata, priors)
  # # Quick-and-dirty fix for STAN wanting sideways matrices
  # mats <- vapply(inps, is.matrix, logical(1))
  # inps[mats] <- lapply(inps[mats], t)
  
  out <- inps
  out
  
}

