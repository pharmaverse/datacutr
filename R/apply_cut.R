#' @title Applies the datacut based on the datacut flagging variables
#'
#' @description Removes any records where the datacut flagging variable, usually called
#' DCUT_TEMP_REMOVE, is marked as "Y". Also, sets the death related variables in DM
#' (DTHDTC and DTHFL) to missing if the death after datacut flagging variable, usually
#' called DCUT_TEMP_DTHCHANGE, is marked as "Y".
#'
#' @param dsin Name of input dataframe
#' @param dcutvar Name of datacut flagging variable created by `pt_cut` and `date_cut` functions -
#' usually called DCUT_TEMP_REMOVE.
#' @param dthchangevar Name of death after datacut flagging variable created by `special_dm_cut`
#' function - usually called DCUT_TEMP_DTHCHANGE.
#'
#' @return Returns the input dataframe, excluding any rows in which `dcutvar` is flagged as "Y".
#' DTHDTC and DTHFL are set to missing for any records where `dthchangevar` is flagged as "Y". Any
#' variables with the "DCUT_TEMP" prefix are removed.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' ae <- data.frame(
#'   USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c", "UXYZ123d"),
#'   DCUT_TEMP_REMOVE = c("Y", "", "NA", NA)
#' )
#' ae_final <- apply_cut(dsin = ae, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = DCUT_TEMP_DTHCHANGE)
#'
#' dm <- data.frame(
#'   USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123b"),
#'   DTHDTC = c("2014-10-20", "2014-10-21", "2013-09-08"),
#'   DTHFL = c("Y", "Y", "Y"),
#'   DCUT_TEMP_REMOVE = c(NA, NA, "Y"),
#'   DCUT_TEMP_DTHCHANGE = c(NA, "Y", "")
#' )
#' dm_final <- apply_cut(dsin = dm, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = DCUT_TEMP_DTHCHANGE)
apply_cut <- function(dsin, dcutvar, dthchangevar) {
  # Handle input values for use in tidyverse
  dcutvar <- assert_symbol(enexpr(dcutvar))
  dthchangevar <- enexpr(dthchangevar)

  # Check if dataframe exists and whether required variables exists within them
  assert_data_frame(dsin,
    required_vars = exprs(!!dcutvar)
  )

  # Remove any rows where datacut flagging variable (dcutvar) is "Y"
  out <- dsin %>%
    filter(is.na(!!dcutvar) | !!dcutvar != "Y")

  # Overwrite death variables if death change variable (dthchangevar) is "Y"
  if (any(names(dsin) == expr_name(dthchangevar))) {
    assert_symbol(dthchangevar)
    if (any(names(dsin) == "DTHFL")) {
      out <- out %>%
        mutate(DTHFL = case_when(
          as.character(!!dthchangevar) == "Y" ~ "",
          TRUE ~ as.character(DTHFL)
        ))
      attributes(out$DTHFL)$label <- attributes(dsin$DTHFL)$label
    }
    if (any(names(dsin) == "DTHDTC")) {
      out <- out %>%
        mutate(DTHDTC = case_when(
          as.character(!!dthchangevar) == "Y" ~ "",
          TRUE ~ as.character(DTHDTC)
        ))
      attributes(out$DTHDTC)$label <- attributes(dsin$DTHDTC)$label
    }
  }

  # Drop temporary variables
  out_final <- drop_temp_vars(dsin = out, drop_dcut_temp = TRUE)

  return(out_final)
}
