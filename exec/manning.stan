
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

  for (i in 1:nx) {
    dA_pos[i] = dAobs[i] - min(dAobs[i]); // make all dA positive
  }
  lowerbound_logQn = lowerbound_logQ + lowerbound_logn;
  upperbound_logQn = upperbound_logQ + upperbound_logn;
}

parameters {
  vector<lower=lowerbound_logQn,upper=upperbound_logQn>[nt] logQtn;
  real<lower=0> sigma_logQ;
  
  real<lower=lowerbound_logn,upper=upperbound_logn> logn;
  real<lower=lowerbound_A0,upper=upperbound_A0> A0[nx];

  real<lower=lowerbound_logQ,upper=upperbound_logQ> logQnbar;
  
  vector<lower=0>[nt] Wact[nx];
  vector<lower=0>[nt] Sact[nx];
  vector[nt] dAact[nx];
}

transformed parameters {
  vector[nt] logWSpart[nx];
  vector[nt] man_rhs[nx];
  
  for (i in 1:nx) {
    logWSpart[i] = 1. / 2. * log(Sact[i]) - 2. / 3. * log(Wact[i]);
    man_rhs[i] = logQtn - 5. / 3. * log(A0[i] + dA_pos[i]);
  }
}

model {
  // Likelihood and observation error
  for (i in 1:nx) {
    Wobs[i] ~ normal(Wact[i], Werr_sd);
    Sobs[i] ~ normal(Sact[i], Serr_sd);
    dA_pos[i] ~ normal(dAact[i], dAerr_sd);
    
    logWSpart[i] ~ normal(man_rhs[i], sigma_man[i]); // already scaled by sigma_man
    A0[i] + dA_shift[i] ~ lognormal(logA0_hat, logA0_sd);
    
    // Jacobian adjustments
    target += -log(Wact[i]);
    target += -log(Sact[i]);
  }

  // Priors
  logQtn ~ normal(logQnbar, sigma_logQ);
  logn ~ normal(logn_hat, logn_sd);
  
  logQnbar ~ normal(logQ_hat + logn, logQ_sd);
  sigma_logQ ~ normal(0, 1);
}

generated quantities {
  real logQbar;
  vector[nt] logQ;
  
  logQbar = logQnbar - logn;
  logQ = logQtn - logn;
}
