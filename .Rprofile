if (Sys.getenv("GITHUB_ACTIONS") == "" || (Sys.getenv("GITHUB_ACTIONS") == "true" && getRversion()$major == 4 && getRversion()$minor == 3)) {
  source("renv/activate.R")
} else {
  options(repos = c(CRAN = "https://cran.rstudio.com"))
}
