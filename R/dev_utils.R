#' Concatenate One or More Quosure(s)
#'
#' @param ... One or more objects of class `quosure` or `quosures`
#'
#' @return An object of class `quosures`
#'
#' @author Thomas Neitmann
#'
#' @keywords dev_utility
#'
#' @export
#'
#' @examples
#' quo_c(rlang::quo(USUBJID))
#' quo_c(rlang::quo(STUDYID), rlang::quo(USUBJID))
#' quo_c(dplyr::vars(USUBJID, ADTM))
#' quo_c(rlang::quo(BASETYPE), dplyr::vars(USUBJID, PARAM), rlang::quo(ADTM))
quo_c <- function(...) {
  inputs <- unlist(list(...), recursive = TRUE)
  stopifnot(all(map_lgl(inputs, is_quosure)))
  is_null <- map_lgl(inputs, quo_is_null)
  as_quosures(inputs[!is_null])
}
