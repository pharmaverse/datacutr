#' @title Drops Temporary Variables From a Dataset
#'
#' @description Drops all the temporary variables (variables beginning with TEMP_) from the input dataset.
#' It also allows the user to specify whether or not to drop the temporary variables needed throughout the
#' datacut process (variables beginning with DCUT_TEMP_).
#'
#' @details The idea of this function is that, when used throughout the datacut process, drop_dcut_temp would
#' always be set to FALSE until the very end of the datacut process, in which case, drop_dcut_temp would be set
#' to TRUE.
#'
#' @param dsin Name of input dataframe
#' @param drop_dcut_temp Whether or not to drop variables beginning with DCUT_TEMP_ (TRUE/FALSE).
#'
#' @return Returns the input dataframe, excluding the temporary variables.
#'
#' @export
#'
#' @examples
#' test <-  data.frame(USUBJID=c(""), TEMP_XYZ=c(""), DCUT_TEMP_XYZ=c(""))
#' drop_temp_vars(dsin=test)                           # Drops temp_ and dcut_temp_ variables
#' drop_temp_vars(dsin=test, drop_dcut_temp="TRUE")    # Drops temp_ and dcut_temp_ variables
#' drop_temp_vars(dsin=test, drop_dcut_temp="FALSE")   # Drops temp_ variables

drop_temp_vars <- function(dsin, drop_dcut_temp = TRUE){

  out <- dsin %>%
    select(-starts_with("TEMP_"))

  if(drop_dcut_temp){
    out <- out %>%
      select(-starts_with("DCUT_TEMP_"))
  }
  return(out)
}
