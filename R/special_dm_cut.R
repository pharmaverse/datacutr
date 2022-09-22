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
#'
#' @examples
#'
#'
#' library(dplyr)
#' library(lubridate)
#'
#' dcut <- tibble::tribble(
#' ~USUBJID, ~DCUTDTC,
#' "01-701-1015", "2014-10-20T23:59:59",
#' "01-701-1023", "2014-10-20T23:59:59",
#' ) %>%
#'   mutate(DCUTDT = ymd_hms(DCUTDTC))
#'
#' dm <- tibble::tribble(
#' ~USUBJID, ~DTHDTC, ~DTHFL,
#' "01-701-1015", "2014-10-20", "Y",
#' "01-701-1023", "2014-10-21", "Y",
#' )
#'
#'   special_dm_cut(dataset_dm=dm,
#'                       dataset_cut=dcut,
#'                       cut_var=DCUTDT,
#'                       dthcut_var=DTHDTC)

special_dm_cut <- function(dataset_dm,
                   dataset_cut = dcut ,
                   cut_var = DCUTDT,
                   dthcut_var = DTHDTC) {

  cut_var <- assert_symbol(enquo(cut_var))
  dthcut_var <- assert_symbol(enquo(dthcut_var))

  attributes(dataset_cut$USUBJID)$label <- attributes(dataset_dm$USUBJID)$label

  dm_temp <- pt_cut(dataset_sdtm=dataset_dm,
                    dataset_cut=dataset_cut) %>%
             impute_sdtm(DTHDTC,DCUT_TEMP_DTHDT) %>%
             left_join((dcut %>% select(USUBJID,DCUT_TEMP_DCUTDT=DCUTDT)),
                        by="USUBJID")

  dataset_updatedth <- dm_temp %>%
    mutate(DCUT_TEMP_DTHCHANGE = case_when(
      DCUT_TEMP_DTHDT > DCUT_TEMP_DCUTDT ~ "Y",
      TRUE ~ as.character(NA)
    ))

  dataset_updatedth
}

