#' xxSTDTC or xxDTC Cut
#'
#' Apply a datacut to either an xxSTDTC or xxDTC SDTM date variable
#'
#' @param dataset_sdtm Input SDTMv dataset
#' @param sdtm_date_var Input date variable found in the `dataset_sdtmv` dataset
#' @param cut_var Datacut date variable, default is `TEMP_DCUTDT`
#' @param cut_type Set to either "cut" or "drop", "cut" will keep all the records before the datacut in
#' the output dataset, "drop" will keep all the records which occur after and would be dropped, default is
#' "cut"
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
#' ae <- ae %>%
#'   pt_cut(.) %>%
#'   mutate(DCUT_TEMP_AESTDT <- AESTDTC) %>%
#'   sdtm_cut(dataset_sdtm = .,
#'            sdtm_date_var = AESTDTC)

sdtm_cut <- function(dataset_sdtm,
                     sdtm_date_var,
                     cut_var = TEMP_DCUTDT,
                     cut_type = "cut") {
  sdtm_date_var <- assert_symbol(enquo(sdtm_date_var))
  cut_var <- assert_symbol(enquo(cut_var))
  assert_data_frame(dataset_sdtm,
                    required_vars = quo_c(cut_var, sdtm_date_var))
  assert_character_scalar(cut_type,
                          values = c("cut", "drop"),
                          case_sensitive = FALSE)

  if (cut_type == "drop") {
    dataset <- dataset_sdtm %>%
      filter(!!sdtm_date_var > !!cut_var)
  }

  if (cut_type == "cut") {
    dataset <- dataset_sdtm %>%
      filter(!!sdtm_date_var <= !!cut_var |
               is.na(!!sdtm_date_var) | is.na(!!cut_var))
  }

  dataset <- drop_temp_vars(dsin=dataset, drop_dcut_temp="TRUE")

  dataset
}
