# Generate read-out file function
# alt name summarize_cut()
read_out <- function(patient_cut_data,
                     date_cut_data,
                     dm_cut,
                     final_data,
                     no_cut_list,
                     out_path = "~") {
  rmarkdown::render(system.file(package = "datacutr",
                                path = "/inst/read-out/read_out.Rmd"),
                    #output_file = paste("read_out_", format(Sys.time(), "%Y-%m-%d", ".html")),
                    output_dir = out_path)
}
