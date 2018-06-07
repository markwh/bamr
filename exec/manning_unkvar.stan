
data {
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times
  
  
  // *Actual* data
  vector[nt] Wobs[nx]; // measured widths
  vector[nt] Sobs[nx]; // measured slopes
  vector[nt] dAobs[nx]; // measured area difference from base area
  real<lower=1> dA_shift[nx]; // median(dA) - min(dA) for each location
    
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
  real logQ_hat;
  real logA0_hat[nx];
  real logn_hat;
  
  real<lower=0> logQ_sd;
  real<lower=0> logA0_sd;
  real<lower=0> logn_sd;
}

transformed data {
  vector[nt] dA_pos[nx];
  real lowerbound_logQn;
  real upperbound_logQn;

  lowerbound_logQn = lowerbound_logQ + lowerbound_logn;
  upperbound_logQn = upperbound_logQ + upperbound_logn;
  for (i in 1:nx) {
    dA_pos[i] = dAobs[i] - min(dAobs[i]); // make all dA positive
  }
}

parameters {
  vector<lower=lowerbound_logQn,upper=upperbound_logQn>[nt] logQtn;
  real<lower=0> truesigma_man;
  real<lower=0> sigma_logQ;
  
  real<lower=lowerbound_logn,upper=upperbound_logn> logn;
  real<lower=lowerbound_A0,upper=upperbound_A0> A0[nx];

  real<lower=lowerbound_logQ,upper=upperbound_logQ> logQbar;
  
  vector<lower=0>[nt] Wact[nx];
  vector<lower=0>[nt] Sact[nx];
  vector[nt] dAact[nx];
}

transformed parameters {
  vector[nt] logW[nx];
  vector[nt] logS[nx];
  vector[nt] man_lhs[nx];
  vector[nt] logA_man[nx]; // log area for Manning's equation
  real<lower=lowerbound_logQn,upper=upperbound_logQn> logQnbar;
  real A0_med[nx];
  
  logQnbar = logQbar + logn; 
  
  
  for (i in 1:nx) {
    logW[i] = log(Wact[i]);
    logS[i] = log(Sact[i]);
    A0_med[i] = A0[i] + dA_shift[i];
    
    for (t in 1:nt) {
      logA_man[i, t] = log(A0[i] + dAact[i, t]);
    }
    
    man_lhs[i] = ((5. / 3. * logA_man[i]) - 
                  (2. / 3. * logW[i]) + 
                  (1. / 2. * logS[i]) - logQtn) ./ sigma_man[i];
  }
}

model {
  // Likelihood and observation error
  for (i in 1:nx) {
    Wact[i] ~ normal(Wobs[i], Werr_sd);
    Sact[i] ~ normal(Sobs[i], Serr_sd);
    dAact[i] ~ normal(dA_pos[i], dAerr_sd);
    
    // man_lhs[i] ~ normal(logQtn, truesigma_man);
    man_lhs[i] ~ normal(0, truesigma_man);
    A0_med[i] ~ lognormal(logA0_hat, logA0_sd);
    
    // Jacobian adjustments
    target += -(log(A0[i] + dA_pos[i]));
    target += -logW[i];
    target += -logS[i];
  }

  
  // Priors
  logQtn ~ normal(logQnbar, sigma_logQ);
  sigma_logQ ~ normal(0, 1);
  truesigma_man ~ normal(0, 1);
  
  logQnbar ~ normal(logQ_hat + logn, logQ_sd);
  logQbar ~ normal(logQ_hat, logQ_sd);
  logn ~ normal(logn_hat, logn_sd); // has median of 0.03, 95% CI of (0.006, 0.156)

}



generated quantities {
  // vector<lower=lowerbound_logQ,upper=upperbound_logQ>[nt] logQ;
  vector[nt] logQ;
  logQ = logQtn - logn;
}