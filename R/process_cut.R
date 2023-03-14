#' @title Wrapper function to prepare and apply the datacut of SDTMv datasets
#'
#' @description Applies the selected type of datacut on each SDTMv dataset based on the chosen
#' SDTMv date variable, and outputs the resulting cut datasets as a list. It also provides an
#' option to perform a "special" cut on the demography (dm) domain in which any deaths occurring
#' after the datacut date are removed.
#'
#' @param source_sdtm_data A list of uncut SDTMv dataframes
#' @param patient_cut_v A vector of quoted SDTMv domain names in which a patient cut should be
#' applied
#' @param date_cut_m A 2 column matrix, where the first column is the quoted SDTMv domain names in
#' which a date cut should be applied and the second column is the quoted SDTMv date variables used
#' to carry out the date cut for each SDTMv domain.
#' @param no_cut_v A vector of quoted SDTMv domain names in which no cut should be applied
#' @param dataset_cut Input datacut dataset, e.g. dcut
#' @param cut_var Datacut date variable within the dataset_cut dataset, e.g. DCUTDTM
#' @param special_dm A logical input indicating whether the "special dm cut" should be performed.
#' Note that, if TRUE, there is no need to specify dm in patient_cut_v, date_cut_m or no_cut_v
#'
#' @return Returns a list of all input SDTMv datasets, plus the dataset_cut dataset, after
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
#' dm <- data.frame(
#'   USUBJID = c("a", "b", "c"),
#'   DTHDTC = c("2022-02-14", "2022-02-22", "2022-02-16"),
#'   DTHFL = c("Y", "Y", "Y")
#' )
#' source_data <- list(sc = sc, ae = ae, dm = dm, ts = ts)
#'
#' cut_data <- process_cut(
#'   source_sdtm_data = source_data,
#'   patient_cut_v = c("sc"),
#'   date_cut_m = rbind(c("ae", "AESTDTC")),
#'   no_cut_v = c("ts"),
#'   dataset_cut = dcut,
#'   cut_var = DCUTDTM,
#'   special_dm = TRUE
#' )
#'
process_cut <- function(source_sdtm_data,
                        patient_cut_v,
                        date_cut_m,
                        no_cut_v,
                        dataset_cut,
                        cut_var,
                        special_dm = TRUE) {
  #  Assertions for input parameters -----------------------------------------------
  assert_that(is.list(source_sdtm_data),
    msg = "source_sdtm_data must be a list"
  )
  assert_that(all(unlist(lapply(source_sdtm_data, is.data.frame))),
    msg = "All elements of the list source_sdtm_data must be a dataframe"
  )
  assert_that(is.vector(patient_cut_v),
    msg = "patient_cut_v must be a vector"
  )
  assert_that(is.matrix(date_cut_m),
    msg = "date_cut_m must be a matrix"
  )
  assert_that(ncol(date_cut_m) == 2,
    msg = "date_cut_m must be a matrix with two columns"
  )
  assert_that(is.vector(no_cut_v),
    msg = "no_cut_v must be a vector"
  )
  cut_var <- assert_symbol(enexpr(cut_var))
  assert_data_frame(dataset_cut,
    required_vars = exprs(USUBJID, !!cut_var)
  )
  assert_that(is.logical(special_dm),
    msg = "special_dm must be either TRUE or FALSE"
  )
  if (special_dm) {
    assert_that(
      setequal(names(source_sdtm_data), c(
        patient_cut_v, date_cut_m[, 1], no_cut_v,
        "dm"
      )),
      msg = "Every input SDTM dataset must be referenced in exactly one of patient_cut_v,
             date_cut_m or no_cut_v"
    )
    assert_that(
      length(unique(c(patient_cut_v, date_cut_m[, 1], no_cut_v, "dm")))
      == length(c(patient_cut_v, date_cut_m[, 1], no_cut_v, "dm")),
      msg = "Every input SDTM dataset must be referenced in exactly one of patient_cut_v,
             date_cut_m or no_cut_v. Note that, if special_dm=TRUE, there is no need to
             specify dm in patient_cut_v, date_cut_m or no_cut_v"
    )
  } else {
    assert_that(setequal(names(source_sdtm_data), c(patient_cut_v, date_cut_m[, 1], no_cut_v)),
      msg = "Every input SDTM dataset must be referenced in exactly one of patient_cut_v,
             date_cut_m or no_cut_v"
    )
    assert_that(
      length(unique(c(patient_cut_v, date_cut_m[, 1], no_cut_v)))
      == length(c(patient_cut_v, date_cut_m[, 1], no_cut_v)),
      msg = "Every input SDTM dataset must be referenced in exactly one of patient_cut_v,
             date_cut_m or no_cut_v."
    )
  }

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
  return(final_data)
}
