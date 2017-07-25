
data {
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times
  
  
  // *Actual* data
  vector[nt] logW[nx]; // measured widths
  vector[nt] logS[nx]; // measured slopes
  vector[nt] dA[nx]; // measured area difference from base area


  // Hard bounds on parameters
  real<lower=0>lowerbound_logQ;
  real<lower=0>upperbound_logQ;
  
  real lowerbound_A0; // These must be scalars, unfortunately. 
  real upperbound_A0;
  real lowerbound_logn;
  real upperbound_logn;
  
  
  // *Known* likelihood parameters
  real<lower=0> sigma_man;
  
  
  // Hyperparameters
  vector[nt] logQ_hat;
  real logA0_hat[nx];
  real logn_hat;
  
  real<lower=0> logQ_sd;
  real<lower=0> logA0_sd;
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
  real<lower=lowerbound_A0,upper=upperbound_A0> A0[nx];
}

transformed parameters {
  vector[nt] man_rhs[nx]; // RHS for Manning likelihood
  vector[nt] logA_man[nx]; // log area for Manning's equation
  
  for (i in 1:nx) {
    for (t in 1:nt) {
      logA_man[i, t] = log(A0[i] + dA_pos[i, t]);
    }
    man_rhs[i] = 10. * logA_man[i] - 6. * logn - 6. * logQ;
  }
}

model {
  
  // Priors
  logQ ~ normal(logQ_hat, logQ_sd);
  
  A0 ~ lognormal(logA0_hat, logA0_sd);
  logn ~ normal(logn_hat, logn_sd); // has median of 0.03, 95% CI of (0.006, 0.156)
  
  // Likelihood
  for (i in 1:nx) {
    man_lhs[i] ~ normal(man_rhs[i], sigma_man); //cv2sigma(0.05));
  }
}
