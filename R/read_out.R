# Generate read-out file function
# alt name summarize_cut()
read_out <- function(dcut = NULL,
                     patient_cut_data = NULL,
                     date_cut_data = NULL,
                     dm_cut = NULL,
                     final_data = NULL,
                     no_cut_list = NULL,
                     out_path = "~") {
  if (dcut) {
    assert_data_frame(dcut,
                    required_vars = exprs(USUBJID, DCUTDTC)
  )
  }

  if (patient_cut_data){
    assert_that(is.list(patient_cut_data),
                msg = "patient_cut_v must be a vector. \n
Note: If you have not used or do not with to view patient cut on any SDTMv domains, then please leave
patient_cut_data empty, in which case a default value of vector() will be used.")
  }

  if (date_cut_data){
    assert_that(is.list(date_cut_data),
                msg = "date_cut_v must be a vector. \n
Note: If you have not used or do not with to view date cut on any SDTMv domains, then please leave
date_cut empty_data, in which case a default value of vector() will be used")
  }

  if (dm_cut){
    assert_data_frame(dm_cut,
                    required_vars = exprs(USUBJID, DCUT_TEMP_REMOVE, DCUT_TEMP_DTHCHANGE)
  )
  }

  rmarkdown::render(system.file(package = "datacutr",
                                path = "/inst/read-out/read_out.Rmd"),
                    output_file = paste("datacut_", format(Sys.time(), "%d-%b-%Y_%H:%M:%S", ".html")),
                    output_dir = out_path)
}
