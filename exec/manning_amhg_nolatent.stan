
data {
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times


  // *Actual* data
  vector[nt] Wobs[nx]; // measured widths
  vector[nt] Sobs[nx]; // measured slopes
  vector[nt] dAobs[nx]; // measured area difference from base area
  real<lower=1> dA_shift[nx]; // median(dA) - min(dA) for each location
 
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
  real logQ_hat; // prior mean on logQ
  real logQc_hat; // prior mean on logQc
  real logWc_hat;
  real b_hat[nx]; // ADD CHECK ON THIS FOR DATA PREP
  real logA0_hat[nx];
  real logn_hat;

  real<lower=0> logQ_sd;
  real<lower=0> logQc_sd;
  real<lower=0> logWc_sd;
  real<lower=0> b_sd;
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
  real<lower=0> sigma_logQ;
  
  real<lower=lowerbound_logn,upper=upperbound_logn> logn;
  real<lower=lowerbound_A0,upper=upperbound_A0> A0[nx];
  
  real<lower=lowerbound_logQ,upper=upperbound_logQ> logQbar;
  
  real<lower=lowerbound_logWc,upper=upperbound_logWc> logWc;
  real<lower=lowerbound_logQc,upper=upperbound_logQc> logQc;
  real<lower=lowerbound_b,upper=upperbound_b> b[nx];
}


transformed parameters {
  vector[nt] man_rhs[nx];
  vector[nt] amhg_rhs[nx]; // RHS for AMHG likelihood

  for (i in 1:nx) {
    man_rhs[i] = logQ + logn - 5. / 3. * log(A0[i] + dA_pos[i]) +
                 2. / 3. * log(Wobs[i]);
    amhg_rhs[i] = b[i] * (logQ - logQc) + logWc;
  }
}

model {
  // Likelihood and observation error
  for (i in 1:nx) {

    log(Sobs[i]) ~ normal(man_rhs[i], sigma_man[i]); //already scaled by sigma_man
    A0[i] + dA_shift[i] ~ lognormal(logA0_hat, logA0_sd);
    
    log(Wobs[i]) ~ normal(amhg_rhs[i], sigma_amhg[i]);
  }
  
  // Priors
  logQ ~ normal(logQbar, sigma_logQ);
  logn ~ normal(logn_hat, logn_sd);
  
  logQbar ~ normal(logQ_hat, logQ_sd);
  sigma_logQ ~ normal(0, 1);

  b ~ normal(b_hat, b_sd);
  logWc ~ normal(logWc_hat, logWc_sd);
  logQc ~ normal(logQc_hat, logQc_sd);
}
