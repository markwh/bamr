maxmin <-
function(logW) {
  max(apply(logW_df, 2, min))
}
