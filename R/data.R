#' Remote-sensing data from the Sacramento River
#' 
#' A dataset containing width, slope, partial cross-section area, and 
#' water-balance-model discharge for 367 consecutive days and 16 cross-sections 
#' in the Sacramento River, California.
#'
#' @format A list of length 4 with the following elements:
#' \describe{
#'   \item{Sac_w}{A matrix of widths, in meters}
#'   \item{Sac_s}{A matrix of slopes (unitless)}
#'   \item{Sac_dA}{A matrix of partial cross-sectional area (m^2)}
#'   \item{Sac_QWBM}{A vector of discharge estimates from a water-balance model (m^3/s)}   
#'   \item{Sac_Qobs}{A vector of observed discharge (for use in validation)}
#' }
"Sacramento"

#' A small version of the Sacramento dataset
#' 
#' A datatset with the same structure as Sacramento, but containing only a small subset of 
#' times and cross-sectoins, for fast testing and debugging of BAM code.
#'
#' @format A list of length 4 with the following elements:
#' \describe{
#'   \item{Sac_w_sm}{A matrix of widths, in meters}
#'   \item{Sac_s_sm}{A matrix of slopes (unitless)}
#'   \item{Sac_dA_sm}{A matrix of partial cross-sectional area (m^2)}
#'   \item{Sac_QWBM_sm}{A vector of discharge estimates from a water-balance model (m^3/s)}   
#'   \item{Sac_Qobs_sm}{A vector of observed discharge (for use in validation)}   
#' }
"Sacramento_sm"