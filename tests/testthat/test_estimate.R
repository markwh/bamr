context("BAM estimation")

test_that("BAM estimates return expected values", {
  data("Po_dA")
  data("Po_w")
  data("Po_s")
  data("Po_QWBM")
  
  
  expect_is(bda <- bam_data(w = Po_w, Qhat = Po_QWBM), "bamdata")
  expect_is(bdm <- bam_data(w = Po_w, s = Po_s, dA = Po_dA, Qhat = Po_QWBM),
            "bamdata")
  
  expect_is(est1 <- bam_estimate(bda, "amhg"), "stanfit")
  
})