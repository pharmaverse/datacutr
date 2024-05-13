# Generate read-out file function
# alt name summarize_cut()
read_out <- function(dcut = NULL,
                     patient_cut_data = NULL,
                     date_cut_data = NULL,
                     dm_cut = NULL,
                     final_data = NULL,
                     no_cut_list = NULL,
                     out_path = "~") {

  # if (!is.null(dcut)) {
  #   assert_data_frame(dcut,
  #                   required_vars = exprs(USUBJID, DCUTDTC),
  #                   #msg = "Required variable `DCUTDTC` is missing from dcut dataset"
  #   )
  #   }

  if (!is.null(patient_cut_data)){
    assert_that(is.list(patient_cut_data) & !is.data.frame(patient_cut_data),
                msg = "patient_cut_data must be a list. \n
Note: If you have not used or do not with to view patient cut on any SDTMv domains, then please leave
patient_cut_data empty, in which case a default value of NULL will be used.")
  }

  if (!is.null(date_cut_data)){
    assert_that(is.list(date_cut_data) & !is.data.frame(date_cut_data),
                msg = "date_cut_data must be a list. \n
Note: If you have not used or do not with to view date cut on any SDTMv domains, then please leave
date_cut_data empty, in which case a default value of NULL will be used.")
  }

  if (!is.null(dm_cut)){
    assert_data_frame(dm_cut,
                    required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE, DCUT_TEMP_DTHCHANGE),
                    #msg = "Required variables `DCUT_TEMP_REMOVE` and `DCUT_TEMP_DTHCHANGE` are missing from dm_cut dataset"
  )
  }

  if (!is.null(no_cut_list)){
    assert_that(is.list(no_cut_list) & !is.data.frame(no_cut_list),
                msg = "no_cut_list must be a list. \n
Note: If you have not used or do not with to view the SDTMv domains where no cut has been applied, then please leave
no_cut_list empty, in which case a default value of NULL will be used.")
  }

  rmarkdown::render(system.file(package = "datacutr",
                                path = "/inst/read-out/read_out.Rmd"),
                    output_file = paste("datacut_", format(Sys.time(), "%d-%b-%Y_%H:%M:%S", ".html")),
                    output_dir = out_path)
}
