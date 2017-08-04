context("postprocessing and validation")

test_that("bam postprocessing and validation work as expected", {
  data("Sacramento_sm")
  attach(Sacramento_sm)
  
  bdm <- bam_data(w = Sac_w_sm, s = Sac_s_sm, dA = Sac_dA_sm, Qhat = Sac_QWBM_sm)
  est2 <- bam_estimate(bdm, "manning")
  
  expect_is(bqp <- bam_qpred(est2, conf.level = 0.95), "data.frame")
  expect_is(bqp2 <- bam_qpred(est2, conf.level = 0.90), "data.frame")
  expect_equal(nrow(bqp), bdm$nt)

  expect_true(all(bqp$conf.high > bqp2$conf.high))
  expect_true(all(bqp$conf.low < bqp2$conf.low))
  
  expect_error(bam_qpred(est2, conf.level = 1.05))
  expect_error(bam_qpred(est2, conf.level = -0.05))
  
  
  
  expect_is(bval1 <- bam_validate(est2, qobs = Sac_Qobs_sm), "bamval")
  expect_identical(bval1$valdata, bam_valdata(est2, qobs = Sac_Qobs_sm))
  expect_is(bval1$stats, "numeric")
  expect_is(plot(bval1), "gg")
  
})