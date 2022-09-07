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
#' dcut <- data.frame(USUBJID=c("UXYZ123a", "UXYZ123b", "UXYZ123c", "UXYZ123d"),
#'         DCUTDTC=c("2022-06-23", "2022-06-23T16", "2022-06-23T16:57", "2022-06-23T16:57:30"))
#' dcut_final <- impute_dcutdtc(dsin=dcut, varin=DCUTDTC, varout=DCUTDT)

impute_dcutdtc <- function(dsin, varin, varout){

  # Assertion to check that all DCUTDTC values are at least a complete date
  assert_that(all(nchar(as.character(dsin$DCUTDTC)) %in% c(10, 13, 16, 19)))

  # Handle input values for use in tidyverse
  varin <- enquo(varin)
  varout <- quo_name(enquo(varout))

  # Impute character datacut date and convert to datetime object
  out <- dsin %>%
    mutate(TEMP_DTC = case_when(
      nchar(as.character(!!varin)) == 10 ~ paste0(trimws(as.character(!!varin)), "T23:59:59"),
      nchar(as.character(!!varin)) == 13 ~ paste0(trimws(as.character(!!varin)), ":59:59"),
      nchar(as.character(!!varin)) == 16 ~ paste0(trimws(as.character(!!varin)), ":59"),
      nchar(as.character(!!varin)) == 19 ~ as.character(!!varin),
      TRUE ~ ""
    )) %>%
    mutate(!!varout := ymd_hms(TEMP_DTC))

  # Drop temporary variables
  out_final <- drop_temp_vars(dsin=out, drop_dcut_temp="FALSE")

  return(out_final)
}
