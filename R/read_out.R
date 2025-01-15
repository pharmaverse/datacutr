#' @title Function to generate datacut summary file
#'
#' @description Produces a .html file summarizing the changes applied to data during a data cut.
#' The file will contain an overview for the change in number of records for each dataset, the types
#' of cut applied and the opportunity to inspect the removed records.
#'
#' @param dcut The output datacut dataset (DCUT), created via the `create_dcut()` function,
#' containing the variable DCUTDTC.
#' @param patient_cut_data A list of quoted SDTMv domain names in which a patient cut has been.
#' applied (via the `pt_cut()` function). To be left blank if a patient cut has not been performed
#' on any domains.
#' @param date_cut_data A list of quoted SDTMv domain names in which a date cut has been applied.
#' (via the `date_cut()` function). To be left blank if a date cut has not been performed on any
#' domains.
#' @param dm_cut The output dataset, created via the `special_dm_cut()` function, containing
#' the variables DCUT_TEMP_REMOVE and DCUT_TEMP_DTHCHANGE.
#' @param no_cut_list List of of quoted SDTMv domain names in which no cut should be applied. To be
#' left blank if no domains are to remain exactly as source.
#' @param out_path A character vector of file save path for the summary file;
#' the default corresponds to a temporary directory, `tempdir()`.
#'
#' @return Returns a .html file summarizing the changes made to data during a datacut.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#' \dontrun{
#' dcut <- tibble::tribble(
#'   ~USUBJID, ~DCUTDTM, ~DCUTDTC,
#'   "subject1", lubridate::ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
#'   "subject2", lubridate::ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
#'   "subject4", lubridate::ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59"
#' )
#'
#' ae <- tibble::tribble(
#'   ~USUBJID, ~AESEQ, ~AESTDTC,
#'   "subject1", 1, "2020-01-02T00:00:00",
#'   "subject1", 2, "2020-08-31T00:00:00",
#'   "subject1", 3, "2020-10-10T00:00:00",
#'   "subject2", 2, "2020-02-20T00:00:00",
#'   "subject3", 1, "2020-03-02T00:00:00",
#'   "subject4", 1, "2020-11-02T00:00:00",
#'   "subject4", 2, ""
#' )
#'
#' dm <- tibble::tribble(
#'   ~USUBJID, ~DTHDTC, ~DTHFL,
#'   "subject1", "2020-10-11", "Y",
#'   "subject2", "2020-10-12", "Y",
#' )
#'
#' dt_ae <- date_cut(
#'   dataset_sdtm = ae,
#'   sdtm_date_var = AESTDTC,
#'   dataset_cut = dcut,
#'   cut_var = DCUTDTM
#' )
#'
#' pt_ae <- pt_cut(
#'   dataset_sdtm = ae,
#'   dataset_cut = dcut
#' )
#'
#' dm_cut <- special_dm_cut(
#'   dataset_dm = dm,
#'   dataset_cut = dcut,
#'   cut_var = DCUTDTM
#' )
#'
#' read_out(dcut, patient_cut_data = list(ae = pt_ae), date_cut_data = list(ae = dt_ae), dm_cut)
#' }
read_out <- function(dcut = NULL,
                     patient_cut_data = NULL,
                     date_cut_data = NULL,
                     dm_cut = NULL,
                     no_cut_list = NULL,
                     out_path = tempdir()) {
  if (!is.null(dcut)) {
    assert_data_frame(dcut,
      required_vars = exprs(USUBJID, DCUTDTC)
    )
  }
  if (!is.null(patient_cut_data)) {
    assert_that(is.list(patient_cut_data) & !is.data.frame(patient_cut_data),
      msg = "patient_cut_data must be a list. \n
Note: If you have not used or do not with to view patient cut on any SDTMv domains, then
please leave patient_cut_data empty, in which case a default value of NULL will be used."
    )

    for (i in seq_along(patient_cut_data)) {
      assert_data_frame(patient_cut_data[[i]],
        required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE)
      )

      assert_that(rlang::is_named(patient_cut_data[i]),
        msg = "All elements patient_cut_data must be named with corresponding domain"
      )
    }
  }
  if (!is.null(date_cut_data)) {
    assert_that(is.list(date_cut_data) & !is.data.frame(date_cut_data),
      msg = "date_cut_data must be a list. \n
Note: If you have not used or do not with to view date cut on any SDTMv domains, then please
leave date_cut_data empty, in which case a default value of NULL will be used."
    )
    for (i in seq_along(date_cut_data)) {
      assert_data_frame(date_cut_data[[i]],
        required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE)
      )

      assert_that(rlang::is_named(date_cut_data[i]),
        msg = "All elements in date_cut_data must be named with corresponding domain"
      )
    }
  }
  if (!is.null(dm_cut)) {
    assert_data_frame(dm_cut,
      required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE, DCUT_TEMP_DTHCHANGE)
    )
  }
  if (!is.null(no_cut_list)) {
    assert_that(is.list(no_cut_list) & !is.data.frame(no_cut_list),
      msg = "no_cut_list must be a list. \n
Note: If you have not used or do not with to view the SDTMv domains where no cut has been
applied, then please leave no_cut_list empty, in which case a default value of NULL will be
used."
    )
    for (i in seq_along(no_cut_list)) {
      assert_data_frame(no_cut_list[[i]])

      assert_that(rlang::is_named(no_cut_list[i]),
        msg = "All elements in no_cut_list must be named with corresponding domain"
      )
    }
  }
  rmarkdown::render(
    paste0(system.file(package = "datacutr"),
      path = "/read-out/read_out.Rmd"
    ),
    output_file = paste0("datacut_", format(Sys.time(), "%Y-%m-%d_%H%M%S", ".html")),
    output_dir = out_path,
    knit_root_dir = out_path
  )
}
