#' Remote-sensing data from the Po River
#' 
#' A dataset containing width, slope, partial cross-section area, and 
#' water-balance-model discharge for 367 consecutive days and 16 cross-sections 
#' in the Po River, Northern Italy.
#'
#' @format A list of length 4 with the following elements:
#' \describe{
#'   \item{Po_w}{A matrix of widths, in meters}
#'   \item{Po_s}{A matrix of slopes (unitless)}
#'   \item{Po_dA}{A matrix of partial cross-sectional area (m^2)}
#'   \item{Po_QWBM}{A vector of discharge estimates from a water-balance model (m^3/s)}   
#'   
#' }
"Po"

#' A small version of the Po dataset
#' 
#' A datatset with the same structure as Po, but containing only a small subset of 
#' times and cross-sectoins, for fast testing and debugging of BAM code.
#'
#' @format A list of length 4 with the following elements:
#' \describe{
#'   \item{Po_w_sm}{A matrix of widths, in meters}
#'   \item{Po_s_sm}{A matrix of slopes (unitless)}
#'   \item{Po_dA_sm}{A matrix of partial cross-sectional area (m^2)}
#'   \item{Po_QWBM_sm}{A vector of discharge estimates from a water-balance model (m^3/s)}   
#'   
#' }
"Po_sm"