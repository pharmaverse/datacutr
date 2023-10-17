#' @title Drops Temporary Variables From a Dataset
#'
#' @description Drops all the temporary variables (variables beginning with TEMP_) from the input
#' dataset. Also allows the user to specify whether or not to drop the temporary variables needed
#' throughout multiple steps of the datacut process (variables beginning with DCUT_TEMP_).
#'
#' @details The other functions within this package use `drop_temp_vars` with the `drop_dcut_temp`
#' argument set to FALSE so that the variables needed across multiple steps of the process are
#' kept. The final datacut takes place in the `apply_cut` function, at which point `drop_temp_vars`
#' is used with the `drop_dcut_temp` argument set to TRUE, so that all temporary variables are
#' dropped.
#'
#' @param dsin Name of input dataframe
#' @param drop_dcut_temp Whether or not to drop variables beginning with DCUT_TEMP_ (TRUE/FALSE).
#'
#' @return Returns the input dataframe, excluding the temporary variables.
#'
#' @export
#'
#' @keywords user_utility
#'
#' @examples
#' ae <- tibble::tribble(
#'   ~USUBJID, ~AESEQ, ~TEMP_FLAG, ~DCUT_TEMP_REMOVE,
#'   "subject1", 1, "Y", NA,
#'   "subject1", 2, "Y", NA,
#'   "subject1", 3, NA, "Y",
#'   "subject2", 2, "Y", NA,
#'   "subject3", 1, NA, "Y",
#'   "subject4", 1, NA, "Y"
#' )
#' drop_temp_vars(dsin = ae) # Drops temp_ and dcut_temp_ variables
#' drop_temp_vars(dsin = ae, drop_dcut_temp = TRUE) # Drops temp_ and dcut_temp_ variables
#' drop_temp_vars(dsin = ae, drop_dcut_temp = FALSE) # Drops temp_ variables
#'
drop_temp_vars <- function(dsin, drop_dcut_temp = TRUE) {
  # Check if dataframe exists and that drop_dcut_temp is true or false
  assert_data_frame(dsin)
  assert_that(is.logical(drop_dcut_temp),
    msg = "drop_dcut_temp must be either TRUE or FALSE"
  )

  out <- dsin %>%
    select(-starts_with("TEMP_"))

  if (drop_dcut_temp) {
    out <- out %>%
      select(-starts_with("DCUT_TEMP_"))
  }
  return(out)
}
