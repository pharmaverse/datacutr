#' xxSTDTC or xxDTC Cut
#'
#' Use to apply a datacut to either an xxSTDTC or xxDTC SDTM date variable. A flag `TEMP_DCUT_REMOVE` is added to the dataset
#' to indicate the observations that would be removed when the cut is applied. Note that this function applies a patient level
#' datacut at the same time.
#'
#' @param dataset_sdtm Input SDTMv dataset
#' @param sdtm_date_var Input date variable found in the `dataset_sdtmv` dataset
#' @param dataset_cut Input datacut dataset, default is `dcut`
#' @param cut_var Datacut date variable, default is `DCUTDT`
#'
#' @author Alana Harris
#'
#' @return Input dataset plus a flag `TEMP_DCUT_REMOVE` to indicate which observations would be dropped when a datacut is applied
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' library(dplyr)
#' library(admiral.test)
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
#' ae_out <- ae %>%
#'   sdtm_cut(dataset_sdtm = .,
#'            sdtm_date_var = AESTDTC)

sdtm_cut <- function(dataset_sdtm,
                     sdtm_date_var,
                     dataset_cut = dcut,
                     cut_var = DCUTDT) {
  sdtm_date_var <- assert_symbol(enquo(sdtm_date_var))
  cut_var <- assert_symbol(enquo(cut_var))
  assert_data_frame(dataset_sdtm,
                    required_vars = quo_c(vars(USUBJID), sdtm_date_var))
  assert_data_frame(dataset_cut,
                    required_vars = quo_c(vars(USUBJID), cut_var))


  dcut <- dataset_cut %>%
    subset(select = c(USUBJID, DCUTDT))

  attributes(dcut$USUBJID)$label <- attributes(dataset_sdtm$USUBJID)$label

  dataset_sdtm_pt <- dataset_sdtm %>%
    left_join(x = .,
              y = dcut,
              by = "USUBJID")

  # Flag records to be removed - those occurring after cut date and patients not in dcut dataset
  dataset <- dataset_sdtm_pt %>%
    mutate(DCUT_TEMP_REMOVE = ifelse((!!sdtm_date_var > !!cut_var) | is.na(!!cut_var), 'Y', '')) %>%
    select(-!!cut_var)

  dataset <- drop_temp_vars(dsin=dataset, drop_dcut_temp="FALSE")

  dataset
}
