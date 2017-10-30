
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
#' @param max_xs Maximum number of cross-sections to allow in data. Used to reduce 
#'   sampling time. Defaults to 30.
#' @param seed RNG seed to use for sampling cross-sections, if nx > max_xs. 
#' @param missing How to treat missing values in data? Currently the only option is
#'   "omit", which omits times with missing observations. 
#' @export

bam_data <- function(w, 
                     s = NULL, 
                     dA = NULL, 
                     Qhat, 
                     max_xs = 30L,
                     seed = NULL,
                     missing = c("omit", "impute")) {

  missing <- match.arg(missing)
  
  s <- if(is.null(s)) NULL else s
  
  datalist <- list(Wobs = w,
                Sobs = s,
                dAobs = dA,
                logQ_hat = log(Qhat))
  
  datalist <- bam_check_args(datalist)
  datalist <- bam_check_nas(datalist, missing = missing)

  nx <- nrow(datalist$Wobs)
  nt <- ncol(datalist$Wobs)
  
  out <- structure(c(datalist,
                        nx = nx, 
                        nt = nt), 
                   class = c("bamdata"))
  
  if (nx > max_xs)
    out <- sample_xs(out, n = max_xs, seed = seed)
  
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
  
  datalist$omitTimes <- integer(0)
  mats <- vapply(datalist, is.matrix, logical(1))
  if (missing == "omit") {
    nonas <- lapply(datalist[mats], function(x) !is.na(x))
    namat <- !Reduce(`*`, nonas, init = nonas[[1]])
    nainds <- which(namat, arr.ind = TRUE)[, 2]
    
    if (length(nainds) > 0) {
      message(sprintf("Omitting %s times with missing observations", length(nainds)))
      omitCols <- function(mat, which) mat[, -nainds]
      datalist[mats] <- lapply(datalist[mats], omitCols, which = nainds)
      datalist[["logQ_hat"]] <- datalist[["logQ_hat"]][-nainds]
      datalist[["omitTimes"]] <- nainds
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
#' @param bamdata An object of class bamdata, as returned by \code{bam_data}
#' @param variant Which BAM variant to use. Options are "manning_amhg" (default), 
#'   "manning", or "amhg".
#' @param ... Optional manually set parameters. Quoted expressions are allowed,
#'   e.g. \code{logQ_sd = "cv2sigma(0.8)"}. 
#' @export

bam_priors <- function(bamdata, 
                       variant = c("manning_amhg", "manning", "amhg"), 
                       ...) {
  variant <- match.arg(variant)
  if (variant != "amhg" && (is.null(bamdata$Sobs) || is.null(bamdata$dAobs)))
    stop("bamdata must have slope and dA data for non-amhg variants.")
  
  force(bamdata)
  paramset <- bam_settings(paste0(variant, "_params"))
  
  myparams0 <- rlang::quos(..., .named = TRUE)
  myparams <- do.call(settings::clone_and_merge, args = (options = c(list(options = bam_settings), 
                                                                     myparams0)))
  
  quoparams <- myparams()[-1:-3] # first 3 are parameter sets
  params <- lapply(quoparams, rlang::eval_tidy, data = bamdata)
  
  if (!length(params[["logQ_sd"]]) == bamdata$nt)
    params$logQ_sd <- rep(params$logQ_sd, length.out = bamdata$nt)
  
  out <- structure(params[paramset],
                   class = c("bampriors"))
  out
}

compose_bam_inputs <- function(bamdata, priors = bam_priors(bamdata)) {
  
  inps <- c(bamdata, priors)
  
  out <- inps
  out
  
}


#' Take a random sample of a bamdata object's cross-sections.
#' 
#' @param bamdata a bamdata object, as returned by \code{bam_data()}
#' @param n Number of cross-sections to 
#' @param seed option RNG seed, for reproducibility.
#' @importFrom methods is
#' @export
sample_xs <- function(bamdata, n, seed = NULL) {
  
  stopifnot(is(bamdata, "bamdata"))
  
  if (n >= bamdata$nx)
    return(bamdata)
  
  if (!is.null(seed))
    set.seed(seed)
  keepxs <- sort(sample(1:bamdata$nx, size = n, replace = FALSE))
  
  bamdata$nx <- n
  bamdata$Wobs <- bamdata$Wobs[keepxs, ]
  
  if (!is.null(bamdata$Sobs)) {
    bamdata$Sobs <- bamdata$Sobs[keepxs, ]
    bamdata$dAobs <- bamdata$dAobs[keepxs, ]
  }
  
  bamdata
}
