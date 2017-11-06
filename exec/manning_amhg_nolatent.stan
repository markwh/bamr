
data {
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times


  // *Actual* data
  vector[nt] Wobs[nx]; // measured widths
  vector[nt] Sobs[nx]; // measured slopes
  vector[nt] dAobs[nx]; // measured area difference from base area
  
  // real<lower=0> Werr_sd;
  // real<lower=0> Serr_sd;
  // real<lower=0> dAerr_sd;
 
 
  // Hard bounds on parameters
  real lowerbound_logQ;
  real upperbound_logQ;  
  
  real lowerbound_A0; // These must be scalars, unfortunately. 
  real upperbound_A0;
  real lowerbound_logn;
  real upperbound_logn;
  
  real lowerbound_logQc;
  real upperbound_logQc;
  real lowerbound_logWc;
  real upperbound_logWc;
  real lowerbound_b;
  real upperbound_b;


  // *Known* likelihood parameters
  vector<lower=0>[nt] sigma_man[nx]; // Manning error standard deviation
  vector<lower=0>[nt] sigma_amhg[nx]; // AMHG error standard deviation


  // Hyperparameters
  vector[nt] logQ_hat; // prior mean on logQ
  real logQc_hat; // prior mean on logQc
  real logWc_hat;
  real b_hat[nx]; // ADD CHECK ON THIS FOR DATA PREP
  real logA0_hat[nx];
  real logn_hat;

  vector<lower=0>[nt] logQ_sd;
  real<lower=0> logQc_sd;
  real<lower=0> logWc_sd;
  real<lower=0> b_sd;
  real<lower=0> logA0_sd;
  real<lower=0> logn_sd;
}



transformed data {
  vector[nt] logW[nx];
  vector[nt] logS[nx];
  vector[nt] dA_pos[nx];

  for (i in 1:nx) {
    logW[i] = log(Wobs[i]);
    logS[i] = log(Sobs[i]);
    dA_pos[i] = dAobs[i] - min(dAobs[i]); // make all dA positive
  }
}

parameters {
  vector<lower=lowerbound_logQ,upper=upperbound_logQ>[nt] logQ;
  real<lower=lowerbound_logn,upper=upperbound_logn> logn;
  real<lower=lowerbound_A0,upper=upperbound_A0> A0[nx];
  
  real<lower=lowerbound_logWc,upper=upperbound_logWc> logWc;
  real<lower=lowerbound_logQc,upper=upperbound_logQc> logQc;
  real<lower=lowerbound_b,upper=upperbound_b> b[nx];
  
  // vector<lower=0>[nt] Wact[nx];
  // vector<lower=0>[nt] Sact[nx];
  // vector[nt] dAact[nx];
}


transformed parameters {
  // vector[nt] logW[nx];
  // vector[nt] logS[nx];
  vector[nt] man_lhs[nx];
  vector[nt] logA_man[nx]; // log area for Manning's equation
  vector[nt] man_rhs[nx]; // RHS for Manning likelihood
  vector[nt] amhg_rhs[nx]; // RHS for AMHG likelihood
  
  for (i in 1:nx) {
    // logW[i] = log(Wact[i]);
    // logS[i] = log(Sact[i]);
    
    man_lhs[i] = 4. * logW[i] - 3. * logS[i]; // LHS of manning equation

    for (t in 1:nt) {
      logA_man[i, t] = log(A0[i] + dA_pos[i, t]);
    }
    man_rhs[i] = 10. * logA_man[i] - 6. * logn - 6. * logQ;
    amhg_rhs[i] = b[i] * (logQ - logQc) + logWc;
  }
}



model {
  
  // Priors
  logQ ~ normal(logQ_hat, logQ_sd);

  A0 ~ lognormal(logA0_hat, logA0_sd); // THINK ABOUT THIS MORE.
  logn ~ normal(logn_hat, logn_sd);

  b ~ normal(b_hat, b_sd);
  logWc ~ normal(logWc_hat, logWc_sd);
  logQc ~ normal(logQc_hat, logQc_sd);
  
  
  // Likelihood and observation error
  for (i in 1:nx) {
    // Wact[i] ~ normal(Wobs[i], Werr_sd);
    // Sact[i] ~ normal(Sobs[i], Serr_sd);
    // dAact[i] ~ normal(dAobs[i], dAerr_sd);
    
    man_lhs[i] ~ normal(man_rhs[i], 6 * sigma_man[i]);
    logW[i] ~ normal(amhg_rhs[i], sigma_amhg[i]);
    
    target += -logW[i];
    target += -logS[i];
  }
}
