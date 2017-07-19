context("plotting functions")

test_that("plotting functions produce gg objects", {
  data("Po_dA")
  data("Po_w")
  data("Po_s")
  
  bdpo <- bam_data(w = Po_w, s = Po_s, dA = Po_dA)
  
  expect_is(plot(bdpo), "gg")
})