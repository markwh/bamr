context("plotting functions")

test_that("plotting functions produce gg objects", {
  data("Po")
  attach(Po)
  
  bdpo <- bam_data(w = Po_w, s = Po_s, dA = Po_dA, Qhat = Po_QWBM)
  
  expect_is(plot(bdpo), "gg")
})