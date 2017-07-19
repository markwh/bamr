bam_defaults <-
function(bamdata) {
  
  force(bamdata)
  out <- list(
    
    # Bounds on parameters
    lowerbound_logQ = eval(bam_settings("lowerbound_logQ")),
    upperbound_logQ = eval(bam_settings("upperbound_logQ")),
    
    lowerbound_Ao = eval(bam_settings("lowerbound_Ao")),
    upperbound_Ao = eval(bam_settings("upperbound_Ao")),
    lowerbound_logn = eval(bam_settings("lowerbound_logn")),
    upperbound_logn = eval(bam_settings("upperbound_logn")),
    
    lowerbound_logQc = eval(bam_settings("lowerbound_logQc")),
    upperbound_logQc = eval(bam_settings("upperbound_logQc")),
    lowerbound_logWc = eval(bam_settings("lowerbound_logWc")),
    upperbound_logWc = eval(bam_settings("upperbound_logWc")), # 3 km
    lowerbound_b = eval(bam_settings("lowerbound_b")),
    upperbound_b = eval(bam_settings("upperbound_b")),
    
    
    # *Known* likelihood parameters
    sigma_man = eval(bam_settings("sigma_man")),
    sigma_amhg = eval(bam_settings("sigma_amhg")),
    
    
    # Hyperparameters
    logQc_hat = eval(bam_settings("logQc_hat")),
    logWc_hat = eval(bam_settings("logWc_hat")),
    b_hat = eval(bam_settings("b_hat")),
    logAo_hat = eval(bam_settings("logAo_hat")),
    logn_hat = eval(bam_settings("logn_hat")),
    
    logQ_sd = eval(bam_settings("logQ_sd")),
    logQc_sd = eval(bam_settings("logQc_sd")),
    logWc_sd = eval(bam_settings("logWc_sd")),
    b_sd = eval(bam_settings("b_sd")),
    logAo_sd = eval(bam_settings("logAo_sd")),
    logn_sd = eval(bam_settings("logn_sd"))
  )
  
  out
}
