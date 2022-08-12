#' Patient Cut
#'
#' Use to apply a datacut a patient cut to an SDTMv dataset
#'
#' @param dataset_sdtm Input SDTMv dataset
#' @param dataset_cut Input datacut dataset, default is `dcut`
#' @param cut_var Datacut date variable found in the `dataset_cut` dataset, default is `DCUTDT`
#'
#' @author Alana Harris
#'
#' @return Input dataset plus a flag `TEMP_DCUT_REMOVE` to indicate which observations would be dropped when a patient level datacut is applied
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
#' ae_out <- pt_cut(ae)

pt_cut <- function(dataset_sdtm,
                   dataset_cut = dcut,
                   cut_var = DCUTDT) {

  cut_var <- assert_symbol(enquo(cut_var))
  assert_data_frame(dataset_sdtm,
                    required_vars = vars(USUBJID))
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
    mutate(DCUT_TEMP_REMOVE = ifelse(is.na(!!cut_var), 'Y', '')) %>%
    select(-!!cut_var)

  dataset <- drop_temp_vars(dsin=dataset, drop_dcut_temp="FALSE")

  dataset
}
