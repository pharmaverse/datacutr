#' Patient Cut
#'
#' Apply a patient cut and add a datacut date variable (TEMP_DCUTDT) to an SDTMv dataset
#'
#' @param dataset_sdtm Input SDTMv dataset
#' @param dataset_cut Input datacut dataset, default is `dcut`
#' @param cut_var Datacut date variable found in the `dataset_cut` dataset, default is `DCUTDT`
#' @param cut_type Set to either "cut" or "drop", "cut" will keep all the patients that are in the datacut dataset
#' "drop" will keep all the patients that are dropped by applying the patient cut, default is "cut"
#'
#' @author Alana Harris
#'
#' @return A dataset containing either the records kept or removed after applying the datacut
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' library(dplyr)
#' library(admiral.test)
#' library(admiral)
#'
#' data("admiral_dm")
#' data("admiral_ae")
#'
#' dm <- admiral_dm
#' ae <- admiral_ae
#'
#' dcut <- dm %>%
#'   filter(RACE == "BLACK OR AFRICAN AMERICAN") %>%
#'   select(USUBJID) %>%
#'   mutate(DCUTDT = "2013-01-01", DCUTDESC = "Clinical Cutoff Date")
#'
#' ae_keep <- pt_cut(ae)
#' ae_drop <- pt_cut(ae,
#'                   cut_type = "drop")

pt_cut <- function(dataset_sdtm,
                   dataset_cut = dcut,
                   cut_var = DCUTDT,
                   cut_type = "cut") {

  cut_var <- assert_symbol(enquo(cut_var))
  assert_data_frame(dataset_sdtm,
                    required_vars = vars(USUBJID))
  assert_data_frame(dataset_cut,
                    required_vars = quo_c(vars(USUBJID), cut_var))
  assert_character_scalar(cut_type,
                          values = c("cut", "drop"),
                          case_sensitive = FALSE)

  dcut <- dataset_cut %>%
    mutate(TEMP_DCUTDT = !!cut_var) %>%
    subset(select = c(USUBJID, TEMP_DCUTDT))

  attributes(dcut$USUBJID)$label <- attributes(dataset_sdtm$USUBJID)$label

  if (cut_type == "cut") {
    dataset <- dataset_sdtm %>%
      inner_join(x = dcut,
                 y = .,
                 by = "USUBJID",
                 all.x = TRUE)
  }

  if (cut_type == "drop") {
    dataset <- dataset_sdtm %>%
      anti_join(x = .,
                y = dcut,
                by = "USUBJID")
  }

  dataset
}
