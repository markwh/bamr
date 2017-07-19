minmax <-
function(logW)
  min(apply(logW_df, 2, max))
