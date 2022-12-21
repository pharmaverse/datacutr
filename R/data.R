#' ds
#'
#' An example Disposition (DS) SDTMv domain.
#'
#' @format A dataset with 5 rows and 3 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{DSDECOD}{Standardized Disposition Term}
#'   \item{DSSTDTC}{Start Date/Time of Disposition Event}
#' }
#' @keywords data
"ds"

#' dm
#'
#' An example Demographics (DM) SDTMv domain.
#'
#' @format A dataset with 5 rows and 3 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{DTHFL}{Subject Death Flag}
#'   \item{DTHDTC}{Date/Time of Death}
#' }
#' @keywords data
"dm"

#' ae
#'
#' An example Adverse Events (AE) SDTMv domain.
#'
#' @format A dataset with 5 rows and 3 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{AETERM}{Reported Term for the Adverse Event}
#'   \item{AESTDTC}{Start Date/Time of Adverse Event}
#' }
#' @keywords data
"ae"

#' sc
#'
#' An example Subject Characteristics (SC) SDTMv domain.
#'
#' @format A dataset with 5 rows and 2 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{SCORRES}{Result or Finding in Original Units}
#' }
#' @keywords data
"sc"

#' lb
#'
#' An example Laboratory Test Results (LB) SDTMv domain.
#'
#' @format A dataset with 5 rows and 3 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{LBORRES}{Result or Finding in Original Units}
#'   \item{LBDTC}{Date/Time of Specimen Collection}
#' }
#' @keywords data
"lb"

#' fa
#'
#' An example Findings About Events or Interventions (FA) SDTMv domain.
#'
#' @format A dataset with 5 rows and 4 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{FAORRES}{Result or Finding in Original Units}
#'   \item{FADTC}{Date/Time of Collection}
#'   \item{FASTDTC}{Start Date/Time of Observation}
#' }
#' @keywords data
"fa"

#' ts
#'
#' An example Trial Summary (TS) SDTMv domain.
#'
#' @format A dataset with 5 rows and 2 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{TSVAL}{Parameter Value}
#' }
#' @keywords data
"ts"
