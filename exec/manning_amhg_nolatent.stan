
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
  
  real<lower=lowerbound_logWc,upper=upperbound_logWc> logWc;
  real<lower=lowerbound_logQc,upper=upperbound_logQc> logQc;
  real<lower=lowerbound_b,upper=upperbound_b> b[nx];
  
}


transformed parameters {
  vector[nt] logW[nx];
  vector[nt] logS[nx];
  vector[nt] man_lhs[nx];
  vector[nt] logA_man[nx]; // log area for Manning's equation
  vector[nt] amhg_rhs[nx]; // RHS for AMHG likelihood
  real<lower=lowerbound_logQn,upper=upperbound_logQn> logQnbar;
  real A0_med[nx];
  
  vector[nt] logQ;
  
  
  logQ = logQtn - logn;
  logQnbar = logQbar + logn; 
  
  
  for (i in 1:nx) {
    logW[i] = log(Wobs[i]);
    logS[i] = log(Sobs[i]);
    A0_med[i] = A0[i] + dA_shift[i];
    
    man_lhs[i] = ((5. / 3. * logA_man[i]) - 
                  (2. / 3. * logW[i]) + 
                  (1. / 2. * logS[i]) - logQtn) ./ sigma_man[i];

    for (t in 1:nt) {
      logA_man[i, t] = log(A0[i] + dA_pos[i, t]);
    }
    amhg_rhs[i] = b[i] * (logQ - logQc) + logWc;
  }
}

model {
  // Likelihood and observation error
  for (i in 1:nx) {

    // man_lhs[i] ~ normal(logQtn, truesigma_man);
    man_lhs[i] ~ normal(0, truesigma_man);
    A0_med[i] ~ lognormal(logA0_hat, logA0_sd);
    
    logW[i] ~ normal(amhg_rhs[i], sigma_amhg[i]);
    
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

  logn ~ normal(logn_hat, logn_sd);

  b ~ normal(b_hat, b_sd);
  logWc ~ normal(logWc_hat, logWc_sd);
  logQc ~ normal(logQc_hat, logQc_sd);
}
