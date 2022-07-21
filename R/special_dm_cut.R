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
#' @keywords derive

special_dm_cut <- function(dataset_dm,
                   dataset_cut = dcut ,
                   cut_var = TEMP_DCUTDT,
                   dthcut_var = TEMP_DTHDT) {

  # dthcut_var <- assert_symbol(enquo(dthcut_var))
  # assert_data_frame(dataset_dm,
  #                   required_vars = vars(USUBJID,dthcut_var))
  # assert_data_frame(dataset_cut,
  #                   required_vars = admiral:::quo_c(vars(USUBJID), cut_var))

  dataset_updatedth <- dataset_dm %>%
    mutate(DTHFL = case_when(
      dthcut_var>cut_var & DTHFL=="Y" ~ "",
      TRUE ~ DTHFL
    ))

  dataset_updatedth
}

# chk <- special_dm_cut(dataset_dm=dm_tempdt,
#                dataset_cut=dcut,
#                cut_var="TEMP_DCUTDT",
#                dthcut_var="TEMP_DTHDT") %>%
#   select(USUBJID,TEMP_DCUTDT,TEMP_DTHDT,DTHDTC,DTHFL)
