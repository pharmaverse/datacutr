#' Special DM Cut
#'
#' Clears death information within DM if death occurred after datacut date
#'
#' @param dataset_dm Input DM SDTMv dataset
#' @param dataset_cut Input datacut dataset, default is `dcut`
#' @param cut_var Datacut date variable found in the `dataset_cut` dataset, default is `TEMP_DCUTDT`
#' @param dthcut_var Death date variable (in date format) found in the `dataset_dm` dataset, default is `TEMP_DMDT`
#'
#' @author Tim Barnett
#'
#' @return A dataset with death information removed if death occurred after data cut
#'
#' @export
#'
#' @keywords assertion
#'
#' @examples
#'
#'

special_dm_cut <- function(dataset_dm,
                   dataset_cut = dcut ,
                   cut_var = TEMP_DCUTDT,
                   dthcut_var = TEMP_DMDT) {

  dthcut_var <- assert_symbol(enquo(dthcut_var))
  assert_data_frame(dataset_dm,
                    required_vars = vars(USUBJID,dthcut_var))
  assert_data_frame(dataset_cut,
                    required_vars = admiral:::quo_c(vars(USUBJID), cut_var))

  dcut <- dataset_cut %>%
    mutate(TEMP_DCUTDT = DCUTDT) %>%
    subset(select = c(USUBJID, TEMP_DCUTDT))

  dataset <- dataset_sdtm %>%
    left_join(dcut, by = "USUBJID")

  dataset
}
