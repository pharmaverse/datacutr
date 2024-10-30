#' Create Datacut Dataset (DCUT)
#'
#' @description After filtering the input DS dataset (based on the given filter condition), any
#' records where the SDTMv date/time variable is on or before the datacut date/time (after
#' imputations) will be returned in the output datacut dataset (DCUT). Note that `ds_date_var`
#' and `cut_date` inputs must be in ISO 8601 format (YYYY-MM-DDThh:mm:ss) and will be imputed
#' using the `impute_sdtm()` and `impute_dcutdtc()` functions.
#'
#' @param dataset_ds Input DS SDTMv dataset
#' @param ds_date_var Character date/time variable in the DS SDTMv to be compared against the
#' datacut date
#' @param filter Condition to filter patients in DS, should give 1 row per patient
#' @param cut_date Datacut date/time, e.g. "2022-10-22", or NA if no date cut is to be applied
#' @param cut_description Datacut date/time description, e.g. "Clinical Cut Off Date"
#'
#' @author Alana Harris
#'
#' @return Datacut dataset containing the variables `USUBJID`, `DCUTDTC`, `DCUTDTM` and
#' `DCUTDESC`.
#'
#' @author Alana Harris
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' ds <- tibble::tribble(
#'   ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSTDTC,
#'   "subject1", 1, "INFORMED CONSENT", "2020-06-23",
#'   "subject1", 2, "RANDOMIZATION", "2020-08-22",
#'   "subject1", 3, "WITHDRAWAL BY SUBJECT", "2020-05-01",
#'   "subject2", 1, "INFORMED CONSENT", "2020-07-13",
#'   "subject3", 1, "INFORMED CONSENT", "2020-06-03",
#'   "subject4", 1, "INFORMED CONSENT", "2021-01-01",
#'   "subject4", 2, "RANDOMIZATION", "2023-01-01"
#' )
#'
#' dcut <- create_dcut(
#'   dataset_ds = ds,
#'   ds_date_var = DSSTDTC,
#'   filter = DSDECOD == "RANDOMIZATION",
#'   cut_date = "2022-01-01",
#'   cut_description = "Clinical Cutoff Date"
#' )
create_dcut <- function(dataset_ds,
                        ds_date_var,
                        filter,
                        cut_date,
                        cut_description) {
  ds_date_var <- assert_symbol(enexpr(ds_date_var))
  assert_data_frame(dataset_ds,
    required_vars = exprs(USUBJID, !!ds_date_var)
  )
  filter <- assert_filter_cond(enexpr(filter), optional = TRUE)

  # Check that ds_date_var is in ISO 8601 format
  input_dtc <- pull(dataset_ds, !!ds_date_var)
  valid_dtc <- is_valid_dtc(input_dtc)
  assert_that(all(valid_dtc),
    msg = "The ds_date_var variable contains datetimes in the incorrect format. All datetimes
   must be stored in ISO 8601 format."
  )

  # Check that cut date is not NULL
  assert_that(!is.null(cut_date),
    msg = "Cut date is NULL, please populate as NA or valid ISO8601 date format"
  )

  # Check that cut_date is in ISO 8601 format
  valid_dtc <- is_valid_dtc(cut_date)
  assert_that(valid_dtc,
    msg = "The cut_date parameter is in the incorrect format. All datetimes
  must be stored in ISO 8601 format."
  )

  dataset <- dataset_ds %>%
    impute_sdtm(dsin = ., varin = !!ds_date_var, varout = DCUT_TEMP_DATE) %>%
    mutate(DCUTDTC = cut_date) %>%
    mutate(DCUTDESC = cut_description) %>%
    impute_dcutdtc(dsin = ., varin = DCUTDTC, varout = DCUTDTM) %>%
    filter(., (!is.na(DCUTDTM) & DCUTDTM >= DCUT_TEMP_DATE) | is.na(DCUTDTM)) %>%
    filter_if(filter) %>%
    subset(select = c(USUBJID, DCUTDTC, DCUTDTM, DCUTDESC))

  assert_that(
    (length(get_duplicates(dataset$USUBJID)) == 0),
    msg = "Duplicate patients in the final returned dataset, please update."
  )

  # Print message if cut date is null
  ifelse(any(is.na(mutate(dataset, DCUTDTM))) == TRUE,
    print("At least 1 patient with missing datacut date."), NA
  )
  dataset
}
