#' Create DCUT dataset
#'
<<<<<<< HEAD
#' Use to create a datacut dataset containing the variables `USUBJID`, `DCUTDTC`, `DCUTDT`, `DCUTDESC`.
=======
#' Use to create a datacut dataset containing the variables `USUBJID`, `DCUTDTC`, `DCUTDESC`.
>>>>>>> f1701f6ba845d5d8984ee652f3f51e3814103ce4
#'
#' @param dataset_ds Input DS SDTMv dataset
#' @param filter Condition to filter patients in DS, should give 1 row per patient
#' @param cut_date Datacut date, e.g. "2022-10-22"
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
#'library(admiral)
#'ds <- tibble::tribble(
#'  ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSDTC,
#'  "subject1", 1, "INFORMED CONSENT",      "2020-06-23",
#'  "subject1", 2, "RANDOMIZATION",         "2020-08-22",
#'  "subject1", 3, "WITHDRAWAL BY SUBJECT", "2020-05-01",
#'  "subject2", 1, "INFORMED CONSENT",      "2020-07-13",
#'  "subject3", 1, "INFORMED CONSENT",      "2020-06-03",
#'  "subject4", 1, "INFORMED CONSENT",      "2021-01-01",
#'  "subject4", 2, "RANDOMIZATION",         "2023-01-01"
#')
#'
#'temp_ds <- impute_sdtm(dsin=ds, varin=DSSDTC, varout=DCUT_TEMP_DSSDTC)
#'
#'dcut <- create_dcut(dataset_ds = temp_ds,
#'                    filter = DSDECOD == "RANDOMIZATION" & DCUTDT>=DCUT_TEMP_DSSDTC,
#'                    cut_date = "2022-01-01",
#'                    cut_description = "Clinical Cutoff Date")


create_dcut <- function(dataset_ds,
                        filter,
                        cut_date,
                        cut_description) {

  assert_data_frame(dataset_ds,
                    required_vars = quo_c(vars(USUBJID)))

  filter <- assert_filter_cond(enquo(filter), optional = TRUE)

  dataset <- dataset_ds %>%
    mutate(DCUTDTC = cut_date) %>%
    mutate(DCUTDESC = cut_description) %>%
    impute_dcutdtc(dsin=., varin=DCUTDTC, varout=DCUTDT) %>%
    filter_if(filter) %>%
    subset(select = c(USUBJID, DCUTDTC, DCUTDT, DCUTDESC))
  dataset
}
