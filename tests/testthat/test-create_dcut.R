# Test 1 - One observation in DCUT

input_ds <- tibble::tribble(
  ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSTDTC,
  "subject1", 1, "INFORMED CONSENT", "2020-06-23",
  "subject1", 2, "RANDOMIZATION", "2020-08-22",
  "subject1", 3, "WITHDRAWAL BY SUBJECT", "2020-05-01",
  "subject2", 1, "INFORMED CONSENT", "2020-07-13",
  "subject3", 1, "INFORMED CONSENT", "2020-06-03",
  "subject4", 1, "INFORMED CONSENT", "2021-01-01",
  "subject4", 2, "RANDOMIZATION", "2023-01-01"
)

expected_dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "subject1", "2022-01-01", ymd_hms("2022-01-01 23:59:59"), "Clinical Cutoff Date"
)

test_that("One observation in DCUT", {
  expect_equal(
    create_dcut(
      dataset_ds = input_ds,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "RANDOMIZATION",
      cut_date = "2022-01-01",
      cut_description = "Clinical Cutoff Date"
    ),
    expected_dcut
  )
})

# Test 2 - Cut date as NA
expected_dcutna <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "subject1", NA, ymd_hms(NA), "Patients with Informed Consent",
  "subject2", NA, ymd_hms(NA), "Patients with Informed Consent",
  "subject3", NA, ymd_hms(NA), "Patients with Informed Consent",
  "subject4", NA, ymd_hms(NA), "Patients with Informed Consent"
)

test_that("One observation in DCUT", {
  expect_equal(
    create_dcut(
      dataset_ds = input_ds,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "INFORMED CONSENT",
      cut_date = NA,
      cut_description = "Patients with Informed Consent"
    ),
    expected_dcutna
  )
})

# Test 3 - Cut date as NULL
test_that("Cut Date of NULL errors", {
  expect_error(
    create_dcut(
      dataset_ds = input_ds,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "INFORMED CONSENT",
      cut_date = NULL,
      cut_description = "Patients with Informed Consent"
    ),
    regexp = "Cut date is NULL, please populate as NA if you do not want to perform a data cut"
  )
})

# Test 4 - Cut date in DDMMMYYYY format
test_that("One observation in DCUT", {
  expect_equal(
    create_dcut(
      dataset_ds = input_ds,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "RANDOMIZATION",
      cut_date = "01JAN2022",
      cut_description = "Clinical Cutoff Date"
    ),
    expected_dcut
  )
})

# Test 4 - Filter is NULL
input_ds_ic_only <- tibble::tribble(
  ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSTDTC,
  "subject1", 1, "INFORMED CONSENT", "2020-06-23",
  "subject2", 1, "INFORMED CONSENT", "2020-07-13",
  "subject3", 1, "INFORMED CONSENT", "2020-06-03",
  "subject4", 1, "INFORMED CONSENT", "2021-01-01"
)

expected_dcut_filter_null <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "subject1", "2023-01-01", ymd_hms("2023-01-01 23:59:59"), "Clinical Cutoff Date",
  "subject2", "2023-01-01", ymd_hms("2023-01-01 23:59:59"), "Clinical Cutoff Date",
  "subject3", "2023-01-01", ymd_hms("2023-01-01 23:59:59"), "Clinical Cutoff Date",
  "subject4", "2023-01-01", ymd_hms("2023-01-01 23:59:59"), "Clinical Cutoff Date"
)

test_that("Filter is NULL", {
  expect_equal(
    create_dcut(
      dataset_ds = input_ds_ic_only,
      ds_date_var = DSSTDTC,
      cut_date = "2023-01-01",
      cut_description = "Clinical Cutoff Date"
    ),
    expected_dcut_filter_null
  )
})

# Test 5 - Datacut dataset is empty
expected_dcut_empty <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
)

expected_dcut_empty$USUBJID <- as.character(expected_dcut_empty$USUBJID)
expected_dcut_empty$DCUTDTC <- as.character(expected_dcut_empty$DCUTDTC)
expected_dcut_empty$DCUTDTM <- as.POSIXct(expected_dcut_empty$DCUTDTM)
attr(expected_dcut_empty$DCUTDTM, "tzone") <- "UTC"
expected_dcut_empty$DCUTDESC <- as.character(expected_dcut_empty$DCUTDESC)

test_that("Datacut dataset is empty", {
  expect_equal(
    create_dcut(
      dataset_ds = input_ds_ic_only,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "RANDOMIZATION",
      cut_date = "2023-01-01",
      cut_description = "Clinical Cutoff Date"
    ),
    expected_dcut_empty
  )
})


# Test 6 - ds_date_var values are not in ISO 8601 format (e.g., DDMMMYYYY)

input_ds_bad_fmt <- tibble::tribble(
  ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSTDTC,
  "subject1", 1, "RANDOMIZATION", "23JUN2020",
  "subject2", 1, "RANDOMIZATION", "13JUL2020"
)

test_that("Error thrown when ds_date_var contains non-ISO-8601 dates", {
  expect_error(
    create_dcut(
      dataset_ds = input_ds_bad_fmt,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "RANDOMIZATION",
      cut_date = "2022-01-01",
      cut_description = "Clinical Cutoff Date"
    ),
    regexp = "contains datetimes in the incorrect format"
  )
})


# Test 7 - cut_date is a logically invalid date (month 13)

input_ds_valid <- tibble::tribble(
  ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSTDTC,
  "subject1", 1, "RANDOMIZATION", "2020-06-23"
)

test_that("Error thrown when cut_date is a logically invalid date", {
  expect_error(
    create_dcut(
      dataset_ds = input_ds_valid,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "RANDOMIZATION",
      cut_date = "2022-13-01",
      cut_description = "Clinical Cutoff Date"
    ),
    regexp = "is an invalid datetime"
  )
})


# Test 8 - cut_date in ISO 8601 datetime format (with T component)

expected_dcut_datetime <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "subject1", "2022-01-01T12:00:00", ymd_hms("2022-01-01 12:00:00"), "Clinical Cutoff Date"
)

test_that("cut_date in ISO 8601 datetime format is handled correctly", {
  expect_equal(
    create_dcut(
      dataset_ds = input_ds_valid,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "RANDOMIZATION",
      cut_date = "2022-01-01T12:00:00",
      cut_description = "Clinical Cutoff Date"
    ),
    expected_dcut_datetime
  )
})


# Test 9 - Filtered DS dataset contains duplicate USUBJIDs

input_ds_dups <- tibble::tribble(
  ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSTDTC,
  "subject1", 1, "RANDOMIZATION", "2020-06-01",
  "subject1", 2, "RANDOMIZATION", "2020-08-22"
)

test_that("Error thrown when filtered DS dataset has duplicate USUBJIDs", {
  expect_error(
    create_dcut(
      dataset_ds = input_ds_dups,
      ds_date_var = DSSTDTC,
      filter = DSDECOD == "RANDOMIZATION",
      cut_date = "2022-01-01",
      cut_description = "Clinical Cutoff Date"
    ),
    regexp = "Duplicate patients in the final returned dataset"
  )
})
