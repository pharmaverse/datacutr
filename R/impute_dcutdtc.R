#' @title Imputes Partial Date/Time Data Cutoff Variable (DCUTDTC)
#'
#' @description Imputes partial date/time data cutoff variable (DCUTDTC), as required by the
#' datacut process.
#'
#' @param dsin Name of input data cut dataframe (i.e; DCUT)
#' @param varin Name of input data cutoff variable (i.e; DCUTDTC) which must be in ISO 8601
#' extended format (YYYY-MM-DDThh:mm:ss). All values of the data cutoff variable must be at
#' least a complete date, or NA.
#' @param varout Name of imputed output variable
#'
#' @return Returns the input data cut dataframe, with the additional of one extra variable (varout)
#' in POSIXct datetime format, which is the imputed version of varin.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' dcut <- data.frame(
#'   USUBJID = rep(c("UXYZ123a"), 7),
#'   DCUTDTC = c(
#'     "2022-06-23", "2022-06-23T16", "2022-06-23T16:57", "2022-06-23T16:57:30",
#'     "2022-06-23T16:57:30.123", "2022-06-23T16:-:30", "2022-06-23T-:57:30"
#'   )
#' )
#' dcut_final <- impute_dcutdtc(dsin = dcut, varin = DCUTDTC, varout = DCUTDTM)
#'
impute_dcutdtc <- function(dsin, varin, varout) {
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
    msg = "The varin variable contains datetimes in the incorrect format. All datetimes must
    be stored in ISO 8601 format."
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
  target["month"] <- "XYZ"
  target["day"] <- "XYZ"
  target["hour"] <- "23"
  target["minute"] <- "59"
  target["second"] <- "59"

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

  # Assertion to check that all DCUTDTC values are at least a complete date or NA
  imputed_dtc_2 <- ifelse(str_detect(imputed_dtc_1, "XYZ-XYZ-XYZ"), "", imputed_dtc_1)
  assert_that(all(!str_detect(imputed_dtc_2, "XYZ")),
    msg = "All values of the data cutoff variable must be at least a complete date"
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
