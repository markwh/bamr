
data {
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times
  
  
  // *Actual* data
  vector[nt] logW[nx]; // measured widths


  // Hard bounds on parameters
  real lowerbound_logQ;
  real upperbound_logQ;
  real lowerbound_logQc; 
  real upperbound_logQc; 
  real lowerbound_logWc; 
  real upperbound_logWc; 
  real lowerbound_b; 
  real upperbound_b; 


  // *Known* likelihood parameters  
  real<lower=0> sigma_amhg;
  
  
  // Hyperparameters
  real logQ_hat; // Prior mean for logQ
  real logQc_hat; // Prior mean for logQc
  real logWc_hat; // Prior mean for logWc
  real b_hat[nx]; // ADD CHECK ON THIS FOR DATA PREP

  real<lower=0> b_sd;
  real<lower=0> logQ_sd;
  real<lower=0> logQc_sd;
  real<lower=0> logWc_sd;

}



parameters {
  vector<lower=lowerbound_logQ,upper=upperbound_logQ>[nt] logQ;
  real<lower=lowerbound_logWc,upper=upperbound_logWc> logWc;
  real<lower=lowerbound_logQc,upper=upperbound_logQc> logQc;
  real<lower=lowerbound_b,upper=upperbound_b> b[nx];
}



transformed parameters {
  vector[nt] amhg_rhs[nx];

  for (i in 1:nx) {
    amhg_rhs[i] = b[i] * (logQ - logQc) + logWc;
  }
}



model {
  
  // Priors
  logQ ~ normal(logQc_hat, logQ_sd);
  
  b ~ normal(b_hat, b_sd);
  logWc ~ normal(logWc_hat, logWc_sd);
  logQc ~ normal(logQc_hat, logQc_sd);


  // Likelihood
  for (i in 1:nx) {
    logW[i] ~ normal(amhg_rhs[i], sigma_amhg);
  }
}
