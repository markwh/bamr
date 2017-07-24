context("BAM estimation")

test_that("BAM estimates return expected values", {
  data("Po_dA_sm")
  data("Po_w_sm")
  data("Po_s_sm")
  data("Po_QWBM_sm")
  
  
  expect_is(bda <- bam_data(w = Po_w_sm, Qhat = Po_QWBM_sm), "bamdata")
  expect_is(bdm <- bam_data(w = Po_w_sm, s = Po_s_sm, dA = Po_dA_sm, Qhat = Po_QWBM_sm),
            "bamdata")
  
  expect_is(est1 <- bam_estimate(bda, "amhg"), c("bamfit","stanfit"))

  expect_is(est2 <- bam_estimate(bdm, "manning"), c("bamfit", "stanfit"))
})