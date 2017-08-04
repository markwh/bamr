context("postprocessing and validation")

test_that("bam_validate produces expected output", {
  data("Sacramento_sm")
  attach(Sacramento_sm)
  
  bdm <- bam_data(w = Sac_w_sm, s = Sac_s_sm, dA = Sac_dA_sm, Qhat = Sac_QWBM_sm)
  est2 <- bam_estimate(bdm, "manning")
  
  expect_is(bval1 <- bam_validate(est2, qobs = Sac_Qobs_sm), "bamval")
  expect_identical(bval1$valdata, bam_valdata(est2, qobs = Sac_Qobs_sm))
  expect_is(bval1$stats, "numeric")
  expect_is(plot(bval1), "gg")
  
})