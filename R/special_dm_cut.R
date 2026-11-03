#' Special DM Cut to reset Death variable information past cut date
#'
#' Applies patient cut if patient not in source DCUT, as well as
#' clearing death information within DM if death occurred after datacut date.
#' When \code{LALIVEDT} (the last known alive date, derived from uncut SDTM data)
#' is supplied as a column in \code{dataset_cut}, a two-rule imputation is applied
#' to partial \code{DTHDTC} values (see Details).
#'
#' @details
#' For partial \code{DTHDTC} values, the imputed death date is the later of:
#' \itemize{
#'   \item \strong{Rule A} — earliest date consistent with the partial date:
#'     missing day imputed as the 1st of the reported month; missing month and day
#'     imputed as 1 January of the reported year.
#'   \item \strong{Rule B} — \code{LALIVEDT} + 1 day (only when \code{LALIVEDT} is
#'     present in \code{dataset_cut}).
#' }
#'
#' \strong{Conflict — partial dates:} Where \code{LALIVEDT} is on or after the last
#' date the reported partial date permits (last day of the reported month where the day
#' is missing, or 31 December of the reported year where the month and day are missing),
#' the reported death date and the last known alive date are in conflict. In this case
#' \code{LALIVEDT + 1 day} still takes precedence — it is applied as the imputed death
#' date and the record is flagged \code{DCUT_TEMP_DTHCONFLICT = "Y"}.
#'
#' \strong{Conflict — complete dates:} Where \code{LALIVEDT} is on or after a complete
#' \code{DTHDTC}, the recorded death date and the last known alive date are in conflict.
#' The recorded death date is \strong{not} changed (it is specific and authoritative), but
#' the record is flagged \code{DCUT_TEMP_DTHCONFLICT = "Y"}.
#'
#' All conflict records should be queried and resolved before applying the cut.
#'
#' \strong{Completely missing death dates} (\code{DTHDTC} with no date components)
#' are never flagged and are always retained (section 5.4.3).
#'
#' \code{LALIVEDT} must be a complete (non-partial) Date or POSIXt column. It is
#' derived from uncut SDTM data and is therefore independent of \code{ADSL.LSTALVDT},
#' which uses cut data. Study teams must explicitly define which records constitute
#' evidence of being alive.
#'
#' @param dataset_dm Input DM SDTMv dataset
#' @param dataset_cut Input datacut dataset. May optionally include a \code{LALIVEDT}
#'   column (complete Date or POSIXt, one row per USUBJID) representing the last known
#'   alive date derived from uncut SDTM data. When present, Rule B imputation and
#'   conflict detection are applied to partial \code{DTHDTC} values. When absent,
#'   only Rule A is applied (current behaviour, backward compatible).
#' @param cut_var Datacut date variable found in the \code{dataset_cut} dataset,
#'   default is \code{DCUTDTM}
#'
#' @author Tim Barnett
#'
#' @return Input dataset plus:
#' \itemize{
#'   \item \code{DCUT_TEMP_REMOVE} — "Y" for subjects not in \code{dataset_cut}
#'   \item \code{DCUT_TEMP_DTHDT} — imputed death datetime (Rule A or Rule B)
#'   \item \code{DCUT_TEMP_DCUTDTM} — datacut datetime
#'   \item \code{DCUT_TEMP_DTHCHANGE} — "Y" when imputed death date is after the
#'     datacut date
#'   \item \code{DCUT_TEMP_DTHCONFLICT} — "Y" when a conflict between \code{LALIVEDT}
#'     and \code{DTHDTC} is detected (partial dates: \code{LALIVEDT} on or after the
#'     last permitted date of the range; complete dates: \code{LALIVEDT} on or after
#'     the recorded death date); only present when \code{LALIVEDT} is supplied in
#'     \code{dataset_cut}
#' }
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

  # Validate LALIVEDT type if present
  if ("LALIVEDT" %in% names(dataset_cut)) {
    assert_that(
      inherits(dataset_cut$LALIVEDT, c("Date", "POSIXt")),
      msg = "LALIVEDT in dataset_cut must be of type Date or POSIXt"
    )
  }

  # If SDTM dataset is empty, output empty file
  if (nrow(dataset_dm) == 0L) {
    dataset_updatedth <- dataset_dm
  }

  # Only proceed with cut if DM dataset is non-empty
  if (nrow(dataset_dm) > 0L) {
    assert_data_frame(dataset_dm,
      required_vars = exprs(USUBJID, DTHDTC)
    )

    attributes(dataset_cut$USUBJID)$label <- attributes(dataset_dm$USUBJID)$label

    # Merge in DCUT information and impute DTHDTC to usable date format (Rule A)
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

    # Apply Rule B (LKAD + 1) and conflict detection when LALIVEDT is in dataset_cut
    if ("LALIVEDT" %in% names(dataset_cut)) {
      dm_temp <- dm_temp %>%
        left_join(dataset_cut %>% select(USUBJID, LALIVEDT), by = "USUBJID") %>%
        mutate(
          DCUT_TEMP_DTHDT_LAST = dthdtc_last_permitted(DTHDTC),
          DCUT_TEMP_DTHCONFLICT = case_when(
            dthdtc_partial_type(DTHDTC) %in% c("partial_day", "partial_month_day") &
              !is.na(LALIVEDT) &
              as.Date(LALIVEDT) >= DCUT_TEMP_DTHDT_LAST ~ "Y",
            dthdtc_partial_type(DTHDTC) == "complete" &
              !is.na(LALIVEDT) &
              as.Date(LALIVEDT) >= as.Date(DCUT_TEMP_DTHDT) ~ "Y",
            TRUE ~ NA_character_
          ),
          DCUT_TEMP_DTHDT = case_when(
            # Conflict or Rule B: LKAD + 1 always takes precedence for partial dates
            # when LKAD + 1 is later than Rule A (including the conflict case where
            # LKAD >= last permitted date)
            dthdtc_partial_type(DTHDTC) %in% c("partial_day", "partial_month_day") &
              !is.na(LALIVEDT) &
              as.POSIXct(as.Date(LALIVEDT) + 1L, tz = "UTC") > DCUT_TEMP_DTHDT ~
              as.POSIXct(as.Date(LALIVEDT) + 1L, tz = "UTC"),
            TRUE ~ DCUT_TEMP_DTHDT
          )
        ) %>%
        select(-DCUT_TEMP_DTHDT_LAST, -LALIVEDT)
    }

    # Flag records with Death Date after Cut date
    dataset_updatedth <- dm_temp %>%
      mutate(DCUT_TEMP_DTHCHANGE = case_when(
        !is.na(DCUT_TEMP_DCUTDTM) & (DCUT_TEMP_DTHDT > DCUT_TEMP_DCUTDTM) ~ "Y",
        TRUE ~ as.character(NA)
      ))

    # Ensure variable is character
    dataset_updatedth$DCUT_TEMP_REMOVE <- as.character(dataset_updatedth$DCUT_TEMP_REMOVE)
  }
  dataset_updatedth
}

# Classify a DTHDTC character vector by the degree of partial-ness.
# Returns "complete", "partial_day", "partial_month_day", or "missing".
dthdtc_partial_type <- function(dthdtc) {
  case_when(
    is.na(dthdtc) | dthdtc == "" ~ "missing",
    str_detect(dthdtc, "^\\d{4}-\\d{2}-\\d{2}") ~ "complete",
    str_detect(dthdtc, "^\\d{4}-\\d{2}$") ~ "partial_day",
    str_detect(dthdtc, "^\\d{4}$") ~ "partial_month_day",
    TRUE ~ "missing"
  )
}

# Return the last Date consistent with a partial DTHDTC string:
#   "partial_day"        -> last day of the reported month
#   "partial_month_day"  -> 31 December of the reported year
#   "complete" / "missing" -> NA
dthdtc_last_permitted <- function(dthdtc) {
  ptype <- dthdtc_partial_type(dthdtc)
  result <- rep(as.Date(NA_character_), length(dthdtc))

  is_pd <- ptype == "partial_day"
  if (any(is_pd, na.rm = TRUE)) {
    d <- ymd(paste0(dthdtc[is_pd], "-01"))
    result[is_pd] <- as.Date(ceiling_date(d, unit = "month") - 1)
  }

  is_pmd <- ptype == "partial_month_day"
  if (any(is_pmd, na.rm = TRUE)) {
    yr <- as.integer(dthdtc[is_pmd])
    result[is_pmd] <- make_date(yr, 12L, 31L)
  }

  result
}
