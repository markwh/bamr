context("BAM estimation")

test_that("BAM estimates return expected values", {
  data("Sacramento_sm")
  attach(Sacramento_sm)
  
  
  expect_is(bda <- bam_data(w = Sac_w_sm, Qhat = Sac_QWBM_sm), "bamdata")
  expect_is(bdm <- bam_data(w = Sac_w_sm, s = Sac_s_sm, dA = Sac_dA_sm, Qhat = Sac_QWBM_sm),
            "bamdata")
  
  expect_is(est1 <- bam_estimate(bda, "amhg"), c("stanfit"))
  expect_is(est2 <- bam_estimate(bdm, "manning"), c("stanfit"))
  
  
})