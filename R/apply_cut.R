#' @title Applies the datacut
#'
#' @description Applies the datacut based on the flagging variable created by pt_cut and sdtm_cut functions.
#'
#' @param dsin Name of input dataframe
#' @param dcutvar Name of input datacut flagging variable (created by pt_cut and sdtm_cut functions)
#'
#' @return Returns the input dataframe, excluding any rows in which the dcutvar is flagged as "Y". Also removes any
#' variables with the "DCUT_TEMP" prefix.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples

apply_cut <- function(dsin, dcutvar){

  # Handle input values for use in tidyverse
  dcutvar <- enquo(dcutvar)

  # Remove any rows where datacut flagging variable (dcutvar) is "Y"
  out <- dsin %>%
    filter(is.na(!!dcutvar) | !!dcutvar != "Y")

  # Drop temporary variables
  out_final <- drop_temp_vars(dsin=out, drop_dcut_temp="TRUE")

  return(out_final)
}

