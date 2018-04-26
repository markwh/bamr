context("utility functions")

test_that("cv2sigma produces correct output", {
  smallcv <- runif(10, 0, 0.01)
  largecv <- runif(10, 0.9, 1)
  
  expect_is(cv2sigma(smallcv), "numeric")
  expect_is(cv2sigma(largecv), "numeric")
  
  expect_equal(cv2sigma(smallcv), smallcv, tolerance = 0.001)
  expect_true(all(cv2sigma(largecv) < largecv))
})