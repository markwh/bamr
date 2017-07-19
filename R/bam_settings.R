bam_settings <-
function (..., .__defaults = FALSE, .__reset = FALSE) 
{
    L <- list(...)
    if (.__defaults) 
        return(.defaults)
    if (.__reset) {
        .op <<- .defaults
        return(invisible(.op))
    }
    if (length(L) == 0) 
        return(.op)
    vars <- names(L)
    if (!is.null(vars) && !any(vars == "")) {
        if (!all(vars %in% names(.defaults))) {
            ii <- vars %in% names(.defaults)
            warning(sprintf("Ignoring options not defined in manager: %s", 
                paste(vars[!ii], collapse = ", ")))
            vars <- vars[ii]
            L <- L[ii]
        }
        ii <- vars %in% names(.defaults)
        for (v in vars[ii]) .al[[v]](L[[v]])
        .op[vars] <<- L
        return(invisible(.op))
    }
    if (is.null(vars)) {
        vars <- unlist(L)
        return(if (length(vars) == 1) .op[[vars]] else .op[vars])
    }
    stop("Illegal arguments")
}
