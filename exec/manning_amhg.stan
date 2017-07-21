
data {
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times


  // *Actual* data
  vector[nt] logW[nx]; // measured widths
  vector[nt] logS[nx]; // measured slopes
  vector[nt] dA[nx]; // measured area difference from base area
 
 
  // Hard bounds on parameters
  real lowerbound_logQ;
  real upperbound_logQ;  
  
  real lowerbound_Ao; // These must be scalars, unfortunately. 
  real upperbound_Ao;
  real lowerbound_logn;
  real upperbound_logn;
  
  real lowerbound_logQc;
  real upperbound_logQc;
  real lowerbound_logWc;
  real upperbound_logWc;
  real lowerbound_b;
  real upperbound_b;


  // *Known* likelihood parameters
  real<lower=0> sigma_man; // Manning error standard deviation
  real<lower=0> sigma_amhg; // AMHG error standard deviation


  // Hyperparameters
  vector[nt] logQ_hat; // prior mean on logQ
  real logQc_hat; // prior mean on logQc
  real logWc_hat;
  real b_hat[nx]; // ADD CHECK ON THIS FOR DATA PREP
  real logAo_hat[nx];
  real logn_hat;

  real<lower=0> logQ_sd;
  real<lower=0> logQc_sd;
  real<lower=0> logWc_sd;
  real<lower=0> b_sd;
  real<lower=0> logAo_sd;
  real<lower=0> logn_sd;
}



transformed data {
  vector[nt] man_lhs[nx];
  vector[nt] dA_pos[nx];

  for (i in 1:nx) {
    man_lhs[i] = 4. * logW[i] - 3. * logS[i]; // LHS of manning equation
    
    dA_pos[i] = dA[i] - min(dA[i]); // make all dA positive
  }
}



parameters {
  vector<lower=lowerbound_logQ,upper=upperbound_logQ>[nt] logQ;

  real<lower=lowerbound_logn,upper=upperbound_logn> logn;
  real<lower=lowerbound_Ao,upper=upperbound_Ao> Ao[nx];
  
  real<lower=lowerbound_logWc,upper=upperbound_logWc> logWc;
  real<lower=lowerbound_logQc,upper=upperbound_logQc> logQc;
  real<lower=lowerbound_b,upper=upperbound_b> b[nx];
}



transformed parameters {
  vector[nt] man_rhs[nx]; // RHS for Manning likelihood
  vector[nt] amhg_rhs[nx]; // RHS for AMHG likelihood
  
  vector[nt] logA_man[nx]; // log area for Manning's equation
  
  for (i in 1:nx) {
    for (t in 1:nt) {
      logA_man[i, t] = log(Ao[i] + dA_pos[i, t]);
    }
    man_rhs[i] = 10. * logA_man[i] - 6. * logn - 6. * logQ;
    amhg_rhs[i] = b[i] * (logQ - logQc) + logWc;
  }
}



model {
  
  // Priors
  logQ ~ normal(logQ_hat, logQ_sd);

  Ao ~ lognormal(logAo_hat, logAo_sd); // THINK ABOUT THIS MORE.
  logn ~ normal(logn_hat, logn_sd);

  b ~ normal(b_hat, b_sd);
  logWc ~ normal(logWc_hat, logWc_sd);
  logQc ~ normal(logQc_hat, logQc_sd);
  
  
  // Likelihood
  for (i in 1:nx) {
    man_lhs[i] ~ normal(man_rhs[i], sigma_man);
    logW[i] ~ normal(amhg_rhs[i], sigma_amhg);
  }
}
