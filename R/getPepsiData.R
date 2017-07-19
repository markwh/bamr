getPepsiData <-
function(pepsiPiece) {
  pp <- pepsiPiece[[1]] %>% 
    setNames(attr(., "dimnames")[[1]]) %>% 
    `[`(, 1, 1)
  
  obslist <- pp[c("W", "Q", "H", "S", "dA")]
  
  # Make each observation array into a nice data.frame
  makeNice <- function(obselem) {
    obselem %>% 
      as.data.frame() %>% 
      setNames(1:ncol(.)) %>% 
      mutate(xs = 1:nrow(.)) %>% 
      gather(key = time, value = value, -xs)
      # melt(id.vars = "xs", variable.name = "time")
  }
  
  # data.frame containing all observations
  # browser()
  obsdf <- obslist %>% 
    lapply(makeNice) %>% 
    bind_rows(.id = "variable") %>% 
    spread(key = variable, value = value)
    # dcast(xs + time ~ variable)
  
  # data.frame containing non-observation info
  auxdf <- as.data.frame(pp$Ao) %>% 
    setNames("Ao") %>% 
    mutate(name = pp$name[1, 1],
           QWBM = pp$QWBM[1, 1],
           wc = pp$wc[1, 1],
           xs = 1:nrow(.))
  
  out <- obsdf %>% 
    left_join(auxdf, by = "xs") %>% 
    mutate(time = as.numeric(time))
}
