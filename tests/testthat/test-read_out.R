# Source data ------------------------------------------------

sc <- tibble::tribble(
    ~USUBJID, ~SCORRES, ~DCUT_TEMP_REMOVE,
    "AB12345-001",      "A",                NA,
    "AB12345-002",      "B",                NA,
    "AB12345-003",      "C",                NA,
    "AB12345-004",      "D",                NA,
    "AB12345-005",      "E",               "Y"
  )

ds <- tibble::tribble(
           ~USUBJID,        ~DSDECOD,     ~DSSTDTC, ~DCUT_TEMP_REMOVE,
      "AB12345-001", "RANDOMIZATION", "2022-06-01",                NA,
      "AB12345-002", "RANDOMIZATION", "2022-06-02",                NA,
      "AB12345-003", "RANDOMIZATION", "2022-06-03",                NA,
      "AB12345-004", "RANDOMIZATION", "2022-06-04",                NA,
      "AB12345-005", "RANDOMIZATION", "2022-10-05",               "Y"
      )

ae <- tibble::tribble(
    ~USUBJID, ~AETERM,     ~AESTDTC, ~DCUT_TEMP_SDTM_DATE,    ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_REMOVE,
    "AB12345-001",   "AE1", "2022-06-01",         "2022-06-01", "2022-06-04 23:59:59",                NA,
    "AB12345-002",   "AE2", "2022-06-30",         "2022-06-30", "2022-06-04 23:59:59",               "Y",
    "AB12345-003",   "AE3", "2022-07-01",         "2022-07-01", "2022-06-04 23:59:59",               "Y",
    "AB12345-004",   "AE4", "2022-05-04",         "2022-05-04", "2022-06-04 23:59:59",                NA,
    "AB12345-005",   "AE5", "2022-12-01",         "2022-12-01",                    NA,               "Y"
  )

lb <- tibble::tribble(
  ~USUBJID, ~LBORRES,       ~LBDTC, ~DCUT_TEMP_SDTM_DATE,    ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_REMOVE,
  "AB12345-001",        1, "2022-06-01",         "2022-06-01", "2022-06-04 23:59:59",                NA,
  "AB12345-002",        2, "2022-06-30",         "2022-06-30", "2022-06-04 23:59:59",               "Y",
  "AB12345-003",        3, "2022-07-01",         "2022-07-01", "2022-06-04 23:59:59",               "Y",
  "AB12345-004",        4, "2022-05-04",         "2022-05-04", "2022-06-04 23:59:59",                NA,
  "AB12345-005",        5, "2022-12-01",         "2022-12-01",                    NA,               "Y"
)

ts <- tibble::tribble(
  ~USUBJID, ~TSVAL,
  "AB12345-001",      1,
  "AB12345-002",      2,
  "AB12345-003",      3,
  "AB12345-004",      4,
  "AB12345-005",      5
)

# Create dcut & cut dataset lists ----------------------------------------------------------

dcut <- tibble::tribble(
  ~USUBJID,     ~DCUTDTC,              ~DCUTDTM,              ~DCUTDESC,
  "AB12345-001", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date",
  "AB12345-002", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date",
  "AB12345-003", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date",
  "AB12345-004", "2022-06-04", "2022-06-04 23:59:59", "Clinical Cutoff Date"
)

pt_cut_data <- c(ds, sc)

dt_cut_data <- c(ae, lb)

no_cut_ls <- c(ts)

dm_cut <- tibble::tribble(
          ~USUBJID, ~DTHFL,      ~DTHDTC, ~DCUT_TEMP_REMOVE, ~DCUT_TEMP_DTHDT,    ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_DTHCHANGE,
          "AB12345-001",    "Y", "2022-06-01",                NA,     "2022-06-01", "2022-06-04 23:59:59",                   NA,
          "AB12345-002",     NA,           NA,                NA,               NA, "2022-06-04 23:59:59",                   NA,
          "AB12345-003",    "Y", "2022-07-01",                NA,     "2022-07-01", "2022-06-04 23:59:59",                  "Y",
          "AB12345-004",     NA,           NA,                NA,               NA, "2022-06-04 23:59:59",                   NA,
          "AB12345-005",    "Y", "2022-12-01",               "Y",     "2022-12-01",                    NA,                   NA
        )

# Final Data ------------------------------------------------

source_data <- list(
  ds = datacutr_ds, dm = datacutr_dm, ae = datacutr_ae,
  sc = datacutr_sc, lb = datacutr_lb, ts = datacutr_ts
)
# Expected final data --------- ------------------------------------------------

ds_cut <- tibble::tribble(
  ~USUBJID, ~DSDECOD, ~DSSTDTC,
  "AB12345-001", "RANDOMIZATION", "2022-06-01",
  "AB12345-002", "RANDOMIZATION", "2022-06-02",
  "AB12345-003", "RANDOMIZATION", "2022-06-03",
  "AB12345-004", "RANDOMIZATION", "2022-06-04",
)
dm_cut2 <- tibble::tribble(
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
final_data <- list(
  dcut = dcut, dm = dm_cut2, sc = sc_cut, ds = ds_cut,
  ae = ae_cut, lb = lb_cut, ts = ts_cut
)

# Testing ---------------------------------------------------------------------------------------------------------

# Test that .Rmd gives the expected result when all fields are filled / set to default -----------
# .Rmd saves to home directory
test_that("Correct .Rmd file is run successfully", {
  # Call read_out() to generate the .Rmd file
  result <- read_out(dcut,
                     patient_cut_data,
                     date_cut_data,
                     dm_cut,
                     final_data,
                     no_cut_list,
                     out_path = "~"
  )
  # Assert that the output file is generated successfully
  expect_true(file.exists(result))
})

# Test that .Rmd errors when invalid datasets are inputted -----------
# raw sdtmv data input
# cut data input

# Test that .Rmd is still produced when data cut fields are incorrect input types -----------
# patient_cut_data input is not a list
test_that("Correct .Rmd file is run successfully", {
  # Call read_out() to generate the .Rmd file
  result <- read_out(dcut,
                     patient_cut_data = ,
                     date_cut_data,
                     dm_cut,
                     final_data,
                     no_cut_list,
                     out_path = "~"
  )
  # Assert that the output file is generated successfully
  expect_true(file.exists(result))
})
