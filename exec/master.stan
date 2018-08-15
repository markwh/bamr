
data {
  
  // Options
  int<lower=1, upper=3> variant; // 1=Manning; 2=AMHG; 3=both
  int<lower=0, upper=1> meas_err; // 0=no; 1=yes;
  
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times

  
  // *Actual* data
  vector[nt] Wobs[nx]; // measured widths
  vector[nt] Sobs[nx]; // measured slopes
  vector[nt] dAobs[nx]; // measured area difference from base area
  vector[nx] dA_shift; // adjustment from min to median

  
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
  int inc_manning; // include Manning?
  int inc_amhg; // include AMHG?

  for (i in 1:nx) {
    dA_pos[i] = dAobs[i] - min(dAobs[i]); // make all dA positive
  }
  inc_manning = variant == 2 ? 0 : 1;
  inc_amhg = variant == 1 ? 0 : 1;
}

parameters {
  vector<lower=lowerbound_logQ,upper=upperbound_logQ>[nt] logQ;
  real<lower=lowerbound_logn,upper=upperbound_logn> logn[inc_manning];
  vector<lower=lowerbound_A0,upper=upperbound_A0>[nx] A0[inc_manning];
  
  real<lower=lowerbound_logWc,upper=upperbound_logWc> logWc[inc_amhg];
  real<lower=lowerbound_logQc,upper=upperbound_logQc> logQc[inc_amhg];
  vector<lower=lowerbound_b,upper=upperbound_b>[nx] b[inc_amhg];
  
  vector<lower=0>[nt] Wact[nx * meas_err];
  vector<lower=0>[nt] Sact[nx * meas_err * inc_manning];
  vector[nt] dAact[nx * meas_err * inc_manning];
}


transformed parameters {
  vector[nt] logW[nx];
  vector[nt] logS[nx * inc_manning];
  vector[nt] man_lhs[nx * inc_manning];
  vector[nt] logA_man[nx * inc_manning]; // log area for Manning's equation
  vector[nt] man_rhs[nx * inc_manning]; // RHS for Manning likelihood
  vector[nt] amhg_rhs[nx * inc_amhg]; // RHS for AMHG likelihood
  
  for (i in 1:nx) {
    logW[i] = meas_err ? log(Wact[i]) : log(Wobs[i]);
  }
  
  if (inc_manning) {
    for (i in 1:nx) {
      logS[i] = log(Sact[i]);
      man_lhs[i] = 4. * logW[i] - 3. * logS[i]; // LHS of manning equation

      logA_man[i] = log(A0[i] + dAact[i]);
      man_rhs[i] = 10. * logA_man[i] - 6. * logn[1] - 6. * logQ;
    }
  }
  if (inc_amhg) {
    for (i in 1:nx) {
      amhg_rhs[i] = b[1][i] * (logQ - logQc[1]) + logWc[1];
    }
  }
}



model {
  
  // Priors
  logQ ~ normal(logQ_hat, logQ_sd);
  
  if (inc_manning) {
    A0[1] + dA_shift ~ lognormal(logA0_hat, logA0_sd);
    logn[1] ~ normal(logn_hat, logn_sd);
  }
  if (inc_amhg) {
    b[1] ~ normal(b_hat, b_sd);
    logWc ~ normal(logWc_hat, logWc_sd);
    logQc ~ normal(logQc_hat, logQc_sd);
  }
  
  // Likelihood and observation error
  if (meas_err) {
    for (i in 1:nx) {
      Wact[i] ~ normal(Wobs[i], Werr_sd);
      Sact[i] ~ normal(Sobs[i], Serr_sd);
      dAact[i] ~ normal(dA_pos[i], dAerr_sd);
    }
  }
  if (inc_manning) {
    for (i in 1:nx) {
      man_lhs[i] ~ normal(man_rhs[i], 6 * sigma_man[i]);
      target += -logW[i];
      target += -logS[i];
    }
  }
  if (inc_amhg) {
    for (i in 1:nx) {
      logW[i] ~ normal(amhg_rhs[i], sigma_amhg[i]);
    }
  }
}
