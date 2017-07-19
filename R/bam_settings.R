
#' Options manager for BAM defaults
#' 
bam_settings <- settings::options_manager(
  
  # Bounds on parameters
  lowerbound_logQ = "maxmin(bamdata$logW) + log(0.5) + log(0.5)",
  upperbound_logQ = "minmax(bamdata$logW) + log(40) + log(5)",
  
  lowerbound_Ao = 30,
  upperbound_Ao = 1e6,
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
  logQc_hat = "mean(bamdata$logQ_hat)",
  logWc_hat = "mean(bamdata$logW)",
  b_hat = "estimate_b(bamdata)",
  logAo_hat = "estimate_A0(bamdata)",
  logn_hat = -3.5,
  
  logQ_sd = sqrt(log(1^2 + 1)), # CV of Q equals 1
  logQc_sd = sqrt(log(1^2 + 1)), # CV of Q equals 1; UPDATE THIS
  logWc_sd = sqrt(log(0.01)^2 + 1),
  b_sd = 0.05, # UPDATE THIS
  logAo_sd = 0.1,
  logn_sd = 1
)
