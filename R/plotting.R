# Functions to plot bamr objects

#' @importFrom reshape2 melt
#' @import ggplot2
plot.bamdata <- function(bamdata, piece = c("w", "s", "dA"), log = FALSE) {
  piece <- match.arg(piece, several.ok = TRUE)
  w_df <- as.data.frame(exp(bamdata$logW))
  s_df <- as.data.frame(exp(bamdata$logS))
  dA_df <- as.data.frame(bamdata$dA)
  
  data_long <- dplyr::bind_rows(w = melt(w_df),
                                s = melt(s_df),
                                dA = melt(dA_df),
                                .id = "variable")
  
  plotdata <- data_long[data_long[["variable"]] %in% piece, ]
  
  out <- ggplot(plotdata, aes(x = time, y = value)) +
    geom_line(aes(linetype = xs, color = xs)) +
    scale_color_gradient() +
    facet_wrap(~variable)
  out
}