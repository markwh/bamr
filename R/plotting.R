# Functions to plot bamr objects

#' @importFrom reshape2 melt
#' @import ggplot2
#' 
#' @export
plot.bamdata <- function(bamdata, piece = c("w", "s", "dA")) {
  piece <- match.arg(piece, several.ok = TRUE)
  
  if (is.null(bamdata$logS) || is.null(bamdata$dA)) {
    bamdata$logS <- bamdata$dA <- matrix(nr = bamdata$nx, nc = bamdata$nt)
    piece = "w"
  }
  
  w_df <- as.data.frame(exp(t(bamdata$logW))) %>% 
    setNames(1:nx)
  s_df <- as.data.frame(exp(t(bamdata$logS))) %>% 
    setNames(1:nx)
  dA_df <- as.data.frame(t(bamdata$dA)) %>% 
    setNames(1:nx)
  # browser()
  w_df$time <- s_df$time <- dA_df$time <- 1:bamdata$nt
  # browser()
  sw <- suppressWarnings
  data_long <- sw(dplyr::bind_rows(w = melt(w_df, id.vars = "time",
                                            variable.name = "xs"),
                                s = melt(s_df, id.vars = "time",
                                         variable.name = "xs"),
                                dA = melt(dA_df, id.vars = "time",
                                          variable.name = "xs"),
                                .id = "variable"))
  data_long$xs <- as.numeric(as.character(data_long$xs))
  plotdata <- data_long[data_long[["variable"]] %in% piece, ]
  
  out <- ggplot(plotdata, aes(x = time, y = value)) +
    geom_line(aes(color = xs, group = xs)) +
    scale_color_gradient() +
    facet_wrap(~variable, scales = "free_y", ncol = 1)
  
  out
}

#' Plot flow time series from BAM inference
#' 
#' @param fit A stanfit object, as returned from \code{bam_estimate()}
#' @param qobs An optional vector giving observed flow for comparison
#' @importFrom dplyr "%>%"
#' @export

bam_hydrograph <- function(fit, qobs = NULL) {
  
  nchains <- length(fit@stan_args)
  qpred <- lapply(1:nchains, function(x) getQstats(fit, x)) %>% 
    setNames(paste0("chain", 1:nchains)) %>% 
    dplyr::bind_rows(.id = "series")
  
  out <- ggplot(qpred, aes(x = time, y = flow, color = stat)) +
    geom_line(aes(linetype = series))
  out
}