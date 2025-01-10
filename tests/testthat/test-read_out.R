# Source data ------------------------------------------------

sc <- tibble::tribble(
  ~USUBJID, ~SCORRES, ~DCUT_TEMP_REMOVE,
  "AB12345-001", "A", NA,
  "AB12345-002", "B", NA,
  "AB12345-003", "C", NA,
  "AB12345-004", "D", NA,
  "AB12345-005", "E", "Y"
)

ds <- tibble::tribble(
  ~USUBJID, ~DSDECOD, ~DSSTDTC, ~DCUT_TEMP_REMOVE,
  "AB12345-001", "RANDOMIZATION", "2022-06-01", NA,
  "AB12345-002", "RANDOMIZATION", "2022-06-02", NA,
  "AB12345-003", "RANDOMIZATION", "2022-06-03", NA,
  "AB12345-004", "RANDOMIZATION", "2022-06-04", NA,
  "AB12345-005", "RANDOMIZATION", "2022-10-05", "Y"
)

ae <- tibble::tribble(
  ~USUBJID, ~AETERM, ~AESTDTC, ~DCUT_TEMP_SDTM_DATE, ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_REMOVE,
  "AB12345-001", "AE1", "2022-06-01", "2022-06-01", "2022-06-04 23:59:59", NA,
  "AB12345-002", "AE2", "2022-06-30", "2022-06-30", "2022-06-04 23:59:59", "Y",
  "AB12345-003", "AE3", "2022-07-01", "2022-07-01", "2022-06-04 23:59:59", "Y",
  "AB12345-004", "AE4", "2022-05-04", "2022-05-04", "2022-06-04 23:59:59", NA,
  "AB12345-005", "AE5", "2022-12-01", "2022-12-01", NA, "Y"
)

lb <- tibble::tribble(
  ~USUBJID, ~LBORRES, ~LBDTC, ~DCUT_TEMP_SDTM_DATE, ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_REMOVE,
  "AB12345-001", 1, "2022-06-01", "2022-06-01", "2022-06-04 23:59:59", NA,
  "AB12345-002", 2, "2022-06-30", "2022-06-30", "2022-06-04 23:59:59", "Y",
  "AB12345-003", 3, "2022-07-01", "2022-07-01", "2022-06-04 23:59:59", "Y",
  "AB12345-004", 4, "2022-05-04", "2022-05-04", "2022-06-04 23:59:59", NA,
  "AB12345-005", 5, "2022-12-01", "2022-12-01", NA, "Y"
)

ts <- tibble::tribble(
  ~USUBJID, ~TSVAL,
  "AB12345-001", 1,
  "AB12345-002", 2,
  "AB12345-003", 3,
  "AB12345-004", 4,
  "AB12345-005", 5
)

# Create dcut & cut dataset lists ----------------------------------------------------------

dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "AB12345-001", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date",
  "AB12345-002", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date",
  "AB12345-003", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date",
  "AB12345-004", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date"
)

pt_cut_data <- list(ds = ds, sc = sc)

dt_cut_data <- list(ae = ae, lb = lb)

no_cut_ls <- list(ts = ts)

dm_cut <- tibble::tribble(
  ~USUBJID, ~DTHFL, ~DTHDTC, ~DCUT_TEMP_REMOVE, ~DCUT_TEMP_DTHDT, ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_DTHCHANGE,
  "AB12345-001", "Y", "2022-06-01", NA, "2022-06-01", "2022-06-04 23:59:59", NA,
  "AB12345-002", NA, NA, NA, NA, "2022-06-04 23:59:59", NA,
  "AB12345-003", "Y", "2022-07-01", NA, "2022-07-01", "2022-06-04 23:59:59", "Y",
  "AB12345-004", NA, NA, NA, NA, "2022-06-04 23:59:59", NA,
  "AB12345-005", "Y", "2022-12-01", "Y", "2022-12-01", NA, NA
)

# Testing ---------------------------------------------------------------------------------------------------------

# Test that .Rmd gives the expected result when all fields are set to default or contain valid data -----------
# Correct .Rmd file is run successfully when fields contain correct data inputs
test_that("Correct .Rmd file is run successfully when fields contain correct data inputs", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  # Call read_out() to generate the .Rmd file
  result <- read_out(
    dcut = dcut,
    patient_cut_data = pt_cut_data,
    date_cut_data = dt_cut_data,
    dm_cut = dm_cut,
    no_cut_list = no_cut_ls,
    out_path = temp_dir
  )
  # Assert that the output file is generated successfully
  expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir))) > 0)
  unlink(temp_dir, recursive = TRUE)
})

# Test that Correct .Rmd file is ran successfully when fields are empty
test_that("Correct .Rmd file is ran successfully when fields are empty", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  # Call read_out() to generate the .Rmd file
  result <- read_out(out_path = temp_dir)
  # Assert that the output file is generated successfully
  expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir))) > 0)
  unlink(temp_dir, recursive = TRUE)
})

# Test read_out() errors when data cut fields are incorrect input types -----------
## DCUT ----
# Test that read_out() errors dcut data frame does not contain the var DCUTDTC
test_that("Test that read_out() errors dcut data frame does not contain the var DCUTDTC", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(read_out(
    dcut = sc,
    patient_cut_data = pt_cut_data,
    date_cut_data = dt_cut_data,
    dm_cut = dm_cut,
    no_cut_list = no_cut_ls,
    out_path = temp_dir
  ))
  unlink(temp_dir, recursive = TRUE)
})

## Patient_cut_data ----
# Test that read_out() errors when patient_cut_data input is not a list
test_that("Test that read_out() errors when patient_cut_data input is not a list", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(
    read_out(
      dcut = dcut,
      patient_cut_data = sc,
      date_cut_data = dt_cut_data,
      dm_cut = dm_cut,
      no_cut_list = no_cut_ls,
      out_path = temp_dir
    ),
    regexp = "patient_cut_data must be a list. \n
Note: If you have not used or do not with to view patient cut on any SDTMv domains, then
please leave patient_cut_data empty, in which case a default value of NULL will be used."
  )
  unlink(temp_dir, recursive = TRUE)
})

# Test that read_out() errors when elements in the patient_cut_data list are not data frames
test_that("Test that read_out() errors when elements in the patient_cut_data list are not data frames", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(read_out(
    dcut = dcut,
    patient_cut_data = list("sc", "ds"),
    date_cut_data = dt_cut_data,
    dm_cut = dm_cut,
    no_cut_list = no_cut_ls,
    out_path = temp_dir
  ))
  unlink(temp_dir, recursive = TRUE)
})

# Test that read_out() errors when data frames in patient_cut_data are unnamed
test_that("Test that read_out() errors when data frames in patient_cut_data are unnamed", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(
    read_out(
      dcut = dcut,
      patient_cut_data = list(sc, ds),
      date_cut_data = dt_cut_data,
      dm_cut = dm_cut,
      no_cut_list = no_cut_ls,
      out_path = temp_dir
    ),
    regexp = "All elements patient_cut_data must be named with corresponding domain"
  )
  unlink(temp_dir, recursive = TRUE)
})

## Date_cut_data ----
# Test that read_out() errors when date_cut_data input is not a list
test_that("Test that read_out() errors when date_cut_data input is not a list", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(
    read_out(
      dcut = dcut,
      patient_cut_data = pt_cut_data,
      date_cut_data = ae,
      dm_cut = dm_cut,
      no_cut_list = no_cut_ls,
      out_path = temp_dir
    ),
    regexp = "date_cut_data must be a list. \n
Note: If you have not used or do not with to view date cut on any SDTMv domains, then please
leave date_cut_data empty, in which case a default value of NULL will be used."
  )
  unlink(temp_dir, recursive = TRUE)
})

# Test that read_out() errors when elements in the date_cut_data list are not data frames
test_that("Test that read_out() errors when elements in the date_cut_data list are not data frames", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(read_out(
    dcut = dcut,
    patient_cut_data = pt_cut_data,
    date_cut_data = list("ae", "lb"),
    dm_cut = dm_cut,
    no_cut_list = no_cut_ls,
    out_path = temp_dir
  ))
  unlink(temp_dir, recursive = TRUE)
})

# Test that read_out() errors when data frames in date_cut_data are unnamed
test_that("Test that read_out() errors when data frames in date_cut_data are unnamed", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(
    read_out(
      dcut = dcut,
      patient_cut_data = pt_cut_data,
      date_cut_data = list(ae, lb),
      dm_cut = dm_cut,
      no_cut_list = no_cut_ls,
      out_path = temp_dir
    ),
    regexp = "All elements in date_cut_data must be named with corresponding domain"
  )
  unlink(temp_dir, recursive = TRUE)
})

## dm_cut ----
# Test that read_out() errors when dm_cut data frame does not contain the vars DCUT_TEMP_REMOVE & DCUT_TEMP_DTHCHANG
test_that("Test that read_out() errors when dm_cut data frame does not contain the vars DCUT_TEMP_REMOVE & DCUT_TEMP_DTHCHANGE", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(read_out(
    dcut = dcut,
    patient_cut_data = pt_cut_data,
    date_cut_data = dt_cut_data,
    dm_cut = sc,
    no_cut_list = no_cut_ls,
    out_path = temp_dir
  ))
  unlink(temp_dir, recursive = TRUE)
})


## no_cut_list ----
# Test that read_out() errors when no_cut_list is not a list
test_that("Test that read_out() errors when no_cut_list is not a list", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(
    read_out(
      dcut = dcut,
      patient_cut_data = pt_cut_data,
      date_cut_data = dt_cut_data,
      dm_cut = dm_cut,
      no_cut_list = ds,
      out_path = temp_dir
    ),
    regexp = "no_cut_list must be a list. \n
Note: If you have not used or do not with to view the SDTMv domains where no cut has been
applied, then please leave no_cut_list empty, in which case a default value of NULL will be
used."
  )
  unlink(temp_dir, recursive = TRUE)
})

# Test that read_out() errors when elements in the no_cut_list list are not data frames
test_that("Test that read_out() errors when elements in the no_cut_list list are not data frames", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(read_out(
    dcut = dcut,
    patient_cut_data = pt_cut_data,
    date_cut_data = dt_cut_data,
    dm_cut = dm_cut,
    no_cut_list = ls("ts"),
    out_path = temp_dir
  ))
  unlink(temp_dir, recursive = TRUE)
})

# Test that read_out() errors when elements in the no_cut_list list are not named with the corresponding domain
test_that("Test that read_out() errors when elements in the no_cut_list list are not named with the corresponding domain", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  expect_error(
    read_out(
      dcut = dcut,
      patient_cut_data = pt_cut_data,
      date_cut_data = dt_cut_data,
      dm_cut = dm_cut,
      no_cut_list = list(ts, ae),
      out_path = temp_dir
    ),
    regexp = "All elements in no_cut_list must be named with corresponding domain"
  )
  unlink(temp_dir, recursive = TRUE)
})
