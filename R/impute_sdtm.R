#' @title Imputes Partial Dates in SDTM Variables
#'
#' @description Imputes partial dates in SDTM variables as part of the datacut process.
#'
#' @param dsin Name of input dataframe
#' @param varin Name of input SDTM variable
#' @param varout Name of imputed output variable
#'
#' @return Returns the input dataframe, with the additional of one extra variable (varout) which is the imputed version of varin.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' ex <- admiral.test::admiral_ex
#' ex <- select(ex, c(USUBJID, EXSTDTC))
#' temp_ex <- impute_sdtm(dsin=ex, varin=EXSTDTC, varout=DCUT_TEMP_EXSTDTC)

impute_sdtm <- function(dsin, varin, varout){

  # Handle input values for use in tidyverse
  varin <- enquo(varin)
  varout <- dplyr::quo_name(enquo(varout))

  # Impute character SDTM dates and convert to datetime object
  out <- dsin %>%
    mutate(TEMP_DTC = case_when(
      nchar(!!varin) == 0 ~ "",
      nchar(!!varin) == 4 ~ paste0(trimws(!!varin), "-01-01T00:00:00"),
      nchar(!!varin) == 7 ~ paste0(trimws(!!varin), "-01T00:00:00"),
      nchar(!!varin) == 10 ~ paste0(trimws(!!varin), "T00:00:00"),
      nchar(!!varin) == 13 ~ paste0(trimws(!!varin), ":00:00"),
      nchar(!!varin) == 16 ~ paste0(trimws(!!varin), ":00"),
      nchar(!!varin) == 19 ~ !!varin,
      TRUE ~ ""
    )) %>%
    mutate(!!varout := ymd_hms(TEMP_DTC))

  # Drop temporary variables
  out_final <- drop_temp_vars(dsin=out, drop_dcut_temp="FALSE")

  return(out_final)
}
