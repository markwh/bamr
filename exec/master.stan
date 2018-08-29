
data {
  
  // Options
  int<lower=0, upper=1> inc_m; // Include Manning? 0=no; 1=yes;
  int<lower=0, upper=1> inc_a; // Include AMHG? 0=no; 1=yes;
  int<lower=0, upper=1> meas_err; // 0=no; 1=yes;
  
  
  // Dimensions
  int<lower=0> nx; // number of cross-sections
  int<lower=0> nt; // number of observation times

  // Missing data
  int<lower=0> n_mis_w; // number of missing width data
  int<lower=0> n_mis_s; // number of missing slope data
  int<lower=0> n_mis_dA; // number of missing dA data
  int mis_w_inds[n_mis_w, 2]; // Indices (rows, columns) of missing width data
  int mis_s_inds[n_mis_s, 2]; // Indices (rows, columns) of missing slope data
  int mis_dA_inds[n_mis_dA, 2]; // Indices (rows, columns) of missing dA data
  
  // *Actual* data
  vector[nt] Wobs[nx]; // measured widths
  vector[nt] Sobs[nx]; // measured slopes
  vector[nt] dAobs[nx]; // measured partial area
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
  vector[nt] logW_obs[nx];
  vector[nt] logS_obs[nx];

  for (i in 1:nx) {
    dA_pos[i] = dAobs[i] - min(dAobs[i]); // make all dA positive
    logS_obs[i] = log(Sobs[i]);
    logW_obs[i] = log(Wobs[i]);
  }
}

parameters {
  vector<lower=lowerbound_logQ,upper=upperbound_logQ>[nt] logQ;
  real<lower=lowerbound_logn,upper=upperbound_logn> logn[inc_m];
  vector<lower=lowerbound_A0,upper=upperbound_A0>[nx] A0[inc_m];
  
  real<lower=lowerbound_logWc,upper=upperbound_logWc> logWc[inc_a];
  real<lower=lowerbound_logQc,upper=upperbound_logQc> logQc[inc_a];
  vector<lower=lowerbound_b,upper=upperbound_b>[nx] b[inc_a];
  
  vector<lower=0>[nt] Wact[nx * meas_err];
  vector<lower=0>[nt] Sact[nx * meas_err * inc_m];
  vector[nt] dAact[nx * meas_err * inc_m];
}


transformed parameters {

  vector[nt] man_lhs[nx * inc_m];
  vector[nt] logA_man[nx * inc_m]; // log area for Manning's equation
  vector[nt] man_rhs[nx * inc_m]; // RHS for Manning likelihood
  vector[nt] amhg_rhs[nx * inc_a]; // RHS for AMHG likelihood
  
  for (i in 1:nx) {
    if (inc_m) {
      logA_man[i] = log(A0[1][i] + (meas_err ? dAact[i] : dA_pos[i]));
      man_rhs[i] = 10. * logA_man[i] - 6. * logn[1] - 6. * logQ;
      if (meas_err)
        man_lhs[i] = 4. * log(Wact[i]) - 3. * log(Sact[i]); // LHS of manning equation
      else
        man_lhs[i] = 4. * log(Wobs[i]) - 3. * log(Sobs[i]); // LHS of manning equation
    }
    if (inc_a) {
      amhg_rhs[i] = b[1][i] * (logQ - logQc[1]) + logWc[1];
    }
  }
}

model {

  // Priors
  logQ ~ normal(logQ_hat, logQ_sd);
  
  if (inc_m) {
    A0[1] + dA_shift[1] ~ lognormal(logA0_hat, logA0_sd);
    logn[1] ~ normal(logn_hat, logn_sd);
  }
  if (inc_a) {
    b[1] ~ normal(b_hat, b_sd);
    logWc ~ normal(logWc_hat, logWc_sd);
    logQc ~ normal(logQc_hat, logQc_sd);
  }
  
  // Likelihood and observation error
  for (i in 1:nx) {
    if (inc_m) {
      man_lhs[i] ~ normal(man_rhs[i], 6 * sigma_man[i]);
    }
    
    if (meas_err) {
      Wact[i] ~ normal(Wobs[i], Werr_sd);
      
      if (inc_m) {
        Sact[i] ~ normal(Sobs[i], Serr_sd);
        dAact[i] ~ normal(dA_pos[i], dAerr_sd);
        target += -log(Wact[i]);
        target += -log(Sact[i]);      
      }
      if (inc_a) {
        Wact[i] ~ lognormal(amhg_rhs[i], sigma_amhg[i]);
      }
    }
    else {
      if (inc_a) {
        Wobs[i] ~ lognormal(amhg_rhs[i], sigma_amhg[i]);
      }
    }
  }
}
