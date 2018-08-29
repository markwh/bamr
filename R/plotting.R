# Functions to plot bamr objects

#' Plot a bamdata object
#' 
#' @importFrom reshape2 melt
#' @importFrom stats setNames
#' @import ggplot2
#' 
#' @export
plot.bamdata <- function(bamdata, piece = c("w", "s", "dA")) {
  piece <- match.arg(piece, several.ok = TRUE)
  
  if (is.null(bamdata$Sobs) || is.null(bamdata$dAobs)) {
    bamdata$Sobs <- bamdata$dAobs <- matrix(nrow = bamdata$nx, ncol = bamdata$nt)
    piece <- "w"
  }
  nx <- bamdata$nx
  w_df <- as.data.frame(t(bamdata$Wobs)) %>% 
    setNames(1:nx)
  s_df <- as.data.frame(t(bamdata$Sobs)) %>% 
    setNames(1:nx)
  dA_df <- as.data.frame(t(bamdata$dAobs)) %>% 
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
  qpred <- lapply(1:nchains, function(x) bam_qpred(fit, x)) %>% 
    setNames(paste0("chain", 1:nchains)) %>% 
    dplyr::bind_rows(.id = "series") %>% 
    reshape2::melt(id.vars = c("series", "time"),
                   measure.vars = c("mean", "conf.low", "conf.high"),
                   variable.name = "stat", value.name = "flow") %>% 
    mutate(stat = as.character(stat))

  out <- ggplot(qpred, aes(x = time, y = flow, color = stat)) +
    geom_line(aes(linetype = series))
  
  if (!is.null(qobs)) {
    obsdf <- data.frame(time = 1:max(qpred$time),
                        flow = qobs, series = "observed", stat = NA)
    out <- out + 
      geom_line(aes(x = time, y = flow, linetype = series), data = obsdf) +
      scale_linetype_manual(values = c(2:(nchains + 1), 1))
  }

  
  out
}

#' Plot a dataset that is formatted in space-down, time-across format
#' 
plot_DAWG <- function(dawgmat) {
  dawgdf <- as.data.frame(t(dawgmat)) %>% 
    setNames(1:nrow(dawgmat)) %>% 
    mutate(time = 1:ncol(dawgmat)) %>% 
    melt(id.vars = "time", variable.name = "xs") %>% 
    mutate(xs = as.numeric(xs))
  
  ggplot(dawgdf, aes(x = time, y = xs, group = xs)) +
    geom_line(aes(color = xs, group = xs)) +
    scale_color_gradient()
}