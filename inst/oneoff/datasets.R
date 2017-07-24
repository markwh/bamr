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
  as.matrix() %>% 
  t()

Po_s <- Po %>% 
  select(xs, time, S) %>% 
  spread(key = xs, value = S, convert = TRUE) %>% 
  select(-time) %>% 
  as.matrix() %>% 
  t()

Po_dA <- Po %>% 
  select(xs, time, dA) %>% 
  spread(key = xs, value = dA, convert = TRUE) %>% 
  select(-time) %>% 
  as.matrix() %>% 
  t()

Po_QWBM <- Po %>% 
  select(xs, time, QWBM) %>% 
  group_by(time) %>% 
  summarize(QWBM = median(QWBM)) %>% 
  `[[`("QWBM")

### Minimal testing datasets

xs_sub <- 1:2
t_sub <- 101:105

Po_w_sm <- Po_w[xs_sub, t_sub]
Po_s_sm <- Po_s[xs_sub, t_sub]
Po_dA_sm <- Po_dA[xs_sub, t_sub]
Po_QWBM_sm <- Po_QWBM[t_sub]