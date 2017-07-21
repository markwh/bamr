# Functions to plot bamr objects

#' @importFrom reshape2 melt
#' @import ggplot2
#' 
#' @export
plot.bamdata <- function(bamdata, piece = c("w", "s", "dA")) {
  piece <- match.arg(piece, several.ok = TRUE)
  
  if (is.null(bamdata$logS) || is.null(bamdata$dA)) {
    bamdata$logS <- bamdata$dA <- matrix(nr = bamdata$nt, nc = bamdata$nx)
    piece = "w"
  }
  
  w_df <- as.data.frame(exp(bamdata$logW))
  s_df <- as.data.frame(exp(bamdata$logS))
  dA_df <- as.data.frame(bamdata$dA)
  
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
    geom_line(aes(color = xs)) +
    scale_color_gradient() +
    facet_wrap(~variable, scales = "free_y")
  
  out
}