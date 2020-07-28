
#' Options manager for BAM defaults
#' 
#' @param ... (Optional) named settings to query or set. 
#' @param .__defaults See \code{?settings::option_manager}  
#' @param .__reset See \code{?settings::option_manager}
#' @export
bam_settings <- settings::options_manager(
  # # BAM variant parameter sets
  # manning_params = c("lowerbound_logQ", "upperbound_logQ", "lowerbound_A0", 
  #   "upperbound_A0", "lowerbound_logn", "upperbound_logn", 
  #   "sigma_man", "logA0_hat", "logn_hat", "logQ_sd", "logA0_sd", "logn_sd",
  #   "Werr_sd", "Serr_sd", "dAerr_sd"),
  # 
  # amhg_params = c("lowerbound_logQ", "upperbound_logQ", "lowerbound_logQc", 
  #    "upperbound_logQc", "lowerbound_logWc", "upperbound_logWc", 
  #    "lowerbound_b", "upperbound_b", "sigma_amhg", "logQc_hat", "logWc_hat", 
  #    "b_hat", "logQ_sd", "logQc_sd", "logWc_sd", "b_sd",
  #    "Werr_sd"),
  # 
  paramnames = c("lowerbound_logQ", "upperbound_logQ", "lowerbound_A0", 
     "upperbound_A0", "lowerbound_logn", "upperbound_logn", "lowerbound_logQc", 
     "upperbound_logQc", "lowerbound_logWc", "upperbound_logWc", 
     "lowerbound_b", "upperbound_b", "sigma_man", "sigma_amhg", "logQc_hat", 
     "logWc_hat", "b_hat", "logA0_hat", "logn_hat", "logQ_sd", "logQc_sd", 
     "logWc_sd", "b_sd", "logA0_sd", "logn_sd", 
     "Werr_sd", "Serr_sd", "dAerr_sd"),
  
  # Bounds on parameters
  lowerbound_logQ = rlang::quo(maxmin(log(Wobs)) + log(0.5) + log(0.5)),
  upperbound_logQ = rlang::quo(minmax(log(Wobs)) + log(40) + log(5)),
  
  lowerbound_A0 = 30,
  upperbound_A0 = 1e6,
  lowerbound_logn = -4.6,
  upperbound_logn = -1.5,
  
  lowerbound_logQc = 0,
  upperbound_logQc = 10,
  lowerbound_logWc = 1,
  upperbound_logWc = 8, # 3 km
  lowerbound_b = 0.01,
  upperbound_b = 0.8,
  
  
  # *Known* likelihood parameters
  sigma_man = 0.25,
  sigma_amhg = 0.22, # UPDATE THIS FROM CAITLINE'S WORK
  
  
  # Hyperparameters
  # logQ_hat # NO DEFAULT FOR THIS--MUST BE SUPPLIED BY USER
  logQc_hat = rlang::quo(mean(logQ_hat)),
  logWc_hat = rlang::quo(mean(log(Wobs))),
  b_hat = rlang::quo(estimate_b(Wobs)),
  logA0_hat = rlang::quo(estimate_logA0(Wobs)),
  logn_hat = -3.5,
  
  logQ_sd = sqrt(log(1^2 + 1)), # CV of Q equals 1
  logQc_sd = sqrt(log(1^2 + 1)), # CV of Q equals 1; UPDATE THIS
  logWc_sd = sqrt(log(0.01^2 + 1)),
  b_sd = 0.05, # UPDATE THIS
  logA0_sd = 0.5,
  logn_sd = 0.25,
  
  # Observation errors. 
  Werr_sd = 10,
  Serr_sd = 1e-5,
  dAerr_sd = 10
)
