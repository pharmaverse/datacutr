#' Patient Cut
#'
#' Use to apply a patient cut to an SDTMv dataset (i.e. subset SDTMv observations on patients
#' included in the dataset_cut input dataset)
#'
#' @param dataset_sdtm Input SDTMv dataset
#' @param dataset_cut Input datacut dataset, e.g. dcut
#'
#' @author Alana Harris
#'
#' @return Input dataset plus a flag `DCUT_TEMP_REMOVE` to indicate which observations would be
#' dropped when a patient level datacut is applied
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' library(lubridate)
#' dcut <- tibble::tribble(
#'   ~USUBJID, ~DCUTDTM,
#'   "subject1", ymd_hms("2020-10-11T23:59:59"),
#'   "subject2", ymd_hms("2020-10-11T23:59:59"),
#'   "subject4", ymd_hms("2020-10-11T23:59:59")
#' )
#'
#' ae <- tibble::tribble(
#'   ~USUBJID, ~AESEQ, ~AESTDTC,
#'   "subject1", 1, "2020-01-02T00:00:00",
#'   "subject1", 2, "2020-08-31T00:00:00",
#'   "subject1", 3, "2020-10-10T00:00:00",
#'   "subject2", 2, "2020-02-20T00:00:00",
#'   "subject3", 1, "2020-03-02T00:00:00",
#'   "subject4", 1, "2020-11-02T00:00:00"
#' )
#'
#' ae_out <- pt_cut(
#'   dataset_sdtm = ae,
#'   dataset_cut = dcut
#' )
pt_cut <- function(dataset_sdtm,
                   dataset_cut) {
  assert_data_frame(dataset_sdtm,
    required_vars = exprs(USUBJID)
  )
  assert_data_frame(dataset_cut,
    required_vars = exprs(USUBJID)
  )
  assert_that(
    (length(get_duplicates(dataset_cut$USUBJID)) == 0),
    msg = "Duplicate patients in the DCUT (dataset_cut) dataset, please update."
  )

  dcut <- dataset_cut %>%
    subset(select = c(USUBJID)) %>%
    mutate(TEMP_FLAG = "Y")

  attributes(dcut$USUBJID)$label <- attributes(dataset_sdtm$USUBJID)$label

  dataset_sdtm_pt <- dataset_sdtm %>%
    left_join(
      x = .,
      y = dcut,
      by = "USUBJID"
    )

  # Flag records to be removed - patients not in dcut dataset
  dataset <- dataset_sdtm_pt %>%
    mutate(DCUT_TEMP_REMOVE = ifelse(is.na(TEMP_FLAG), "Y", NA_character_))

  dataset <- drop_temp_vars(dsin = dataset, drop_dcut_temp = FALSE)

  dataset
}
