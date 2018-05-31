#' Simulate SWOT data from a specified BAM model. 
#' 
#' @importFrom truncnorm rtruncnorm
#' @importFrom mvtnorm rmvnorm
#' @importFrom magic adiag
#' @importFrom reshape2 melt
#' @importFrom stats rWishart rnorm

bam_simulate <- function(logQ_hat, nx, nt) {
  
  # Flow
  sigma_logQ <- rtruncnorm(1, a = 0, b = Inf,
                           mean = 1.03, sd = 0.4146)
  mu_logQ <- rnorm(1, logQ_hat, cv2sigma(1)) # How far off might logQ_hat be?
  
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
  
  # TODO: IMPLEMENT AMHG DEPENDENCE
  # logQc <- rnorm(1, logQ_hat, logQc_sd)
  # logWc <- rnorm(1, 2.099 + 0.454 * mu_logQ, 0.502)
  
  sigma_logW <- rtruncnorm(nx, 0, Inf, 
                           0.053 + 0.222 * sigma_logQ, 0.224)
  sigma_logS <- abs(rnorm(nx, 0, 0.4))
  
  sighat <- matrix(c(sigma_logQ, sigma_logA, sigma_logS, sigma_logW), 
                   ncol = 1)
  
  # Manually constructed correlation matrix, based on hydroSWOT, Pepsi
  # Order is logQ, logA, logS, logW
  corhat <- matrix(c(1, .92, .5, .75,
                     .92, 1, .5, .8,
                     .5, .5,  1, .1,
                     .75, .8, .1, 1), 
                   nrow = 4)
  
  qaswcor <- matrix(nrow = nx * 3 + 1, ncol = nx * 3 + 1)
  qcor <- c(1, rep(corhat[-1, 1], nx))
  qaswcor[1,] <- qaswcor[, 1] <- qcor
  
  aswcor1 <- corhat[-1, -1]
  tilemat <- function(mat, times) {
    toprows <- Reduce(cbind, lapply(1:times, function(x) mat))
    out <- Reduce(rbind, lapply(1:times, function(x) toprows))
    out
  }
  aswcor_tile <- tilemat(aswcor1, nx)
  aswcor_diag <- Reduce(adiag, lapply(1:nx, function(x) aswcor1))
  
  diagweight <- 0.15
  offdweight <- 1 - diagweight
  aswcor <- diagweight * aswcor_diag + offdweight * aswcor_tile
  qaswcor[-1, -1] <- aswcor
  sigmat <- diag(c(sigma_logQ, sigma_logA, sigma_logS, sigma_logW))
  qaswcov <- sigmat %*% qaswcor %*% sigmat
  
  # Randomly generate a covariance matrix from Wishart distribution
  qaswcov_rand <- rWishart(1, df = nrow(qaswcov), Sigma = qaswcov)[,,1] / 91
  
  # hydro variable values
  muvec <- c(mu_logQ, as.vector(t(cbind(mu_logA, mu_logS, mu_logW))))
  vals <- rmvnorm(n = nt, mean = muvec, sigma = qaswcov_rand)
  
  dfnames <- rep(c("A", "S", "W"), times = nx) %>% 
    paste(rep(1:nx, each = 3), sep = "_") %>% 
    c("Q", .) %>% 
    paste0("log", .)
  
  vals_df <- as.data.frame(vals) %>% 
    setNames(dfnames) %>% 
    mutate(time = 1:nt) %>% 
    melt(id.vars = "time") %>% 
    mutate(xs = as.numeric(substr(variable, start = 6L, stop = 100L)),
           var = substr(variable, start = 1L, stop = 4L))
  
  vals_list <- split(vals_df, f = vals_df$var)
  
  # Observations and parameters
  
  # format a data.frame in space-down, time-across DAWG format
  formatDAWG <- function(df) {
    acast(df, xs ~ time, value.var = "value")
  }
  
  Q <- exp(vals_list$logQ$value)
  
  A <- exp(formatDAWG(vals_list$logA))
  A0 <- apply(A, 1, min)
  A0_mat <- matrix(A0, nrow = nx, ncol = nt, byrow = FALSE)
  dA <- A - A0_mat
  
  s <- exp(formatDAWG(vals_list$logS))
  w <- exp(formatDAWG(vals_list$logW))

  logn <- logn # generated stochastically above; mu_logS depends on it.
  b <- qaswcov_rand[1 + (1:nx * 3), 1] / qaswcov_rand[1,1] # from regression coef math
  
  bamdata <- bam_data(w = w, s = s, dA = dA, Qhat = exp(logQ_hat))
  params <- list(A0 = A0,
                 logn = logn,
                 n = exp(logn))
  
  out <- list(bamdata = bamdata, params = params)
  out
}
