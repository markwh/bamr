# Datasets that bamr will store

# load("../SWOT/cache/Pepsi.RData")
load("../SWOT/cache/nc_r.RData")
Pepsi <- nc_r

Po_pepsi <- nc_r$Po

Po_w <- Po_pepsi$w

Po_s <- Po_pepsi$s

Po_dA <- Po_pepsi$dA

Po_QWBM <- Po_pepsi$QWBM[1]

Po <- list(Po_w = Po_w,
           Po_s = Po_s,
           Po_dA = Po_dA,
           Po_QWBM = Po_QWBM)


# Sacramento downstream, since Po is off limits ---------------------------

Sac_pepsi <- nc_r$SacramentoDownstream

Sac_w <- Sac_pepsi$w

Sac_s <- Sac_pepsi$s

Sac_dA <- Sac_pepsi$dA

Sac_QWBM <- Sac_pepsi$QWBM[1]

Sac_Qobs <- Sac_pepsi$Qobs

Sacramento <- list(Sac_w = Sac_w,
           Sac_s = Sac_s,
           Sac_dA = Sac_dA,
           Sac_QWBM = Sac_QWBM,
           Sac_Qobs = Sac_Qobs)

### Minimal testing datasets -------

xs_sub <- 1:2
t_sub <- 101:105

Po_w_sm <- Po_w[xs_sub, t_sub]
Po_s_sm <- Po_s[xs_sub, t_sub]
Po_dA_sm <- Po_dA[xs_sub, t_sub]
Po_QWBM_sm <- Po_QWBM

Po_sm <- list(Po_w_sm = Po_w_sm,
           Po_s_sm = Po_s_sm,
           Po_dA_sm = Po_dA_sm,
           Po_QWBM_sm = Po_QWBM_sm)


# Again with Sac downstream -----------------------------------------------

Sac_w_sm <- Sac_w[xs_sub, t_sub]
Sac_s_sm <- Sac_s[xs_sub, t_sub]
Sac_dA_sm <- Sac_dA[xs_sub, t_sub]
Sac_QWBM_sm <- Sac_QWBM[t_sub]
Sac_Qobs_sm <- Sac_Qobs

Sacramento_sm <- list(Sac_w_sm = Sac_w_sm,
              Sac_s_sm = Sac_s_sm,
              Sac_dA_sm = Sac_dA_sm,
              Sac_QWBM_sm = Sac_QWBM_sm,
              Sac_Qobs_sm = Sac_Qobs_sm)
