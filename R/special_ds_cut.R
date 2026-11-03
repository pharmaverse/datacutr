#' Special DS Cut to remove Death disposition records past cut date
#'
#' Where \code{special_dm_cut()} determines that a subject's death occurred after the
#' data cutoff date (\code{DCUT_TEMP_DTHCHANGE = "Y"}), the corresponding DS record
#' where \code{DSDECOD = "DEATH"} should also be removed. This function flags those
#' records by setting \code{DCUT_TEMP_REMOVE = "Y"}, consistent with the output of
#' \code{pt_cut()} and \code{date_cut()}, so that \code{apply_cut()} can handle the
#' actual removal.
#'
#' @param dataset_ds Input DS SDTMv dataset
#' @param dataset_dm_cut Output of \code{special_dm_cut()}, containing
#'   \code{DCUT_TEMP_DTHCHANGE}
#'
#' @author Tim Barnett
#'
#' @return Input DS dataset with \code{DCUT_TEMP_REMOVE} set to \code{"Y"} for any
#'   record where \code{DSDECOD = "DEATH"} and the corresponding subject had their
#'   death cleared by \code{special_dm_cut()}.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' library(lubridate)
#'
#' dcut <- tibble::tribble(
#'   ~USUBJID, ~DCUTDTC, ~DCUTDTM,
#'   "01-701-1015", "2014-10-20T23:59:59", ymd_hms("2014-10-20T23:59:59"),
#'   "01-701-1023", "2014-10-20T23:59:59", ymd_hms("2014-10-20T23:59:59")
#' )
#'
#' dm <- tibble::tribble(
#'   ~USUBJID,      ~DTHDTC,       ~DTHFL,
#'   "01-701-1015", "2014-10-20",  "Y",
#'   "01-701-1023", "2014-10-21",  "Y"
#' )
#'
#' ds <- tibble::tribble(
#'   ~USUBJID,      ~DSSEQ, ~DSDECOD,
#'   "01-701-1015", 1,      "COMPLETED",
#'   "01-701-1015", 2,      "DEATH",
#'   "01-701-1023", 1,      "COMPLETED",
#'   "01-701-1023", 2,      "DEATH"
#' )
#'
#' dm_cut <- special_dm_cut(
#'   dataset_dm  = dm,
#'   dataset_cut = dcut,
#'   cut_var     = DCUTDTM
#' )
#'
#' special_ds_cut(dataset_ds = ds, dataset_dm_cut = dm_cut)
special_ds_cut <- function(dataset_ds, dataset_dm_cut) {
  assert_data_frame(dataset_ds,
    required_vars = exprs(USUBJID, DSDECOD)
  )
  assert_data_frame(dataset_dm_cut,
    required_vars = exprs(USUBJID, DCUT_TEMP_DTHCHANGE)
  )

  if (nrow(dataset_ds) == 0L) {
    return(dataset_ds)
  }

  death_cleared <- dataset_dm_cut %>%
    filter(DCUT_TEMP_DTHCHANGE == "Y") %>%
    pull(USUBJID)

  ds_out <- dataset_ds
  if (!"DCUT_TEMP_REMOVE" %in% names(ds_out)) {
    ds_out <- ds_out %>% mutate(DCUT_TEMP_REMOVE = NA_character_)
  }

  ds_out %>%
    mutate(
      DCUT_TEMP_REMOVE = case_when(
        USUBJID %in% death_cleared & DSDECOD == "DEATH" ~ "Y",
        TRUE ~ DCUT_TEMP_REMOVE
      )
    )
}
