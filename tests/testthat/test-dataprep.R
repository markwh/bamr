context("data preparation")

test_that("data preparation produces correct output", {
  data("Sacramento")
  attach(Sacramento)
  
  bdpo <- bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM)
  expect_is(bdpo, "bamdata")
  expect_is(bdpo$Wobs, "matrix")
  expect_is(bdpo$Sobs, "matrix")
  expect_is(bdpo$dAobs, "matrix")
  expect_is(bdpo$logQ_hat, "numeric")
  expect_is(bdpo$omitTimes, "integer")
  
  expect_equal(nrow(bdpo$Wobs), bdpo$nx)
  expect_equal(ncol(bdpo$Wobs), bdpo$nt)
  expect_equal(length(bdpo$logQ_hat), 1)
  expect_equal(length(bdpo$omitTimes), 0)
  
  expect_is(bdpr <- bam_priors(bamdata = bdpo), "bampriors")
  expect_equal(length(bdpr$logQ_sd), 1)
  expect_is(bdpr$logQ_sd, "numeric")
  
  expect_is(bdpr$sigma_man, "matrix")
  expect_is(bdpr$sigma_amhg, "matrix")
  expect_equal(nrow(bdpr$sigma_man), bdpo$nx)
  expect_equal(ncol(bdpr$sigma_amhg), bdpo$nt)
  
  
  # manually specify logQ_sd as vector
  expect_is(bdpr <- bam_priors(bamdata = bdpo, logQ_sd = runif(1)), "bampriors")
  expect_equal(length(bdpr$logQ_sd), 1)
  expect_is(bdpr$logQ_sd, "numeric")
  
  expect_is(compose_bam_inputs(bdpo, bam_priors(bdpo)), "list")

})

test_that("different BAM variants yield proper behavior", {
  data("Sacramento")
  attach(Sacramento)
  
  expect_is(bda <- bam_data(w = Sac_w, Qhat = Sac_QWBM), "bamdata")
  expect_is(bdm <- bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM),
            "bamdata")
  
  expect_error(bam_priors(bda))
  expect_error(bam_priors(bda, variant = "manning"))
  expect_is(bpa <- bam_priors(bda, variant = "amhg"), "bampriors")
  # expect_is(bpm <- bam_priors(bdm, variant = "manning"), "bampriors")
  # expect_is(bpam <- bam_priors(bdm, variant = "manning_amhg"), "bampriors")
  
  # expect_lt(length(bpm), length(bpam))
  # expect_lt(length(bpa), length(bpam))
  
  expect_is(plot(bda), "gg")
})


test_that("NA values are removed or replaced", {
  data("Sacramento")
  attach(Sacramento)
  
  
  randna <- function(mat, n) {
    rws <- sample(1:nrow(mat), n)
    cls <- sample(1:ncol(mat), n)
    
    for (i in 1:n)
      mat[rws[i], cls[i]] <- NA
    mat
  }
  
  
  expect_message(bdpo <- bam_data(w = randna(Sac_w, 3), 
                   s = randna(Sac_s, 4), 
                   dA = randna(Sac_dA, 5),
                   Qhat = Sac_QWBM))
  
  expect_equal(sum(is.na(bdpo$Wobs)), 0)
  expect_equal(sum(is.na(bdpo$Sobs)), 0)
  expect_equal(sum(is.na(bdpo$dAobs)), 0)
  expect_equal(length(bdpo$logQ_hat), 1)
  
  expect_is(bdpo$omitTimes, "integer")
  expect_gte(length(bdpo$omitTimes), 5)
  
  expect_equal(nrow(bdpo$Wobs), bdpo$nx)
  expect_equal(ncol(bdpo$Sobs), bdpo$nt)
})


test_that("Parameter estimation yields sensible values", {
  data("Sacramento")
  attach(Sacramento)
  
  bdpo <- bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM)
  prpo <- bam_priors(bdpo)
})

test_that("subsetting of cross-sections works", {
  data("Sacramento")
  attach(Sacramento)
  
  bdsac <- bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM)
  
  nn <- 2
  bdsm <- sample_xs(bdsac, n = nn, seed = 8888)
  
  expect_is(bdsm, "bamdata")
  expect_lt(nrow(bdsm$Wobs), nrow(bdsac$Wobs))
  expect_lt(nrow(bdsm$Sobs), nrow(bdsac$Sobs))
  expect_lt(nrow(bdsm$dAobs), nrow(bdsac$dAobs))
  
  expect_true(identical(bdsm, sample_xs(bdsac, n = nn, seed = 8888)))
  expect_false(identical(bdsm, sample_xs(bdsac, n = nn, seed = 8889)))
  
  expect_true(identical(bdsac, sample_xs(bdsac, n = bdsac$nx, seed = 8888)))
  expect_true(identical(bdsac, sample_xs(bdsac, n = bdsac$nx + 10, seed = 8888)))
  
  expect_true(identical(bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM,
                                 max_xs = 2, seed = 8888), 
                        sample_xs(bdsac, n = 2, seed = 8888)))
  
  expect_equal(sample_xs(bdsac, n = 2)$nx, 2)

  nx1 <- bdsac$nx
  expect_equal(sample_xs(bdsac, n = 1000)$nx, nx1)
})


test_that("error reparameterization works as expected", {
  data("Sacramento")
  attach(Sacramento)
  
  bdsac <- bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM)
  
  expect_is((w_ln_sigsq <- ln_sigsq(bdsac$Wobs, 30)), "matrix")
  expect_equal(nrow(w_ln_sigsq), bdsac$nx)
  expect_equal(ncol(w_ln_sigsq), bdsac$nt)
  
  expect_equal(order(as.vector(w_ln_sigsq)), 
               order(as.vector(bdsac$Wobs), decreasing = TRUE))
  
  uniqSvec <- unique(round(as.vector(bdsac$Sobs), digits = 10))
  expect_equal(order(uniqSvec), 
               order(ln_sigsq(uniqSvec, 1e-4), decreasing = TRUE))
               
  
})