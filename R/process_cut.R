#' @title Wrapper function to prepare and apply the datacut
#'
#' @description Applies the selected type of datacut on each SDTM dataset based on the selected SDTM date variable,
#' and outputs the resulting cut datasets. It also provides an option to perform a "special" cut on the
#' demography (dm) domain in which any deaths occurring after the datacut date will be removed.
#'
#' @param source_sdtm_data A list of uncut SDTM dataframes
#' @param patient_cut_lst A vector of quoted SDTM domain names in which a patient cut should be applied
#' @param date_cut_lst A vector of quoted SDTM domain names in which a date cut should be applied
#' @param date_cut_var_lst A vector of quoted SDTM date variables used to carry out the date cut for each SDTM domain. Note
#' that the order must be consistent with the order that the domains are listed in date_cut_lst.
#' @param dataset_cut Input datacut dataset, e.g. dcut
#' @param cut_var Datacut date variable within the dataset_cut dataset, e.g. DCUTDTM
#' @param special_dm A logical input indicating whether the "special dm cut" should be performed. Note that, if TRUE, there
#' is no need to specify dm in patient_cut_lst or date_cut_lst.
#' @param dthcut_var Death date variable (in date format) found in dm. Only required if special_dm is TRUE.
#'
#' @return Returns a list of all input SDTM datasets after performing the selected datacut on each domain.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' dcut <- data.frame(USUBJID=factor(c("a", "b"), levels=c("a", "b", "c")),
#' DCUTDTC=c("2022-02-17", "2022-02-17")) %>%
#'   impute_dcutdtc(DCUTDTC, DCUTDTM)
#' sc <- data.frame(USUBJID=c("a", "a", "b", "c"))
#' ae <- data.frame(USUBJID=c("a", "a", "b", "c"),
#'                  AESTDTC=c("2022-02-16", "2022-02-18", "2022-02-16", "2022-02-16"))
#' dm <- data.frame(USUBJID=c("a", "b", "c"),
#'                  DTHDTC=c("2022-02-14", "2022-02-22", "2022-02-16"),
#'                  DTHFL=c("Y", "Y", "Y"))
#' source_data <- list(sc=sc, ae=ae, dm=dm)
#'
#' process_cut(source_sdtm_data = source_data,
#'             patient_cut_lst = c("sc"),
#'             date_cut_lst = c("ae"),
#'             date_cut_var_lst = c("AESTDTC"),
#'             dataset_cut = dcut,
#'             cut_var = DCUTDTM,
#'             special_dm=TRUE,
#'             dthcut_var = DTHDTC)

process_cut <- function(source_sdtm_data,
                            patient_cut_lst,
                            date_cut_lst,
                            date_cut_var_lst,
                            dataset_cut,
                            cut_var,
                            special_dm=TRUE,
                            dthcut_var){

  #  Assertions for input parameters -----------------------------------------------

  assert_that(is.list(source_sdtm_data),
              msg="source_sdtm_data must be a list")
  assert_that(all(unlist(lapply(source_data, is.data.frame))),
              msg="All elements of the list source_sdtm_data must be a dataframe")
  assert_that(is.vector(patient_cut_lst),
              msg="patient_cut_lst must be a vector")
  assert_that(is.vector(date_cut_lst),
              msg="date_cut_lst must be a vector")
  assert_that(is.vector(date_cut_var_lst),
              msg="date_cut_var_lst must be a vector")
  cut_var <- assert_symbol(enquo(cut_var))
  assert_data_frame(dataset_cut,
                    required_vars = quo_c(vars(USUBJID), cut_var))
  assert_that(is.logical(special_dm),
              msg="special_dm must be either TRUE or FALSE")


  # Conduct Patient-Level Cut ------------------------------------------------------

  patient_cut_data <- lapply(
    source_sdtm_data[patient_cut_lst], pt_cut, dataset_cut = dataset_cut
  )

  # Conduct xxSTDTC or xxDTC Cut ---------------------------------------------------

  date_cut_data <- pmap(
    .l=list(dataset_sdtm = source_sdtm_data[date_cut_lst],
            sdtm_date_var = syms(date_cut_var_lst)),
    .f=date_cut,
    dataset_cut = dataset_cut,
    cut_var = !!cut_var
  )

  # Append SDTM datasets back together in a list
  all_cut <- c(patient_cut_data, date_cut_data)

  # Conduct DM special cut for DTH flags after DCUTDTM ------------------------------

  if(special_dm){

    # Assertions for special dm cut
    dthcut_var <- assert_symbol(enquo(dthcut_var))
    assert_data_frame(source_sdtm_data[["dm"]], required_vars = quo_c(vars(USUBJID), dthcut_var))

    dm_cut <- special_dm_cut(dataset_dm = source_sdtm_data[["dm"]],
                             dataset_cut = dataset_cut,
                             cut_var = cut_var,
                             dthcut_var = !!dthcut_var)

    # Append the cut dm dataset to the list of SDTM datasets
    all_cut <- c(list(dm = dm_cut), all_cut)
  }

  # Apply the cut ------------------------------------------------------------------

  cut_data <- map(
    all_cut,
    apply_cut,
    dcutvar = DCUT_TEMP_REMOVE,
    dthchangevar = DCUT_TEMP_DTHCHANGE
  )

  # Return the final list of cut SDTM datasets
  return(cut_data)
}
