context("data preparation")

test_that("data preparation produces correct output", {
  data("Sacramento")
  attach(Sacramento)
  
  bdpo <- bam_data(w = Sac_w, s = Sac_s, dA = Sac_dA, Qhat = Sac_QWBM)
  expect_is(bdpo, "bamdata")
  expect_is(bdpo$logW, "matrix")
  expect_is(bdpo$logS, "matrix")
  expect_is(bdpo$dA, "matrix")
  expect_is(bdpo$logQ_hat, "numeric")
  
  expect_equal(nrow(bdpo$logW), bdpo$nx)
  expect_equal(ncol(bdpo$logW), bdpo$nt)
  expect_equal(length(bdpo$logQ_hat), bdpo$nt)
  
  expect_is(bam_priors(bamdata = bdpo), "bampriors")
  
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
  expect_is(bpm <- bam_priors(bdm, variant = "manning"), "bampriors")
  expect_is(bpam <- bam_priors(bdm, variant = "manning_amhg"), "bampriors")
  
  expect_lt(length(bpm), length(bpam))
  expect_lt(length(bpa), length(bpam))
  
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
  
  expect_equal(sum(is.na(bdpo$logW)), 0)
  expect_equal(sum(is.na(bdpo$logS)), 0)
  expect_equal(sum(is.na(bdpo$dA)), 0)
  
  expect_equal(nrow(bdpo$logW), bdpo$nx)
  expect_equal(ncol(bdpo$logS), bdpo$nt)
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
  expect_lt(nrow(bdsm$logW), nrow(bdsac$logW))
  expect_lt(nrow(bdsm$logS), nrow(bdsac$logS))
  expect_lt(nrow(bdsm$dA), nrow(bdsac$dA))
  
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