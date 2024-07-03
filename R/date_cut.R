#' xxSTDTC or xxDTC Cut
#'
#' Use to apply a datacut to either an xxSTDTC or xxDTC SDTM date variable. The datacut date from
#' the datacut dataset is merged on to the input SDTMv dataset and renamed to `TEMP_DCUT_DCUTDTM`.
#' A flag `TEMP_DCUT_REMOVE` is added to the dataset to indicate the observations that would be
#' removed when the cut is applied.
#' Note that this function applies a patient level datacut at the same time (using the `pt_cut()`
#' function), and also imputes dates in the specified SDTMv dataset (using the `impute_sdtm()`
#' function).
#'
#' @param dataset_sdtm Input SDTMv dataset
#' @param sdtm_date_var Input date variable found in the `dataset_sdtmv` dataset
#' @param dataset_cut Input datacut dataset
#' @param cut_var Datacut date variable
#'
#' @author Alana Harris
#'
#' @return Input dataset plus a flag `TEMP_DCUT_REMOVE` to indicate which observations would be
#' dropped when a datacut is applied
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' library(lubridate)
#' dcut <- tibble::tribble(
#'   ~USUBJID, ~DCUTDTM, ~DCUTDTC,
#'   "subject1", ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
#'   "subject2", ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
#'   "subject4", ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59"
#' )
#'
#' ae <- tibble::tribble(
#'   ~USUBJID, ~AESEQ, ~AESTDTC,
#'   "subject1", 1, "2020-01-02T00:00:00",
#'   "subject1", 2, "2020-08-31T00:00:00",
#'   "subject1", 3, "2020-10-10T00:00:00",
#'   "subject2", 2, "2020-02-20T00:00:00",
#'   "subject3", 1, "2020-03-02T00:00:00",
#'   "subject4", 1, "2020-11-02T00:00:00",
#'   "subject4", 2, ""
#' )
#'
#' ae_out <- date_cut(
#'   dataset_sdtm = ae,
#'   sdtm_date_var = AESTDTC,
#'   dataset_cut = dcut,
#'   cut_var = DCUTDTM
#' )
date_cut <- function(dataset_sdtm,
                     sdtm_date_var,
                     dataset_cut,
                     cut_var) {
  sdtm_date_var <- assert_symbol(enexpr(sdtm_date_var))
  cut_var <- assert_symbol(enexpr(cut_var))
  assert_data_frame(dataset_sdtm,
    required_vars = exprs(USUBJID, !!sdtm_date_var)
  )
  assert_data_frame(dataset_cut,
    required_vars = exprs(USUBJID, !!cut_var)
  )
  assert_that(
    (length(get_duplicates(dataset_cut$USUBJID)) == 0),
    msg = "Duplicate patients in the DCUT (dataset_cut) dataset, please update."
  )
  ifelse(any(is.na(mutate(dataset_cut, !!cut_var))) == TRUE,
    print("At least 1 patient with missing datacut date, all records will be kept."), NA
  )

  dcut <- dataset_cut %>%
    mutate(DCUT_TEMP_DCUTDTM = !!cut_var) %>%
    subset(select = c(USUBJID, DCUT_TEMP_DCUTDTM)) %>%
    mutate(TEMP_DCUT_KEEP = "Y")

  ifelse(!is.na(dcut$DCUT_TEMP_DCUTDTM), assert_that(is.POSIXt(dcut$DCUT_TEMP_DCUTDTM),
    msg = "cut_var is expected to be of date type POSIXt"
  ), NA)

  attributes(dcut$USUBJID)$label <- attributes(dataset_sdtm$USUBJID)$label

  dataset_sdtm_pt <- dataset_sdtm %>%
    impute_sdtm(dsin = ., varin = !!sdtm_date_var, varout = DCUT_TEMP_SDTM_DATE) %>%
    left_join(
      x = .,
      y = dcut,
      by = "USUBJID"
    )

  # Flag records to be removed - those occurring after cut date and patients not in dcut dataset
  dataset <- dataset_sdtm_pt %>%
    mutate(DCUT_TEMP_REMOVE = ifelse((DCUT_TEMP_SDTM_DATE > DCUT_TEMP_DCUTDTM) |
      is.na(TEMP_DCUT_KEEP), "Y", NA_character_))

  # Ensure variable is character
  dataset$DCUT_TEMP_REMOVE <- as.character(dataset$DCUT_TEMP_REMOVE)

  dataset <- drop_temp_vars(dsin = dataset, drop_dcut_temp = FALSE)

  dataset
}
