# Datasets that bamr will store

library(dplyr)
library(tidyr)
load("../SWOT/cache/Pepsi.RData")

Po <- Pepsi %>% 
  filter(name == "Po") %>% 
  transmute(xs, time, dA, H, S, W, QWBM, Q, A0 = Ao)

Po_w <- Po %>% 
  select(xs, time, W) %>% 
  spread(key = xs, value = W, convert = TRUE) %>% 
  select(-time) %>% 
  as.matrix()

Po_s <- Po %>% 
  select(xs, time, S) %>% 
  spread(key = xs, value = S, convert = TRUE) %>% 
  select(-time) %>% 
  as.matrix()

Po_dA <- Po %>% 
  select(xs, time, dA) %>% 
  spread(key = xs, value = dA, convert = TRUE) %>% 
  select(-time) %>% 
  as.matrix()

Po_QWBM <- Po %>% 
  select(xs, time, QWBM) %>% 
  group_by(time) %>% 
  summarize(QWBM = median(QWBM)) %>% 
  `[[`("QWBM")