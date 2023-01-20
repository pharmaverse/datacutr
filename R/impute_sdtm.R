#' @title Imputes Partial Date/Time SDTMv Variables
#'
#' @description Imputes partial date/time SDTMv variables, as required by the datacut process.
#'
#' @param dsin Name of input SDTMv dataframe
#' @param varin Name of input SDTMv character date/time variable. Note that this date/time variable must be in ISO 8601
#' extended format (YYYY-MM-DDThh:mm:ss) and cannot include "fractions of seconds" or "time zones". Any missing components
#' must be represented by right truncation, rather than the use of additional hyphens. Date/time intervals are not accepted.
#' @param varout Name of imputed output variable
#'
#' @return Returns the input SDTMv dataframe, with the addition of one extra variable (varout) in POSIXct datetime format,
#' which is the imputed version of varin.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' ex <- data.frame(
#'   USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c", "UXYZ123d"),
#'   EXSTDTC = c("2022-06-23", "2022-06-23T16", "2022-06-23T16:57", "2022-06-23T16:57:30")
#' )
#' temp_ex <- impute_sdtm(dsin = ex, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC)

impute_sdtm <- function(dsin, varin, varout) {

  # Handle input values for use in tidyverse
  varin <- assert_symbol(enquo(varin))
  varout <- quo_name(assert_symbol(enquo(varout)))

  # Check if dataframe exists and whether required variables exists within them
  assert_data_frame(dsin,
    required_vars = quo_c(varin)
  )

  # Check that varin is in ISO 8601 format
  dtc <- pull(dsin, !!varin)
  valid_dtc <- is_valid_dtc(dtc)
  warn_if_invalid_dtc(dtc, valid_dtc)

  # Impute character SDTM dates and convert to datetime object
  out <- dsin %>%
    mutate(TEMP_DTC = case_when(
      nchar(as.character(!!varin)) == 4 ~ paste0(trimws(as.character(!!varin)), "-01-01T00:00:00"),
      nchar(as.character(!!varin)) == 7 ~ paste0(trimws(as.character(!!varin)), "-01T00:00:00"),
      nchar(as.character(!!varin)) == 10 ~ paste0(trimws(as.character(!!varin)), "T00:00:00"),
      nchar(as.character(!!varin)) == 13 ~ paste0(trimws(as.character(!!varin)), ":00:00"),
      nchar(as.character(!!varin)) == 16 ~ paste0(trimws(as.character(!!varin)), ":00"),
      nchar(as.character(!!varin)) == 19 ~ as.character(!!varin),
      TRUE ~ ""
    )) %>%
    mutate(!!varout := ymd_hms(TEMP_DTC))

  # Drop temporary variables
  out_final <- drop_temp_vars(dsin = out, drop_dcut_temp = FALSE)

  return(out_final)
}
