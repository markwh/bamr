#' Simulate SWOT data from a specified BAM model. 
#' 
#' @importFrom truncnorm rtruncnorm
#' @importFrom mvtnorm rmvnorm
#' @importFrom magic adiag

logQ_WBM <- 7
nt <- 365
nx <- 30
library(truncnorm)
lowerbound_b <- bam_settings("lowerbound_b")
upperbound_b <- bam_settings("upperbound_b")
logQc_sd <- bam_settings("logQc_sd")
sigma_man <- bam_settings("sigma_man")
sigma_amhg <- bam_settings("sigma_amhg")

df <- 36 # degrees of freedom for Wishart distribution

bam_simulate <- function(fit) {
  
  # Flow
  sigma_logQ <- rtruncnorm(1, a = 0, b = Inf,
                           mean = 1.03, sd = 0.4146)
  mu_logQ <- rnorm(1, logQ_WBM, cv2sigma(1)) # How far off might QWBM be?
  
  # Manning parameters
  mu_logA <- rnorm(nx, 1.209 + 0.753 * mu_logQ + 0.285 * sigma_logQ,
                   0.684)
  sigma_logA <- rtruncnorm(nx, a = 0, b = Inf,
                           0.0332 + 0.0182 * mu_logQ + 0.4883 * sigma_logQ,
                           0.2773)
  logn <- rtruncnorm(1, a = -4.6, b = -1.5, mean = -3.5, sd = 1)
  
  mu_manning <- 10 * mu_logA - 6 * logn - 6 * mu_logQ
  mu_logW <- rnorm(nx, 2.099 + 0.454 * mu_logQ, 0.502)
  mu_logS <- (4 *mu_logW - mu_manning) / 3
  
  logQc <- rnorm(1, logQ_WBM, logQc_sd)
  logWc <- rnorm(1, 2.099 + 0.454 * mu_logQ, 0.502)
  
  sigma_logW <- rtruncnorm(nx, 0, Inf, 
                           0.053 + 0.222 * sigma_logQ, 0.224)
  sigma_logS <- abs(rnorm(nx, 0, 0.4))
  
  sighat <- matrix(c(sigma_logQ, sigma_logA, sigma_logS, sigma_logW), 
                   ncol = 1)
  
  sigmat <- matrix(c(rep(sigma_logQ, nx),
                     sigma_logA,
                     sigma_logS, 
                     sigma_logW),
                   nc = 4,
                   byrow = FALSE)
  diags <- lapply(split(sigmat, f = 1:nx), diag)
  
  # Manually constructed correlation matrix, based on hydroSWOT, Pepsi
  # Order is logQ, logA, logS, logW
  corhat <- matrix(c(1, .92, .5, .75,
                     .92, 1, .5, .8,
                     .5, .5,  1, .1,
                     .75, .8, .1, 1), 
                   nrow = 4)
  
  # covhats <- lapply(diags, function(x) x %*% corhat %*% x)
  # 
  # isPosDef <- function(x) all(eigen(x)$values > 0)
  # 
  # pds <- vapply(covhats, isPosDef, logical(1))
  # if (!all(pds))
  #   stop("Not all simulated covariance matrices are positive definite.")
  
  # Idea is to simulate correlation and variance separately, then combine
  # into covariance matrix.
  cormats_array <- rWishart(nx, df = df, Sigma = corhat) / df
  cormats0 <- lapply(1:nx, function(x) cormats_array[,,x])
  
  # scale a matrix to give 1 on the diagonal
  scale_mat <- function(mat) {
    sigs <- sqrt(diag(mat))
    scaler <- sigs %o% sigs
    out <- mat / scaler
    out
  }
  cormats <- lapply(cormats, scale_mat)
  
  covmats <- mapply(function(rho, sigma) sigma %*% rho %*% sigma, 
                    rho = cormats, sigma = diags, SIMPLIFY = FALSE)
  
  # combine all matrices into a single big matrix for flow, all cross-sections vars
  qparts <- lapply(covmats, function(x) x[-1, 1]) %>% 
    unlist() %>% 
    c(covmats[[1]][1,1], .)
  aswparts <- lapply(covmats, function(x) x[-1, -1])
  aswcov <- matrix(nrow = length(qparts), ncol = length(qparts))
  aswcov[1,] <- aswcov[, 1] <- qparts
  aswcov[-1, -1] <- Reduce(adiag, aswparts)
  
  # hydro variable values
  muvec <- c(mu_logQ, as.vector(t(cbind(mu_logA, mu_logS, mu_logW))))
  vals <- rmvnorm(n = nt, mean = muvec, sigma = aswcov)
  
  vals_list <- mapply(function(mu, Sigma) rmvnorm(nt, mean = mu, sigma = Sigma),
                    mu = mulist, Sigma = covmats, 
                    SIMPLIFY = FALSE)
  
  vals_df <- lapply(vals_list, as.data.frame) %>% 
    lapply(setNames, c("logQ", "logA", "logS", "logW")) %>% 
    lapply(dplyr::mutate, time = 1:nt) %>% 
    dplyr::bind_rows(.id = "xs")
  
  # dA <- apply(logA, 1, function(x) exp(x) - min(exp(x))) %>% 
  #   t()
  # 
  # logA0 <- apply(logA, 1, min)
  
  # Observations
  
  w <- exp(amhg_lhs)
  s <- exp((4 * log(w) - man_lhs) / 3)
  dA <- dA
  
  bamdata <- bam_data(w = w, s = s, dA = dA, Qhat = exp(logQ_WBM))
}
