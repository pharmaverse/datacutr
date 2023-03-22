#' @title Imputes Partial Date/Time SDTMv Variables
#'
#' @description Imputes partial date/time SDTMv variables, as required by the datacut process.
#'
#' @param dsin Name of input SDTMv dataframe
#' @param varin Name of input SDTMv character date/time variable, which must be in ISO 8601
#' extended format (YYYY-MM-DDThh:mm:ss). The use of date/time intervals are not permitted.
#' @param varout Name of imputed output variable
#'
#' @return Returns the input SDTMv dataframe, with the addition of one extra variable (varout) in
#' POSIXct datetime format, which is the imputed version of varin.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' ex <- data.frame(
#'   USUBJID = rep(c("UXYZ123a"), 13),
#'   EXSTDTC = c(
#'     "", "2022", "2022-06", "2022-06-23", "2022-06-23T16", "2022-06-23T16:57",
#'     "2022-06-23T16:57:30", "2022-06-23T16:57:30.123", "2022-06-23T16:-:30",
#'     "2022-06-23T-:57:30", "2022-06--T16:57:30", "2022---23T16:57:30", "--06-23T16:57:30"
#'   )
#' )
#' ex_imputed <- impute_sdtm(dsin = ex, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC)
#'
impute_sdtm <- function(dsin, varin, varout) {
  # Handle input values for use in tidyverse
  varin <- assert_symbol(enexpr(varin))
  varout <- quo_name(assert_symbol(enexpr(varout)))

  # Check if dataframe exists and whether required variables exists within them
  assert_data_frame(dsin,
    required_vars = exprs(!!varin)
  )

  # Check that varin is in ISO 8601 format
  input_dtc <- pull(dsin, !!varin)
  valid_dtc <- is_valid_dtc(input_dtc)
  assert_that(all(valid_dtc),
    msg = "The varin variable contains datetimes in the incorrect format. All datetimes
    must be stored in ISO 8601 format."
  )

  # Split the input datetime (varin) into it's individual components
  # (years, months, days, hours, etc...)
  two <- "(\\d{2}|-?)"
  split_dtc <- str_match(input_dtc, paste0(
    "(\\d{4}|-?)-?",
    two,
    "-?",
    two,
    "T?",
    two,
    ":?",
    two,
    ":?",
    "(\\d{2}(\\.\\d{1,5})?)?"
  ))

  components <- c("year", "month", "day", "hour", "minute", "second")
  split_dtc_final <- vector("list", 6)
  names(split_dtc_final) <- components
  for (i in seq_along(components)) {
    split_dtc_final[[i]] <- split_dtc[, i + 1]
    split_dtc_final[[i]] <- if_else(split_dtc_final[[i]] %in% c("-", ""),
      NA_character_, split_dtc_final[[i]]
    )
  }

  # Define how each component should be imputed, if missing
  target <- vector("list", 6)
  names(target) <- components
  target["year"] <- "XYZ"
  target["month"] <- "01"
  target["day"] <- "01"
  target["hour"] <- "00"
  target["minute"] <- "00"
  target["second"] <- "00"

  # Perform imputation
  imputed_dtc_split <- vector("list", 6)
  names(imputed_dtc_split) <- components
  for (c in components) {
    imputed_dtc_split[[c]] <- if_else(is.na(split_dtc_final[[c]]),
      target[[c]], split_dtc_final[[c]]
    )
  }

  # Re-construct the datetime variable using our imputed components
  imputed_dtc_1 <- paste0(
    paste(imputed_dtc_split[["year"]], imputed_dtc_split[["month"]],
      imputed_dtc_split[["day"]],
      sep = "-"
    ), "T",
    paste(imputed_dtc_split[["hour"]], imputed_dtc_split[["minute"]],
      imputed_dtc_split[["second"]],
      sep = ":"
    )
  )

  # Set datetime to NA if the year is missing
  imputed_dtc_2 <-
    if_else(
      str_detect(imputed_dtc_1, "XYZ"),
      NA_character_,
      imputed_dtc_1
    )

  # Remove fractional seconds from the datetime
  imputed_dtc_final <- gsub("\\..*", "", imputed_dtc_2)

  # Add our new imputed datetime variable back to dsin + convert to datetime object
  out <- dsin %>%
    mutate(!!varout := ymd_hms(imputed_dtc_final))

  # Drop temporary variables
  out_final <- drop_temp_vars(dsin = out, drop_dcut_temp = FALSE)

  return(out_final)
}
