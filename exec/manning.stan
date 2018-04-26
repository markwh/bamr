
data {
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times
  
  
  // *Actual* data
  vector[nt] Wobs[nx]; // measured widths
  vector[nt] Sobs[nx]; // measured slopes
  vector[nt] dAobs[nx]; // measured area difference from base area
  
  real<lower=0> Werr_sd;
  real<lower=0> Serr_sd;
  real<lower=0> dAerr_sd;


  // Hard bounds on parameters
  real<lower=0>lowerbound_logQ;
  real<lower=0>upperbound_logQ;
  
  real lowerbound_A0; // These must be scalars, unfortunately. 
  real upperbound_A0;
  real lowerbound_logn;
  real upperbound_logn;
  
  
  // *Known* likelihood parameters
  vector<lower=0>[nt] sigma_man[nx];
  
  
  // Hyperparameters
  vector[nt] logQ_hat;
  real logA0_hat[nx];
  real logn_hat;
  
  vector<lower=0>[nt] logQ_sd;
  real<lower=0> logA0_sd;
  real<lower=0> logn_sd;
}

transformed data {
  vector[nt] dA_pos[nx];

  for (i in 1:nx) {
    dA_pos[i] = dAobs[i] - min(dAobs[i]); // make all dA positive
  }
}

parameters {
  vector<lower=lowerbound_logQ,upper=upperbound_logQ>[nt] logQ;
  real<lower=lowerbound_logn,upper=upperbound_logn> logn;
  real<lower=lowerbound_A0,upper=upperbound_A0> A0[nx];
  
  vector<lower=0>[nt] Wact[nx];
  vector<lower=0>[nt] Sact[nx];
  vector[nt] dAact[nx];
}

transformed parameters {
  vector[nt] logW[nx];
  vector[nt] logS[nx];
  vector[nt] man_lhs[nx];
  vector[nt] logA_man[nx]; // log area for Manning's equation
  vector[nt] man_rhs[nx]; // RHS for Manning likelihood
  
  for (i in 1:nx) {
    logW[i] = log(Wact[i]);
    logS[i] = log(Sact[i]);
    
    man_lhs[i] = 4. * logW[i] - 3. * logS[i]; // LHS of manning equation
    
    for (t in 1:nt) {
      logA_man[i, t] = log(A0[i] + dAact[i, t]);
    }
    man_rhs[i] = 10. * logA_man[i] - 6. * logn - 6. * logQ;
  }
}

model {
  
  // Priors
  logQ ~ normal(logQ_hat, logQ_sd);
  
  A0 ~ lognormal(logA0_hat, logA0_sd);
  logn ~ normal(logn_hat, logn_sd); // has median of 0.03, 95% CI of (0.006, 0.156)
  
  // Likelihood and observation error
  for (i in 1:nx) {
    Wact[i] ~ normal(Wobs[i], Werr_sd);
    Sact[i] ~ normal(Sobs[i], Serr_sd);
    dAact[i] ~ normal(dA_pos[i], dAerr_sd);
    
    man_lhs[i] ~ normal(man_rhs[i], 6 * sigma_man[i]); //cv2sigma(0.05));
    
    target += -logW[i];
    target += -logS[i];
  }
}
