context("BAM estimation")

test_that("BAM estimates return expected values", {
  data("Po_sm")
  attach(Po_sm)
  
  
  expect_is(bda <- bam_data(w = Po_w_sm, Qhat = Po_QWBM_sm), "bamdata")
  expect_is(bdm <- bam_data(w = Po_w_sm, s = Po_s_sm, dA = Po_dA_sm, Qhat = Po_QWBM_sm),
            "bamdata")
  
  expect_is(est1 <- bam_estimate(bda, "amhg"), c("stanfit"))

  expect_is(est2 <- bam_estimate(bdm, "manning"), c("stanfit"))
})