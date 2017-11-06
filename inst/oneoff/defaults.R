# defaults.R
# Mark Hagemann
# Set default prior parameter values

#' Options manager for BAM defaults
#' 
bam_settings <- settings::options_manager(

  # Bounds on parameters
  lowerbound_logQ = quote(maxmin(log(bamata$Wobs)) + log(0.5) + log(0.5)),
  upperbound_logQ = quote(minmax(log(bamata$Wobs)) + log(40) + log(5)),
  
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
  sigma_man = 0.25,
  sigma_amhg = 0.22, # UPDATE THIS FROM CAITLINE'S WORK
  
  
  # Hyperparameters
  # logQ_hat # NO DEFAULT FOR THIS--MUST BE SUPPLIED BY USER
  logQc_hat = quote(mean(bamata$logQ_hat)),
  logWc_hat = quote(mean(log(bamata$Wobs))),
  b_hat = quote(estimate_b(bamdata)),
  logAo_hat = quote(estimate_A0(bamdata)),
  logn_hat = -3.5,
  
  logQ_sd = cv2sigma(1), # CV of Q equals 1
  logQc_sd = cv2sigma(1), # CV of Q equals 1; UPDATE THIS
  logWc_sd = cv2sigma(0.01),
  b_sd = 0.05, # UPDATE THIS
  logAo_sd = 0.1,
  logn_sd = 1
)
