guessAo <-
function(W, S, Q, dA) {
  Ao_hat = (exp(log(Q) -  
                  3.5 + # ln (manning's n guess)
                  2. / 3. * log(W) - 
                  1. / 2. * log(S)))^(3. / 5.) - log(dA)
  out <- max(Ao_hat, W)
}
