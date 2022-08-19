# Test 1 - one patient not in DCUT is flagged to be removed

input_ae <- tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC,
  "my_study", "subject1", 1, "2020-01-02",
  "my_study", "subject1", 2, "2020-08-31",
  "my_study", "subject1", 3, "2020-10-10",
  "my_study", "subject2", 2, "2020-02-20",
  "my_study", "subject3", 1, "2020-03-02",
  "my_study", "subject4", 1, "2020-11-02"
)

input_dcut <- tribble(
  ~STUDYID, ~USUBJID, ~DCUTDT,
  "my_study", "subject1", "2020-02-20",
  "my_study", "subject2", "2020-02-20",
  "my_study", "subject4", "2020-02-20"
)


expected_ae <- tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2020-01-02", "",
  "my_study", "subject1", 2, "2020-08-31", "",
  "my_study", "subject1", 3, "2020-10-10", "",
  "my_study", "subject2", 2, "2020-02-20", "",
  "my_study", "subject3", 1, "2020-03-02", "Y",
  "my_study", "subject4", 1, "2020-11-02", ""
)

test_that("The one patient not in DCUT is flagged to be removed", {
  expect_equal(
    pt_cut(dataset_sdtm = input_ae,
           dataset_cut = input_dcut),
    expected_ae
  )
})


# Test 2 - multiple patients not in DCUT are flagged to be removed

input_dcut2 <- tribble(
  ~STUDYID, ~USUBJID, ~DCUTDT,
  "my_study", "subject2", "2020-02-20",
  "my_study", "subject4", "2020-02-20"
)


expected_ae2 <- tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2020-01-02", "Y",
  "my_study", "subject1", 2, "2020-08-31", "Y",
  "my_study", "subject1", 3, "2020-10-10", "Y",
  "my_study", "subject2", 2, "2020-02-20", "",
  "my_study", "subject3", 1, "2020-03-02", "Y",
  "my_study", "subject4", 1, "2020-11-02", ""
)

test_that("The multiple patients not in DCUT are flagged to be removed", {
  expect_equal(
    pt_cut(dataset_sdtm = input_ae,
           dataset_cut = input_dcut2),
    expected_ae2
  )
})


# Test 3 - no patients match in DCUT, all records should be flagged

input_dcut3 <- tribble(
  ~STUDYID, ~USUBJID, ~DCUTDT,
  "my_study", "subject5", "2020-02-20",
  "my_study", "subject6", "2020-02-20",
)


expected_ae3 <- tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2020-01-02", "Y",
  "my_study", "subject1", 2, "2020-08-31", "Y",
  "my_study", "subject1", 3, "2020-10-10", "Y",
  "my_study", "subject2", 2, "2020-02-20", "Y",
  "my_study", "subject3", 1, "2020-03-02", "Y",
  "my_study", "subject4", 1, "2020-11-02", "Y"
)

test_that("If no patients in DCUT match the dataset then all records are flagged to be removed", {
  expect_equal(
    pt_cut(dataset_sdtm = input_ae,
           dataset_cut = input_dcut3),
    expected_ae3
  )
})


# Test 4 - all patients in DCUT are in dataset, no records should be flagged

input_dcut4 <- tribble(
  ~STUDYID, ~USUBJID, ~DCUTDT,
  "my_study", "subject1", "2020-02-20",
  "my_study", "subject2", "2020-02-20",
  "my_study", "subject3", "2020-02-20",
  "my_study", "subject4", "2020-02-20",
)


expected_ae4 <- tribble(
  ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC, ~DCUT_TEMP_REMOVE,
  "my_study", "subject1", 1, "2020-01-02", "",
  "my_study", "subject1", 2, "2020-08-31", "",
  "my_study", "subject1", 3, "2020-10-10", "",
  "my_study", "subject2", 2, "2020-02-20", "",
  "my_study", "subject3", 1, "2020-03-02", "",
  "my_study", "subject4", 1, "2020-11-02", ""
)

test_that("If all patients in DCUT match the dataset then no records are flagged to be removed", {
  expect_equal(
    pt_cut(dataset_sdtm = input_ae,
           dataset_cut = input_dcut4),
    expected_ae4
  )
})


