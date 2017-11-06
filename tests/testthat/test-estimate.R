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