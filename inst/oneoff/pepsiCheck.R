# bamr.R
# Mark Hagemann
# 8/2/2017
# Estimate discharge using my new bamr package
# Mainly to be used as a test of bamr, see if it reproduces previous results

load("../SWOT/cache/Pepsi_bamr.RData")

# Pepsi -------------------------------------------------------------------

# Plots

slopeToPct <- function(bamdata) {
  bamdata$logS <- bamdata$logS - log(100)
  bamdata
}


# Manning
library(rstan)
modman <- stan_model("exec/manning.stan")
river <- "Po"
standat <- compose_bam_inputs(Pepsi_bamr[[river]])
# standat$logQ_hat <- standat$logQ_hat[1]
# standat$logA0_hat <- log(standat$logA0_hat)
samps <- sampling(object = modman, data = standat, chains = 2,
                  cores = 2, iter = 1000)
bam_hydrograph(samps)


# Try using old stan model
load("inst/po_pepsi.Rda")
mm2 <- stan_model("exec/man_old.stan")

samps2 <- sampling(object = mm2, data = po_pepsi, chains = 2, 
                   cores = 2, iter = 1000)
bam_hydrograph(samps2)

# That works. Now slowly morph it into the new version.

inboth <- intersect(names(po_pepsi), names(standat))
inboth
po_pepsi[[inboth[10]]]
standat[[inboth[10]]]

# All the same. Good.

diffs1 <- setdiff(po_pepsi %>% names, standat %>% names)
diffs2 <- setdiff(standat %>% names, po_pepsi %>% names)
diffs1
diffs2

# Try just removing bounds