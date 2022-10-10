#' @title Wrapper function to prepare and apply the datacut
#'
#' @description Loops through all input SDTM datasets, applies the selected type of datacut based on the selected
#' SDTM date variable, and outputs the resulting datasets. Also provides an option to perform a "special" cut on the
#' demography (dm) domain in which any deaths occuring after the datacut will be removed.
#'
#' @param dataset_cut Input datacut dataset, e.g. dcut
#' @param cut_var Datacut date variable, e.g. DCUTDTM
#' @param patient_cut A vector of quoted SDTM domain names in which a patient cut will be applied
#' @param date_cut A matrix where column 1 is the SDTM domain names in which a date cut will be applied. Column 2 is the associated SDTM date variable used to carry out the date cut.
#' @param special_dm A logical input indicating whether the "special dm cut" should be performed.
#' @param dthcut_var Death date variable (in date format) found in dm, if special_dm is TRUE.
#'
#' @return Returns all input SDTM datasets after performing the selected datacut on each domain.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' dcut <- data.frame(USUBJID=factor(c("a", "b"), levels=c("a", "b", "c")),
#'                   DCUTDTC=c("2022-02-17", "2022-02-17")) %>%
#'  impute_dcutdtc(DCUTDTC, DCUTDTM)
#'
#'sc <- data.frame(USUBJID=c("a", "a", "b", "c"))
#'ae <- data.frame(USUBJID=c("a", "a", "b", "c"),
#'                 AESTDTC=c("2022-02-16", "2022-02-18", "2022-02-16", "2022-02-16"))
#'dm <- data.frame(USUBJID=c("a", "b", "c"),
#'                 DTHDTC=c("2022-02-14", "2022-02-22", "2022-02-16"),
#'                 DTHFL=c("Y", "Y", "Y"))
#'
#'process_cut(dataset_cut=dcut, cut_var=DCUTDTM, patient_cut=c("sc"), date_cut=rbind(c("ae", "AESTDTC")),
#'            special_dm=TRUE, dthcut_var=DTHDTC)

process_cut <- function(dataset_cut, cut_var, patient_cut, date_cut, special_dm=TRUE, dthcut_var){

  #  Assertions for input parameters -----------------------------------------------

  cut_var <- assert_symbol(enquo(cut_var))
  assert_data_frame(dataset_cut,
                    required_vars = quo_c(vars(USUBJID), cut_var))
  assert_that(is.logical(special_dm),
              msg="special_dm must be either TRUE or FALSE")
  assert_that(is.vector(patient_cut),
              msg="patient_cut must be a vector")
  for (i in 1:length(patient_cut)) {
    assert_data_frame(get(patient_cut[i]),
                      required_vars = quo_c(vars(USUBJID)))
  }
  assert_that(is.matrix(date_cut),
              msg="date_cut must be a matrix")
  assert_that(ncol(date_cut)==2,
              msg="date_cut must be a matrix with two columns")
  for (i in 1:nrow(date_cut)) {
    assert_data_frame(get(date_cut[i,1]),
                      required_vars = quo_c(vars(USUBJID)))
  }

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
                    cut_var = !!cut_var))
  }

  # Conduct DM special cut for DTH flags after DCUTDTM ------------------------------

  if(special_dm){

    # Assertions for special dm cut
    dthcut_var <- assert_symbol(enquo(dthcut_var))
    assert_data_frame(dm,
                      required_vars = quo_c(vars(USUBJID), dthcut_var))

    assign(noquote("dm"),
           special_dm_cut(dataset_dm = dm,
                          dataset_cut = dataset_cut,
                          cut_var = cut_var,
                          dthcut_var = !!dthcut_var))
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
