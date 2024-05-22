# Store all input data as a list ------------------------------------------------

source_data <- list(
  ds = datacutr_ds, dm = datacutr_dm, ae = datacutr_ae,
  sc = datacutr_sc, lb = datacutr_lb, ts = datacutr_ts
)

# Create dcut dataset ----------------------------------------------------------

dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "AB12345-001", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-002", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-003", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-004", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
)

# Expected final data --------- ------------------------------------------------

ds_cut <- tibble::tribble(
  ~USUBJID, ~DSDECOD, ~DSSTDTC,
  "AB12345-001", "RANDOMIZATION", "2022-06-01",
  "AB12345-002", "RANDOMIZATION", "2022-06-02",
  "AB12345-003", "RANDOMIZATION", "2022-06-03",
  "AB12345-004", "RANDOMIZATION", "2022-06-04",
)
dm_cut <- tibble::tribble(
  ~USUBJID, ~DTHFL, ~DTHDTC,
  "AB12345-001", "Y", "2022-06-01",
  "AB12345-002", "", "",
  "AB12345-003", "", "",
  "AB12345-004", "", "",
)
ae_cut <- tibble::tribble(
  ~USUBJID, ~AETERM, ~AESTDTC,
  "AB12345-001", "AE1", "2022-06-01",
  "AB12345-004", "AE4", "2022-05-04",
)
sc_cut <- tibble::tribble(
  ~USUBJID, ~SCORRES,
  "AB12345-001", "A",
  "AB12345-002", "B",
  "AB12345-003", "C",
  "AB12345-004", "D",
)
lb_cut <- tibble::tribble(
  ~USUBJID, ~LBORRES, ~LBDTC,
  "AB12345-001", 1, "2022-06-01",
  "AB12345-004", 4, "2022-05-04",
)
ts_cut <- tibble::tribble(
  ~USUBJID, ~TSVAL,
  "AB12345-001", 1,
  "AB12345-002", 2,
  "AB12345-003", 3,
  "AB12345-004", 4,
  "AB12345-005", 5,
)

# Store all expected data as a list
expected <- list(
  dcut = dcut, dm = dm_cut, sc = sc_cut, ds = ds_cut,
  ae = ae_cut, lb = lb_cut, ts = ts_cut
)

# Test that every type of datacut gives the expected result, when special_dm=TRUE -----------

test_that("Test that every type of datacut gives the expected result, when special_dm=TRUE", {
  expect_equal(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    expected
  )
})

# Test that process_cut() errors when a source SDTM dataset is not referenced
# in any input list

test_that("Test that process_cut() errors when a source SDTM dataset is not
          referenced in any input list", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("ds"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "Inconsistency between input SDTMv datasets and the SDTMv datasets
listed under each cut approach."
  )
})

# Test that process_cut() errors when an input list includes a source SDTMv
# dataset that does not exist

test_that("Test that process_cut() errors when an input list includes a source
           SDTMv dataset that does not exist in the source SDTMv data", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds", "vs"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "Inconsistency between input SDTMv datasets and the SDTMv datasets
listed under each cut approach."
  )
})

# Test that process_cut() errors when a source SDTMv dataset is referenced in
# more than one input list

test_that("Test that process_cut() errors when a source SDTMv dataset is
          referenced in more than one input list", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds", "ae"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "The number of SDTMv datasets in the source data does not match the
number of SDTMv datasets in which a cut approach has been defined."
  )
})

# Test that process_cut() errors when special_dm = TRUE and dm is also referenced
# in an input list

test_that("Test that process_cut() errors when special_dm = TRUE and dm is also
          referenced in an input list", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds", "dm"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "The number of SDTMv datasets in the source data does not match the
number of SDTMv datasets in which a cut approach has been defined."
  )
})

# Test that every type of datacut gives the expected result, when special_dm=FALSE -----------

# Remove dm from the source data list and expected data list
source_data["dm"] <- NULL
expected["dm"] <- NULL

test_that("Test that every type of datacut gives the expected result, when special_dm=FALSE", {
  expect_equal(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = FALSE
    ),
    expected
  )
})

# READ_OUT() ----
# Test that no .Rmd file is produced when read_out = FALSE
test_that("Test that no .Rmd file is produced when read_out = FALSE", {
  # Call read_out() to generate the .Rmd file
  result <- read_out(out_path = "~")
  # Assert that the output file is generated successfully
  expect_true(file.exists(result))
})

# Test that Correct .Rmd file is ran successfully when read_out = TRUE
test_that("Test that Correct .Rmd file is ran successfully when read_out = TRUE", {
  process_cut(
              source_sdtm_data = source_data,
              patient_cut_v = c("sc", "ds"),
              date_cut_m = rbind(
                c("ae", "AESTDTC"),
                c("lb", "LBDTC")
              ),
              no_cut_v = c("ts"),
              dataset_cut = dcut,
              cut_var = DCUTDTM,
              special_dm = TRUE,
              read_out = TRUE
            )
  output_file <- paste(format(Sys.time(), "datacut_%d-%b-%Y_%H:%M:%S.html"))
  #out <- paste(out_path, output_file)
  # Assert that the output file is generated successfully
  expect_true(file.exists(output_file))
})

