#' Special DM Cut to reset Death variable information past cut date
#'
#' Applies patient cut if patient not in source DCUT, as well as
#' clearing death information within DM if death occurred after datacut date
#'
#' @param dataset_dm Input DM SDTMv dataset
#' @param dataset_cut Input datacut dataset
#' @param cut_var Datacut date variable found in the `dataset_cut` dataset, default is `DCUTDTM`
#'
#' @author Tim Barnett
#'
#' @return Input dataset plus a flag `DCUT_TEMP_REMOVE` to indicate which observations would be
#' dropped when a datacut is applied, and a flag `DCUT_TEMP_DTHCHANGE` to indicate which
#' observations have death occurring after data cut date for clearing
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#'
#' dcut <- tibble::tribble(
#'   ~USUBJID, ~DCUTDTC, ~DCUTDTM,
#'   "01-701-1015", "2014-10-20T23:59:59", lubridate::ymd_hms("2014-10-20T23:59:59"),
#'   "01-701-1023", "2014-10-20T23:59:59", lubridate::ymd_hms("2014-10-20T23:59:59")
#' )
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
  cut_var <- assert_symbol(enexpr(cut_var))

  assert_data_frame(dataset_cut,
    required_vars = exprs(USUBJID, !!cut_var)
  )
  assert_that(
    (length(get_duplicates(dataset_cut$USUBJID)) == 0),
    msg = "Duplicate patients in the DCUT (dataset_cut) dataset, please update."
  )
  ifelse(any(is.na(mutate(dataset_cut, !!cut_var))) == TRUE,
    print("At least 1 patient with missing datacut date, all records will be kept."), NA
  )
  assert_data_frame(dataset_dm,
    required_vars = exprs(USUBJID, DTHDTC)
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

  ifelse(!is.na(dm_temp$DCUT_TEMP_DCUTDTM), assert_that(is.POSIXt(dm_temp$DCUT_TEMP_DCUTDTM),
    msg = "cut_var is expected to be of date type POSIXt"
  ), NA)

  # Flag records with Death Date after Cut date
  dataset_updatedth <- dm_temp %>%
    mutate(DCUT_TEMP_DTHCHANGE = case_when(
      !is.na(DCUT_TEMP_DCUTDTM) & (DCUT_TEMP_DTHDT > DCUT_TEMP_DCUTDTM) ~ "Y",
      TRUE ~ as.character(NA)
    ))

  # Ensure variable is character
  dataset_updatedth$DCUT_TEMP_REMOVE <- as.character(dataset_updatedth$DCUT_TEMP_REMOVE)

  dataset_updatedth
}
