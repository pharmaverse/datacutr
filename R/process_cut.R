#' @title Wrapper function to prepare and apply the datacut
#'
#' @description Loops through all input SDTM datasets, applies the selected type of datacut, based on the selected
#' SDTM date variable, and outputs the resulting datasets
#'
#' @param dataset_cut Input datacut dataset, e.g. dcut
#' @param cut_var Datacut date variable, e.g. DCUTDTM
#' @param patient_cut A vector of quoted SDTM domain names in which a patient cut will be applied
#' @param date_cut A dataframe where column 1 is the SDTM domain names in which a date cut will be applied. Column 2 is the associated SDTM date variable used to carry out the date cut.
#' @param special_dm A logical input indicating whether the "special dm cut" should be performed.
#'
#' @return Returns all input SDTM datasets after performing the selected datacut on each domain.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' test <- 1
#'

process_cut <- function(dataset_cut, cut_varx, patient_cut, date_cut, special_dm, dthcut_var){


  browser()
  # Conduct Patient-Level Cut ------------------------------------------------------

  for (i in 1:length(patient_cut)) {
    assign(noquote(patient_cut[i]),
           pt_cut(dataset_sdtm = get(patient_cut[i]),
                  dataset_cut = dataset_cut))
  }

  # Conduct xxSTDTC or xxDTC Cut ---------------------------------------------------

  for (i in 1:nrow(date_cut)) {
    assign(noquote(date_cut[i,1]),
           date_cut(dataset_sdtm = get(date_cut[i,1]),
                    sdtm_date_var = !!as.symbol(date_cut[i,2]),
                    dataset_cut = dataset_cut,
                    cut_var = !!substitute(cut_varx)))
  }

  # Conduct DM special cut for DTH flags after DCUTDTM ------------------------------

  if(special_dm){
    assign(noquote("dm"),
           special_dm_cut(dataset_dm = dm,
                          dataset_cut = dataset_cut,
                          cut_var = cut_varx,
                          dthcut_var = dthcut_var))
  }

  # Apply the cut ------------------------------------------------------------------

  # Create list of all domains
  if(special_dm){
    all_cut <- c(patient_cut, date_cut[,1], "dm")
  }
  else{
    all_cut <- c(patient_cut, date_cut[,1])
  }

  # Creates datasets with all flagged obs removed + Updates DM flags if applicable
  for (i in 1:length(all_cut)) {
    assign(noquote(all_cut[i]),
           apply_cut(dsin = get(all_cut[i]),
                     dcutvar = DCUT_TEMP_REMOVE,
                     dthchangevar = DCUT_TEMP_DTHCHANGE),
           pos=1)
  }
}




