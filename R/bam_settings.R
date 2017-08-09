
#' Options manager for BAM defaults
#' 
bam_settings <- settings::options_manager(
  # BAM variant parameter sets
  manning_params = c("lowerbound_logQ", "upperbound_logQ", "lowerbound_A0", 
    "upperbound_A0", "lowerbound_logn", "upperbound_logn", 
    "sigma_man", "logA0_hat", "logn_hat", "mu_logQ_sd", "sigma_logQ", "logA0_sd", "logn_sd"),
  
  amhg_params = c("lowerbound_logQ", "upperbound_logQ", "lowerbound_logQc", 
     "upperbound_logQc", "lowerbound_logWc", "upperbound_logWc", 
     "lowerbound_b", "upperbound_b", "sigma_amhg", "logQc_hat", "logWc_hat", 
     "b_hat", "mu_logQ_sd", "sigma_logQ", "logQc_sd", "logWc_sd", "b_sd"),
  
  manning_amhg_params = c("lowerbound_logQ", "upperbound_logQ", "lowerbound_A0", 
     "upperbound_A0", "lowerbound_logn", "upperbound_logn", "lowerbound_logQc", 
     "upperbound_logQc", "lowerbound_logWc", "upperbound_logWc", 
     "lowerbound_b", "upperbound_b", "sigma_man", "sigma_amhg", "logQc_hat", 
     "logWc_hat", "b_hat", "logA0_hat", "logn_hat", "mu_logQ_sd", "sigma_logQ", "logQc_sd", 
     "logWc_sd", "b_sd", "logA0_sd", "logn_sd"),
  
  # Bounds on parameters
  lowerbound_logQ = "maxmin(bamdata$logW) + log(0.5) + log(0.5)",
  upperbound_logQ = "minmax(bamdata$logW) + log(40) + log(5)",
  
  lowerbound_A0 = 30,
  upperbound_A0 = 1e6,
  lowerbound_logA0 = log(30),
  upperbound_logA0 = log(1e6),
  lowerbound_logn = -4.6,
  upperbound_logn = -1.5,
  
  lowerbound_logQc = 0,
  upperbound_logQc = 10,
  lowerbound_logWc = 1,
  upperbound_logWc = 8, # 3 km
  lowerbound_b = 0.01,
  upperbound_b = 0.8,
  
  
  # *Known* likelihood parameters
  sigma_man = 6 * 0.25,
  sigma_amhg = 0.22, # UPDATE THIS FROM CAITLINE'S WORK
  
  
  # Hyperparameters
  # logQ_hat # NO DEFAULT FOR THIS--MUST BE SUPPLIED BY USER
  logQc_hat = "mean(bamdata$mu_logQ_hat)",
  logWc_hat = "mean(bamdata$logW)",
  b_hat = "estimate_b(bamdata)",
  logA0_hat = "estimate_logA0(bamdata)",
  logn_hat = -3.5,
  
  mu_logQ_sd = sqrt(log((0.5)^2 + 1)), # CV of Q equals 0.5
  sigma_logQ = 0.7,
  logQc_sd = sqrt(log(1^2 + 1)), # CV of Q equals 1; UPDATE THIS
  logWc_sd = sqrt(log(0.01)^2 + 1),
  b_sd = 0.05, # UPDATE THIS
  logA0_sd = 0.1,
  logn_sd = 1
)
