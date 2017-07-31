#' Simulate SWOT data from a specified BAM model. 
#' 
#' @importFrom truncnorm rtruncnorm

logQ_WBM <- 7
nt <- 365
nx <- 30
library(truncnorm)
lowerbound_b <- bam_settings("lowerbound_b")
upperbound_b <- bam_settings("upperbound_b")
logQc_sd <- bam_settings("logQc_sd")
sigma_man <- bam_settings("sigma_man")
sigma_amhg <- bam_settings("sigma_amhg")


bam_simulate <- function(fit) {
  
  # Flow
  
  sigma_logQ <- rtruncnorm(1, a = 0, b = Inf,
                           mean = 1.03, sd = 0.4146)
  mu_logQ <- rnorm(1, logQ_WBM, cv2sigma(1)) # How far off might QWBM be?
  
  # logQ <- rnorm(nt, mu_logQ, sigma_logQ)
  # logQ_mat <- matrix(rep(logQ, nx), nrow = nx, ncol = nt, byrow = TRUE)
  
  # Manning parameters
  mu_logA <- rnorm(nx, 1.209 + 0.753 * mu_logQ + 0.285 * sigma_logQ,
                   0.684)
  sigma_logA <- rtruncnorm(nx, a = 0, b = Inf,
                           0.0332 + 0.0182 * mu_logQ + 0.4883 * sigma_logQ,
                           0.2773)
  
  # logA <- lapply(mu_logA, 
  #          function(x) rnorm(nt, x + 0.455 * (logQ - mean(logQ)), sigma_logA)) %>% 
  #   as.data.frame() %>% 
  #   as.matrix() %>% 
  #   unname() %>% 
  #   t()
  # 
  # dA <- apply(logA, 1, function(x) exp(x) - min(exp(x))) %>% 
  #   t()
  # 
  # logA0 <- apply(logA, 1, min)
  logn <- rtruncnorm(1, a = -4.6, b = -1.5, mean = -3.5, sd = 1)
  
  # AMHG parameters
  
  # b <- truncnorm::rtruncnorm(nx, 
  #                            a = lowerbound_b,
  #                            b = upperbound_b,
  #                            mean = 0.262 * sigma_logA,
  #                            sd = 0.1295)
  # b_mat <- matrix(rep(b, nt), nrow = nx, ncol = nt, byrow = FALSE)
  # 
  logQc <- rnorm(1, logQ_WBM, logQc_sd)
  logWc <- rnorm(1, 2.099 + 0.454 * mu_logQ, 0.502)
  
  # Likelihood
  man_rhs <- 10 * logA - 6 * logn - 6 * logQ_mat
  man_lhs <- apply(man_rhs, 1, function(x) rnorm(nt, x, 1.5)) %>% 
    t()

  amhg_rhs <- b_mat * (logQ_mat - logQc) + logWc
  amhg_lhs <- apply(amhg_rhs, 1, function(x) rnorm(nt, x, sigma_amhg)) %>% 
    t()
  
  sigma_logW <- rtruncnorm(nx, 0, Inf, 
                           0.053 + 0.222 * sigma_logQ, 0.224)
  sigma_logS <- abs(rnorm(nx, 0, 0.4))
  
  sighat <- matrix(c(sigma_logQ, sigma_logA, sigma_logS, sigma_logW), 
                   ncol = 1)
  corhat <- matrix(c(1, .92, .5, .75,
                     .92, 1, .5, .8,
                     .5, .5,  1, .1,
                     .75, .8, .1, 1), 
                   nrow = 4)
  
  covhat <-  %*% corhat %*% sighat
  
  # Observations
  w <- exp(amhg_lhs)
  s <- exp((4 * log(w) - man_lhs) / 3)
  dA <- dA
  
  bamdata <- bam_data(w = w, s = s, dA = dA, Qhat = exp(logQ_WBM))
}
