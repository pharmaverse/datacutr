#' Create DCUT dataset
#'
#' Use to create a datacut dataset containing the variables `USUBJID`, `DCUTDTC`, `DCUTDTM` and
#' `DCUTDESC`.
#'
#' @param dataset_ds Input DS SDTMv dataset
#' @param ds_date_var Character date variable in the DS SDTMv to be imputed
#' @param filter Condition to filter patients in DS, should give 1 row per patient
#' @param cut_date Datacut date, e.g. "2022-10-22"
#' @param cut_description Datacut date description, e.g. "Clinical Cut Off Date"
#'
#' @author Alana Harris
#'
#' @return Datacut dataset
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
  assert_data_frame(dataset_ds,
    required_vars = vars(USUBJID)
  )
  ds_date_var <- assert_symbol(enquo(ds_date_var))
  filter <- assert_filter_cond(enquo(filter), optional = TRUE)

  dataset <- dataset_ds %>%
    impute_sdtm(dsin = ., varin = !!ds_date_var, varout = DCUT_TEMP_DATE) %>%
    mutate(DCUTDTC = cut_date) %>%
    mutate(DCUTDESC = cut_description) %>%
    impute_dcutdtc(dsin = ., varin = DCUTDTC, varout = DCUTDTM) %>%
    filter(., DCUTDTM >= DCUT_TEMP_DATE) %>%
    filter_if(filter) %>%
    subset(select = c(USUBJID, DCUTDTC, DCUTDTM, DCUTDESC))
  dataset
}
