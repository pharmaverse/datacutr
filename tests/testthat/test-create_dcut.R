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
