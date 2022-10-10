#' @title Wrapper function to prepare and apply the datacut
#'
#' @description Loops through all input SDTM datasets, applies the selected type of datacut, based on the selected
#' SDTM date variable, and outputs the resulting datasets
#'
#' @param patient_cut A vector of quoted SDTM domain names in which a patient cut will be applied
#' @param date_cut A dataframe where column 1 is the SDTM domain names in which a date cut will be applied.
#' Column 2 is the associated SDTM date variable used to carry out the date cut.
#' @param dataset_cut Input datacut dataset, e.g. dcut
#' @param cut_var Datacut date variable, e.g. DCUTDTM
#' @param special_dm A logical input indicating whether the "special dm cut" should be performed.
#'
#' @return Returns the input dataframe, excluding any rows in which dcutvar is flagged as "Y". DTHDTC and DTHFL are
#' set to missing for any records where dthchangevar is flagged as "Y". Any variables with the "DCUT_TEMP" prefix
#' are removed.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
