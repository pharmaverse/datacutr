# Test 1 - One observation is after cut and one patient not in DCUT is flagged to be removed

input_ae <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC,
  "my_study", "subject1", 1, "2020-01-02",
  "my_study", "subject1", 2, "2020-08-31",
  "my_study", "subject1", 3, "2020-10-10",
  "my_study", "subject2", 2, "2020-02-20",
  "my_study", "subject3", 1, "2020-03-02",
  "my_study", "subject4", 1, "2020-11-02"
)

input_dcut <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~DCUTDTM,
  "my_study", "subject1", ymd_hms("2020-10-11T23:59:59"),
  "my_study", "subject2", ymd_hms("2020-10-11T23:59:59"),
  "my_study", "subject4", ymd_hms("2020-10-11T23:59:59")
)


expected_ae <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_SDTM_DATE, ~DCUT_TEMP_DCUTDTM,
  ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2020-01-02", ymd_hms("2020-01-02T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject1", 2, "2020-08-31", ymd_hms("2020-08-31T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject1", 3, "2020-10-10", ymd_hms("2020-10-10T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject2", 2, "2020-02-20", ymd_hms("2020-02-20T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject3", 1, "2020-03-02", ymd_hms("2020-03-02T00:00:00"),
  NA, "Y",
  "my_study", "subject4", 1, "2020-11-02", ymd_hms("2020-11-02T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), "Y"
)

test_that("One observation is after cut and one patient not in DCUT is flagged to be removed", {
  expect_equal(
    date_cut(
      dataset_sdtm = input_ae,
      sdtm_date_var = AESTDTC,
      dataset_cut = input_dcut,
      cut_var = DCUTDTM
    ),
    expected_ae
  )
})


# Test 2 - One observations is after cut and partial/missing dates in SDTMv dataset

input_ae2 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC,
  "my_study", "subject1", 1, "2020-12",
  "my_study", "subject1", 2, "2020-08-31",
  "my_study", "subject1", 3, "2020-10-10T13:03",
  "my_study", "subject2", 2, "2020-02-20T10:30:54",
  "my_study", "subject3", 1, "2020-03-02",
  "my_study", "subject4", 1, ""
)

input_dcut2 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~DCUTDTM,
  "my_study", "subject1", ymd_hms("2020-10-11T23:59:59"),
  "my_study", "subject2", ymd_hms("2020-10-11T23:59:59"),
  "my_study", "subject3", ymd_hms("2020-10-11T23:59:59"),
  "my_study", "subject4", ymd_hms("2020-10-11T23:59:59")
)


expected_ae2 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_SDTM_DATE, ~DCUT_TEMP_DCUTDTM,
  ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2020-12", ymd_hms("2020-12-01T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), "Y",
  "my_study", "subject1", 2, "2020-08-31", ymd_hms("2020-08-31T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject1", 3, "2020-10-10T13:03", ymd_hms("2020-10-10T13:03:00"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject2", 2, "2020-02-20T10:30:54", ymd_hms("2020-02-20T10:30:54"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject3", 1, "2020-03-02", ymd_hms("2020-03-02T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), NA_character_,
  "my_study", "subject4", 1, "", NA, ymd_hms("2020-10-11T23:59:59"), NA_character_
)

test_that("One observations is after cut and partial/missing dates in SDTMv dataset", {
  expect_equal(
    date_cut(
      dataset_sdtm = input_ae2,
      sdtm_date_var = AESTDTC,
      dataset_cut = input_dcut2,
      cut_var = DCUTDTM
    ),
    expected_ae2
  )
})


# Test 3 - Datacut date and SDTMv date are the same, extra patients in DCUT

input_ae3 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC,
  "my_study", "subject1", 1, "2020-01-02T23:59:59",
)

input_dcut3 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~DCUTDTM,
  "my_study", "subject1", ymd_hms("2020-01-02T23:59:59"),
  "my_study", "subject2", ymd_hms("2020-01-02T23:59:59"),
  "my_study", "subject4", ymd_hms("2020-01-02T23:59:59")
)


expected_ae3 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_SDTM_DATE, ~DCUT_TEMP_DCUTDTM,
  ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2020-01-02T23:59:59", ymd_hms("2020-01-02T23:59:59"),
  ymd_hms("2020-01-02T23:59:59"), NA_character_
)

test_that("Datacut date and SDTMv date are the same, extra patients in DCUT", {
  expect_equal(
    date_cut(
      dataset_sdtm = input_ae3,
      sdtm_date_var = AESTDTC,
      dataset_cut = input_dcut3,
      cut_var = DCUTDTM
    ),
    expected_ae3
  )
})


# Test 4 - All SDTMv dates are after datacut date

input_ae4 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC,
  "my_study", "subject1", 1, "2021-01-02",
  "my_study", "subject1", 2, "2021-08-31",
  "my_study", "subject1", 3, "2021-10-10",
  "my_study", "subject2", 2, "2021-02-20",
  "my_study", "subject3", 1, "2021-03-02"
)

input_dcut4 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~DCUTDTM,
  "my_study", "subject1", ymd_hms("2020-10-11T23:59:59"),
  "my_study", "subject2", ymd_hms("2020-10-11T23:59:59"),
  "my_study", "subject3", ymd_hms("2020-10-11T23:59:59")
)


expected_ae4 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_SDTM_DATE, ~DCUT_TEMP_DCUTDTM,
  ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2021-01-02", ymd_hms("2021-01-02T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), "Y",
  "my_study", "subject1", 2, "2021-08-31", ymd_hms("2021-08-31T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), "Y",
  "my_study", "subject1", 3, "2021-10-10", ymd_hms("2021-10-10T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), "Y",
  "my_study", "subject2", 2, "2021-02-20", ymd_hms("2021-02-20T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), "Y",
  "my_study", "subject3", 1, "2021-03-02", ymd_hms("2021-03-02T00:00:00"),
  ymd_hms("2020-10-11T23:59:59"), "Y"
)

test_that("All SDTMv dates are after datacut date", {
  expect_equal(
    date_cut(
      dataset_sdtm = input_ae4,
      sdtm_date_var = AESTDTC,
      dataset_cut = input_dcut4,
      cut_var = DCUTDTM
    ),
    expected_ae4
  )
})

# Test 5 - Datacut date is NA

input_ae5 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC,
  "my_study", "subject1", 1, "2021-01-02",
  "my_study", "subject1", 2, "2021-08-31",
  "my_study", "subject1", 3, "2021-10-10",
  "my_study", "subject2", 2, "2021-02-20",
  "my_study", "subject3", 1, "2021-03-02"
)

input_dcut5 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~DCUTDTM,
  "my_study", "subject1", NA,
  "my_study", "subject2", NA,
  "my_study", "subject3", NA
)


expected_ae5 <- tibble::tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_SDTM_DATE, ~DCUT_TEMP_DCUTDTM,
  ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2021-01-02", ymd_hms("2021-01-02T00:00:00"),
  NA, NA_character_,
  "my_study", "subject1", 2, "2021-08-31", ymd_hms("2021-08-31T00:00:00"),
  NA, NA_character_,
  "my_study", "subject1", 3, "2021-10-10", ymd_hms("2021-10-10T00:00:00"),
  NA, NA_character_,
  "my_study", "subject2", 2, "2021-02-20", ymd_hms("2021-02-20T00:00:00"),
  NA, NA_character_,
  "my_study", "subject3", 1, "2021-03-02", ymd_hms("2021-03-02T00:00:00"),
  NA, NA_character_
)

test_that("DCUTDTM is NA", {
  expect_equal(
    date_cut(
      dataset_sdtm = input_ae5,
      sdtm_date_var = AESTDTC,
      dataset_cut = input_dcut5,
      cut_var = DCUTDTM
    ),
    expected_ae5
  )
})
