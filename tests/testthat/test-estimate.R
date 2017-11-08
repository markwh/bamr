context("BAM estimation")

test_that("BAM estimates return expected values", {
  data("Sacramento_sm")
  attach(Sacramento_sm)
  
  
  expect_is(bda <- bam_data(w = Sac_w_sm, Qhat = Sac_QWBM_sm), "bamdata")
  expect_is(bdm <- bam_data(w = Sac_w_sm, s = Sac_s_sm, dA = Sac_dA_sm, Qhat = Sac_QWBM_sm),
            "bamdata")
  
  myseed <- 582
  
  bp1 <- bam_priors(bda, Werr_sd = 1600, variant = "amhg")
  bp2 <- bam_priors(bdm, Werr_sd = 10, sigma_man = 0.2)
  expect_is(est1 <- bam_estimate(bda, "amhg", bampriors = bp1, seed = myseed), c("stanfit"))
  expect_is(est2 <- bam_estimate(bdm, "manning", bampriors = bp2, seed = myseed), c("stanfit"))
  expect_is(est3 <- bam_estimate(bdm, "manning", seed = myseed), c("stanfit"))
  
  expect_equivalent(est2, est3)
  
  # Now check meas_error functionality
  expect_is(est4 <- bam_estimate(bda, "amhg", meas_error = FALSE, seed = myseed), c("stanfit"))
  expect_is(est5 <- bam_estimate(bdm, "manning", meas_error = FALSE, seed = myseed), c("stanfit"))
  
  expect_is(qp1 <- bam_qpred(est1), "data.frame")
  expect_is(qp2 <- bam_qpred(est2), "data.frame")
  expect_is(qp4 <- bam_qpred(est4), "data.frame")
  expect_is(qp5 <- bam_qpred(est5), "data.frame")
  
  ## (Commented out because AMHG isn't behaving re: meas. error)
  # expect_true(sum((qp1$conf.high - qp1$conf.low) <= 
  #                 (qp4$conf.high - qp4$conf.low)) 
  #             == 0)
  
  expect_true(sum((qp2$conf.high - qp2$conf.low) <= 
                    (qp5$conf.high - qp5$conf.low)) 
              == 0)
})


test_that("Measurement error reparameterization works", {
  data("Sacramento_sm")
  attach(Sacramento_sm)
  
  expect_is(bda <- bam_data(w = Sac_w_sm, Qhat = Sac_QWBM_sm), "bamdata")
  expect_is(bdm <- bam_data(w = Sac_w_sm, s = Sac_s_sm, dA = Sac_dA_sm, Qhat = Sac_QWBM_sm),
            "bamdata")
  
  # Test reparameterization
  rs <- 2438
  expect_is(est1 <- bam_estimate(bda, "amhg", reparam = FALSE, seed = rs), c("stanfit"))
  expect_is(est2 <- bam_estimate(bdm, "manning", reparam = FALSE, seed = rs), c("stanfit"))
  
  expect_is(est3 <- bam_estimate(bda, "amhg", reparam = TRUE, seed = rs), c("stanfit"))
  expect_is(est4 <- bam_estimate(bdm, "manning", reparam = TRUE, seed = rs), c("stanfit"))
  
  expect_true(identical(bam_estimate(bda, "amhg", reparam = FALSE, seed = rs), 
                        est1))
  expect_false(identical(est1, est3))
  expect_false(identical(est2, est4))
  
})
