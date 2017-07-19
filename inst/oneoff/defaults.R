# defaults.R
# Mark Hagemann
# 7/18/2017
# Set default prior parameter values

#' Options manager for BAM defaults
#' 
bam_settings <- settings::options_manager(

  # Bounds on parameters
  lowerbound_logQ = quote(maxmin(bamata$logW) + log(0.5) + log(0.5)),
  upperbound_logQ = quote(minmax(bamata$logW) + log(40) + log(5)),
  
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
  logQc_hat = quote(mean(bamata$logQ_hat)),
  logWc_hat = quote(mean(bamata$logW)),
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
# 
# bam_defaults <- function(bamdata) {
#   
#   force(bamdata)
#   out <- list(
#     
#     # Bounds on parameters
#     lowerbound_logQ = eval(bam_settings("lowerbound_logQ")),
#     upperbound_logQ = eval(bam_settings("upperbound_logQ")),
#     
#     lowerbound_Ao = eval(bam_settings("lowerbound_Ao")),
#     upperbound_Ao = eval(bam_settings("upperbound_Ao")),
#     lowerbound_logn = eval(bam_settings("lowerbound_logn")),
#     upperbound_logn = eval(bam_settings("upperbound_logn")),
#     
#     lowerbound_logQc = eval(bam_settings("lowerbound_logQc")),
#     upperbound_logQc = eval(bam_settings("upperbound_logQc")),
#     lowerbound_logWc = eval(bam_settings("lowerbound_logWc")),
#     upperbound_logWc = eval(bam_settings("upperbound_logWc")), # 3 km
#     lowerbound_b = eval(bam_settings("lowerbound_b")),
#     upperbound_b = eval(bam_settings("upperbound_b")),
#     
#     
#     # *Known* likelihood parameters
#     sigma_man = eval(bam_settings("sigma_man")),
#     sigma_amhg = eval(bam_settings("sigma_amhg")),
#     
#     
#     # Hyperparameters
#     logQc_hat = eval(bam_settings("logQc_hat")),
#     logWc_hat = eval(bam_settings("logWc_hat")),
#     b_hat = eval(bam_settings("b_hat")),
#     logAo_hat = eval(bam_settings("logAo_hat")),
#     logn_hat = eval(bam_settings("logn_hat")),
#     
#     logQ_sd = eval(bam_settings("logQ_sd")),
#     logQc_sd = eval(bam_settings("logQc_sd")),
#     logWc_sd = eval(bam_settings("logWc_sd")),
#     b_sd = eval(bam_settings("b_sd")),
#     logAo_sd = eval(bam_settings("logAo_sd")),
#     logn_sd = eval(bam_settings("logn_sd"))
#   )
#   
#   out
# }