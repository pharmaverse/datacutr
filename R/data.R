#' Disposition SDTMv Dataset
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
"datacutr_ds"

#' Demographics SDTMv Dataset
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
"datacutr_dm"

#' Adverse Events SDTMv Dataset
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
"datacutr_ae"

#' Subject Characteristics SDTMv Dataset
#'
#' An example Subject Characteristics (SC) SDTMv domain.
#'
#' @format A dataset with 5 rows and 2 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{SCORRES}{Result or Finding in Original Units}
#' }
#' @keywords data
"datacutr_sc"

#' Laboratory Test Results SDTMv Dataset
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
"datacutr_lb"

#' Findings About Events or Interventions SDTMv Dataset
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
"datacutr_fa"

#' Trial Summary SDTMv Dataset
#'
#' An example Trial Summary (TS) SDTMv domain.
#'
#' @format A dataset with 5 rows and 2 variables:
#' \describe{
#'   \item{USUBJID}{Unique Subject Identifier}
#'   \item{TSVAL}{Parameter Value}
#' }
#' @keywords data
"datacutr_ts"
