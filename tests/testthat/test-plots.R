context("plotting functions")

test_that("plotting functions produce gg objects", {
  data("Sacramento")
  attach(Sacramento)
  
  bdpo <- bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM)
  
  expect_is(bam_plot(bdpo), "gg")
})