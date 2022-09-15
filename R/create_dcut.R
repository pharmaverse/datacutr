#' Create DCUT dataset
#'
#' Use to create a datacut dataset containing the variables `USUBJID`, `DCUTDTC`, `DCUTDESC`.
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
#' library(admiral)
#' ds <- tibble::tribble(
#'  ~USUBJID, ~DSSEQ, ~DSDECOD,
#'  "subject1", 1, "INFORMED CONSENT",
#'  "subject1", 2, "RANDOMIZATION",
#'  "subject1", 3, "WITHDRAWAL BY SUBJECT",
#'  "subject2", 1, "INFORMED CONSENT",
#'  "subject3", 1, "INFORMED CONSENT",
#'  "subject4", 1, "INFORMED CONSENT",
#'  "subject4", 2, "RANDOMIZATION"
#'  )
#'
#'  dcut <- create_dcut(dataset_ds = ds,
#'                      filter = DSDECOD == "RANDOMIZATION",
#'                      cut_date = "2022-01-01",
#'                      cut_description = "Clinical Cutoff Date")

create_dcut <- function(dataset_ds,
                        filter,
                        cut_date,
                        cut_description) {

  assert_data_frame(dataset_ds,
                    required_vars = quo_c(vars(USUBJID)))

  filter <- assert_filter_cond(enquo(filter), optional = TRUE)

  dataset <- dataset_ds %>%
    filter_if(filter) %>%
    mutate(DCUTDTC = cut_date) %>%
    mutate(DCUTDESC = cut_description) %>%
    subset(select = c(USUBJID, DCUTDTC, DCUTDESC))

  dataset
}
