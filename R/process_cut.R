# nolint start: cyclocomp_linter
#' @title Wrapper function to prepare and apply the datacut of SDTMv datasets
#'
#' @description Applies the selected type of datacut on each SDTMv dataset based on the chosen
#' SDTMv date variable, and outputs the resulting cut datasets, as well as the datacut dataset,
#' as a list. It provides an option to perform a "special" cut on the demography (dm) domain
#' in which any deaths occurring after the datacut date are removed. It also provides an option
#' to produce a .html file that summarizes the changes applied to the data during the cut, where
#' you can inspect the records that have been removed and/or modified.
#'
#' @param source_sdtm_data A list of uncut SDTMv dataframes
#' @param patient_cut_v A vector of quoted SDTMv domain names in which a patient cut should be
#' applied. To be left blank if a patient cut should not be performed on any domains.
#' @param date_cut_m A 2 column matrix, where the first column is the quoted SDTMv domain names in
#' which a date cut should be applied and the second column is the quoted SDTMv date variables used
#' to carry out the date cut for each SDTMv domain. To be left blank if a date cut should not be
#' performed on any domains.
#' @param no_cut_v A vector of quoted SDTMv domain names in which no cut should be applied. To be
#' left blank if no domains are to remain exactly as source.
#' @param dataset_cut Input datacut dataset, e.g. dcut
#' @param cut_var Datacut date variable within the dataset_cut dataset, e.g. DCUTDTM
#' @param special_dm A logical input indicating whether the `special dm cut` should be performed.
#' Note that, if TRUE, dm should not be included in `patient_cut_v`, `date_cut_m` or `no_cut_v`
#' inputs.
#' @param read_out A logical input indicating whether a summary file for the datacut should be
#' produced. If `TRUE`, a .html file will be returned containing a summary of the cut and
#' records removed. Default set to `FALSE`.
#' @param out_path A character vector of file save path for the summary file if `read_out = TRUE`;
#' the default corresponds to the working directory, `getwd()`.
#'
#' @return Returns a list of all input SDTMv datasets, plus the datacut dataset, after
#' performing the selected datacut on each SDTMv domain.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' dcut <- data.frame(
#'   USUBJID = c("a", "b"),
#'   DCUTDTC = c("2022-02-17", "2022-02-17")
#' )
#' dcut <- impute_dcutdtc(dcut, DCUTDTC, DCUTDTM)
#' sc <- data.frame(USUBJID = c("a", "a", "b", "c"))
#' ts <- data.frame(USUBJID = c("a", "a", "b", "c"))
#' ae <- data.frame(
#'   USUBJID = c("a", "a", "b", "c"),
#'   AESTDTC = c("2022-02-16", "2022-02-18", "2022-02-16", "2022-02-16")
#' )
#' source_data <- list(sc = sc, ae = ae, ts = ts)
#'
#' cut_data <- process_cut(
#'   source_sdtm_data = source_data,
#'   patient_cut_v = c("sc"),
#'   date_cut_m = rbind(c("ae", "AESTDTC")),
#'   no_cut_v = c("ts"),
#'   dataset_cut = dcut,
#'   cut_var = DCUTDTM,
#'   special_dm = FALSE
#' )
#'
process_cut <- function(source_sdtm_data,
                        patient_cut_v = NULL,
                        date_cut_m = NULL,
                        no_cut_v = NULL,
                        dataset_cut,
                        cut_var,
                        special_dm = TRUE,
                        read_out = FALSE,
                        out_path = ".") {
  #  Assertions for input parameters -----------------------------------------------
  assert_that(is.list(source_sdtm_data),
    msg = "source_sdtm_data must be of class list"
  )

  assert_that(all(unlist(lapply(source_sdtm_data, is.data.frame))),
    msg = "All elements of source_sdtm_data must be a dataframe"
  )

  assert_that(all(is.vector(patient_cut_v) | is.null(patient_cut_v), patient_cut_v != ""),
    msg = "patient_cut_v must be a vector or NULL. \n
Note: If no SDTMv domains use a patient cut, then please leave patient_cut_v
empty, in which case a default value of NULL will be used."
  )

  assert_that(all(is.matrix(date_cut_m) | is.null(date_cut_m), date_cut_m != ""),
    msg = "date_cut_m must be a matrix or NULL. \n
Note: If no SDTMv domains use a date cut, then please leave date_cut_m
empty, in which case a default value of NULL will be used."
  )

  assert_that(any(ncol(date_cut_m) == 2, is.null(date_cut_m)),
    msg = "date_cut_m must be a matrix with two columns or NULL."
  )

  assert_that(all(is.vector(no_cut_v) | is.null(no_cut_v), no_cut_v != ""),
    msg = "no_cut_v must be a vector or NULL. \n
Note: If you do not wish to leave any SDTMv domains uncut, then please leave
no_cut_v empty, in which case a default value of NULL will be used."
  )

  cut_var <- assert_symbol(enexpr(cut_var))
  assert_data_frame(dataset_cut,
    required_vars = exprs(USUBJID, !!cut_var)
  )

  assert_that(is.logical(special_dm),
    msg = "special_dm must be either TRUE or FALSE"
  )

  sdtm_inputs <- names(source_sdtm_data)
  cut_inputs <- c(patient_cut_v, date_cut_m[, 1], no_cut_v)

  if (special_dm) {
    assert_that("dm" %in% names(source_sdtm_data),
      msg = "dataset `dm` is missing from source_sdtm_data but special_dm processing expects this"
    )
    cut_inputs <- append(cut_inputs, "dm")
  }
  # No cut list --------------------------------------------------------------------
  no_cut_list <- source_sdtm_data[no_cut_v]

  sdtm_inputs_dups <- c()
  no_cut_method <- c()
  for (i in seq_len(length(sdtm_inputs))) {
    if ((sdtm_inputs[i] %in% sdtm_inputs[-i]) && !(sdtm_inputs[i] %in% sdtm_inputs_dups)) {
      sdtm_inputs_dups <- append(sdtm_inputs_dups, sdtm_inputs[i])
    }
    if (!(sdtm_inputs[i] %in% cut_inputs) && !(sdtm_inputs[i] %in% no_cut_method)) {
      no_cut_method <- append(no_cut_method, sdtm_inputs[i])
    }
  }
  error_msg1 <- paste0(
    paste(sdtm_inputs_dups, collapse = " & "),
    " exists more than once in source_sdtm_data"
  )
  assert_that(is.null(sdtm_inputs_dups),
    msg = error_msg1
  )
  error_msg2 <- paste0(
    paste(no_cut_method, collapse = " & "),
    " exists in source_sdtm_data but no cut method has been assigned"
  )
  assert_that(is.null(no_cut_method),
    msg = error_msg2
  )

  cut_inputs_dups <- c()
  no_sdtm <- c()
  for (i in seq_len(length(cut_inputs))) {
    if ((cut_inputs[i] %in% cut_inputs[-i]) && !(cut_inputs[i] %in% cut_inputs_dups)) {
      cut_inputs_dups <- append(cut_inputs_dups, cut_inputs[i])
    }
    if (!(cut_inputs[i] %in% sdtm_inputs) && !(cut_inputs[i] %in% no_sdtm)) {
      no_sdtm <- append(no_sdtm, cut_inputs[i])
    }
  }
  error_msg3 <- paste0(
    "Multiple cut types have been assigned for ",
    paste(cut_inputs_dups, collapse = " & ")
  )
  assert_that(is.null(cut_inputs_dups),
    msg = error_msg3
  )
  error_msg4 <- paste0(
    "Cut types have been assigned for ", paste(no_sdtm, collapse = " & "),
    " which does not exist in source_sdtm_data"
  )
  assert_that(is.null(no_sdtm),
    msg = error_msg4
  )

  # Conduct Patient-Level Cut ------------------------------------------------------

  patient_cut_data <- lapply(
    source_sdtm_data[patient_cut_v], pt_cut,
    dataset_cut = dataset_cut
  )

  # Conduct xxSTDTC or xxDTC Cut ---------------------------------------------------

  date_cut_data <- pmap(
    .l = list(
      dataset_sdtm = source_sdtm_data[date_cut_m[, 1]],
      sdtm_date_var = syms(date_cut_m[, 2])
    ),
    .f = date_cut,
    dataset_cut = dataset_cut,
    cut_var = !!cut_var
  )

  # Append SDTM datasets back together in a list
  all_cut <- c(patient_cut_data, date_cut_data)

  # Conduct DM special cut for DTH flags after DCUTDTM ------------------------------
  # dm_cut = NULL unless special dm cut applied
  dm_cut <- NULL

  if (special_dm) {
    # Assertions for special dm cut
    assert_data_frame(source_sdtm_data[["dm"]], required_vars = exprs(USUBJID))

    dm_cut <- special_dm_cut(
      dataset_dm = source_sdtm_data[["dm"]],
      dataset_cut = dataset_cut,
      cut_var = !!cut_var
    )

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

  # Return the final list of SDTM datasets + DCUT ----------------------------------

  final_data <- c(list(dcut = dataset_cut), cut_data, source_sdtm_data[no_cut_v])

  if (read_out) {
    read_out(dataset_cut, patient_cut_data, date_cut_data, dm_cut, no_cut_list, out_path)
  }

  return(final_data)
}
# nolint end
