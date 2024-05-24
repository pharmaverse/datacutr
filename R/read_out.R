#' @title Produce a Datacut Summary Rmarkdown
#'
#' @description
#'
#' @param dcut
#' @param patient_cut_data A list of quoted SDTMv domain names in which a patient cut has been
#' applied. To be left blank if a patient cut has not been performed on any domains.
#' @param date_cut_data A list of quoted SDTMv domain names in which a date cut has been applied.
#' To be left blank if a date cut has not been performed on any domains.
#' @param dm_cut
#' @param no_cut_list List of of quoted SDTMv domain names in which no cut should be applied. To be
#' left blank if no domains are to remain exactly as source.
#'
#' @return Returns a .html R markdown summarising the changes made to data during a data cut.
#'
#' @export
#'
#' @keywords derive
#'
#' @examples
#'

# alt name summarize_cut() ??
read_out <- function(dcut = NULL,
                     patient_cut_data = NULL,
                     date_cut_data = NULL,
                     dm_cut = NULL,
                     no_cut_list = NULL,
                     out_path = ".") {
#browser()
  if (!is.null(dcut)) {
    assert_data_frame(dcut,
                    required_vars = exprs(USUBJID, DCUTDTC)
    )
    }
  if (!is.null(patient_cut_data)){
    assert_that(is.list(patient_cut_data) & !is.data.frame(patient_cut_data),
                msg = "patient_cut_data must be a list. \n
Note: If you have not used or do not with to view patient cut on any SDTMv domains, then please leave
patient_cut_data empty, in which case a default value of NULL will be used.")

    for(i in seq(length(patient_cut_data))){
      assert_data_frame(patient_cut_data[[i]],
                        required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE))

      assert_that(is_named(patient_cut_data[i]),
                   msg = "All elements patient_cut_data must be named with corresponding domain")
    }
  }
  if (!is.null(date_cut_data)){
    assert_that(is.list(date_cut_data) & !is.data.frame(date_cut_data),
                msg = "date_cut_data must be a list. \n
Note: If you have not used or do not with to view date cut on any SDTMv domains, then please leave
date_cut_data empty, in which case a default value of NULL will be used.")
    for(i in seq(length(date_cut_data))){
      assert_data_frame(date_cut_data[[i]],
                        required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE))

      assert_that(is_named(date_cut_data[i]),
                  msg = "All elements in date_cut_data must be named with corresponding domain")
    }
  }
  if (!is.null(dm_cut)){
    assert_data_frame(dm_cut,
                    required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE, DCUT_TEMP_DTHCHANGE)
  )
  }
  if (!is.null(no_cut_list)){
    assert_that(is.list(no_cut_list) & !is.data.frame(no_cut_list),
                msg = "no_cut_list must be a list. \n
Note: If you have not used or do not with to view the SDTMv domains where no cut has been applied, then please leave
no_cut_list empty, in which case a default value of NULL will be used.")
    for(i in seq(length(no_cut_list))){
      assert_data_frame(no_cut_list[[i]])

      assert_that(is_named(no_cut_list[i]),
                  msg = "All elements in no_cut_list must be named with corresponding domain")
  }
  }
  rmarkdown::render(paste0(system.file(package = "datacutr"),
                                path = "/read-out/read_out.Rmd"),
                    output_file = paste("datacut_", format(Sys.time(), "%d-%b-%Y_%H:%M:%S", ".html")),
                    output_dir = out_path)
}
