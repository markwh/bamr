context("measurement error reparameterization")

test_that("reparameterization returns correct object types", {
  sdW <- 10
  sdS <- 0.03 / 1000
  sddA <- 20
  
  wobs <- rlnorm(100, 5.2, 0.5) + rnorm(100, 0, sdW)
  sobs <- rlnorm(100, log(0.2 / 1000), 0.7) + rnorm(100, 0, sdS)
  dAobs <- rlnorm(100, 6.5, 0.5) + rnorm(100, 0, sddA)
  
  expect_is(wmoms <- ln_moms(wobs, sdW), "list")
  expect_is(smoms <- ln_moms(sobs, sdS), "list")
  expect_is(dAmoms <- ln_moms(dAobs, sddA), "list")
  
  expect_is(wmoms$mean, "numeric")
  expect_is(smoms$mean, "numeric")
  expect_is(smoms$sd, "numeric")

  
})


test_that("reparameterization bamr results are roughly equivalent", {
  data("Sacramento_sm")
  attach(Sacramento_sm)
  
  
  expect_is(bda <- bam_data(w = Sac_w_sm, Qhat = Sac_QWBM_sm), "bamdata")
  expect_is(bdm <- bam_data(w = Sac_w_sm, s = Sac_s_sm, dA = Sac_dA_sm, Qhat = Sac_QWBM_sm),
            "bamdata")
  # TODO
})