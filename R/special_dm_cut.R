#' Special DM Cut to reset Death variable information past cut date
#'
#' Clears death information within DM if death occurred after datacut date
#'
#' @param dataset_dm Input DM SDTMv dataset
#' @param dataset_cut Input datacut dataset
#' @param cut_var Datacut date variable found in the `dataset_cut` dataset, default is `DCUTDTM`
#'
#' @author Tim Barnett
#'
#' @return A dataset with death information flagged if death occurred after data cut
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
#'   ~USUBJID, ~DCUTDTC,
#'   "01-701-1015", "2014-10-20T23:59:59",
#'   "01-701-1023", "2014-10-20T23:59:59",
#' ) %>%
#'   mutate(DCUTDTM = ymd_hms(DCUTDTC))
#'
#' dm <- tibble::tribble(
#'   ~USUBJID, ~DTHDTC, ~DTHFL,
#'   "01-701-1015", "2014-10-20", "Y",
#'   "01-701-1023", "2014-10-21", "Y",
#' )
#'
#' special_dm_cut(
#'   dataset_dm = dm,
#'   dataset_cut = dcut,
#'   cut_var = DCUTDTM
#' )
special_dm_cut <- function(dataset_dm,
                           dataset_cut,
                           cut_var = DCUTDTM) {
  cut_var <- assert_symbol(enquo(cut_var))

  assert_data_frame(dataset_cut,
    required_vars = quo_c(vars(USUBJID), cut_var)
  )

  attributes(dataset_cut$USUBJID)$label <- attributes(dataset_dm$USUBJID)$label

  # Merge in DCUT information and impute DCUTDTC to usable date format
  dm_temp <- pt_cut(
    dataset_sdtm = dataset_dm,
    dataset_cut = dataset_cut
  ) %>%
    impute_sdtm(DTHDTC, DCUT_TEMP_DTHDT) %>%
    left_join((dataset_cut %>% select(USUBJID, DCUT_TEMP_DCUTDTM = !!cut_var)),
      by = "USUBJID"
    )

  assert_that(is.POSIXt(dm_temp$DCUT_TEMP_DCUTDTM),
    msg = "cut_var is expected to be of date type POSIXt"
  )

  # Flag records with Death Date after Cut date
  dataset_updatedth <- dm_temp %>%
    mutate(DCUT_TEMP_DTHCHANGE = case_when(
      DCUT_TEMP_DTHDT > DCUT_TEMP_DCUTDTM ~ "Y",
      TRUE ~ as.character(NA)
    ))

  dataset_updatedth
}
