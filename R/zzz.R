.onLoad <- function(libname, pkgname) {
  modules <- paste0("stan_fit4", names(stanmodels), "_mod")
  # browser()
  # for (m in 1:length(modules)) {
  
  loadModule("stan_fit4man_mod")
  loadModule("stan_fit4amhg_mod")
  loadModule("stan_fit4man_amhg_mod")
  
  # for (m in 1:3) {
  #   print ("count ")
  #   print(modules[m])
  #   loadModule(modules[m], what = TRUE)
  #   print(modules[m])
  # }

}
