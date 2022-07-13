#' @title Imputes Partial Dates in DCUTDTC
#'
#' @description Imputes partial dates in DCUTDTC variable, created within the datacut process.
#'
#' @param dsin Name of input dataframe
#' @param varin Name of input datacut date variable
#' @param varout Name of imputed output variable
#'
#' @return Returns the input dataframe, with the additional of one extra variable (varout) which is the imputed version of varin.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' dcut <- data.frame(USUBJID=c("UXYZ123a", "UXYZ123b", "UXYZ123c", "UXYZ123d", "UXYZ123e"),
#'         DCUTDTC=c("2022-06-23", "2022-06-23T16", "2022-06-23T16:57", "2022-06-23T16:57:30",
#'                  "2022-06"))
#' dcut$DCUTDTC <- as.character(dcut$DCUTDTC)
#' dcut_final <- impute_dcutdtc(dsin=dcut, varin=DCUTDTC, varout=DCUTDT)

impute_dcutdtc <- function(dsin, varin, varout){

  # Handle input values for use in tidyverse
  varin <- enquo(varin)
  varout <- dplyr::quo_name(enquo(varout))

  # Impute character datacut date and convert to datetime object
  out <- dsin %>%
    mutate(TEMP_DTC = case_when(
      nchar(!!varin) == 10 ~ paste0(trimws(!!varin), "T23:59:59"),
      nchar(!!varin) == 13 ~ paste0(trimws(!!varin), ":59:59"),
      nchar(!!varin) == 16 ~ paste0(trimws(!!varin), ":59"),
      nchar(!!varin) == 19 ~ !!varin,
      TRUE ~ ""
    )) %>%
    mutate(!!varout := ymd_hms(TEMP_DTC))

  # Drop temporary variables
  out_final <- drop_temp_vars(dsin=out, drop_dcut_temp="FALSE")

  return(out_final)
}
