library(stringr)
library(dplyr)
library(lubridate)

dm_expect <- tibble::tribble(
  ~USUBJID, ~DTHDTC, ~DTHFL, ~DCUT_TEMP_DTHCHANGE, ~DCUT_TEMP_REMOVE, ~DCUTDTC,
  "01-701-1015", "", "", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1023", "2014-10-20", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1028", "2014-10-21", "Y", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1033", "2014-10-19", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1047", "2014-10-31", "Y", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1057", "2025-10-20", "Y", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1097", "2002-10-20", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1111", "", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1115", "", "Y", NA_character_, "Y", NA_character_,
  "01-701-1118", "2014-11-20", "", "Y", NA_character_, "2014-10-20T23:59:59",
) %>%
  mutate(DCUT_TEMP_DCUTDTM = ymd_hms(DCUTDTC)) %>%
  mutate(DCUT_TEMP_DTHDTC = if_else(DTHDTC != "", str_c(DTHDTC, "T00:00:00"), "")) %>%
  mutate(DCUT_TEMP_DTHDT = ymd_hms(DCUT_TEMP_DTHDTC)) %>%
  select(
    USUBJID, DTHDTC, DTHFL, DCUT_TEMP_REMOVE, DCUT_TEMP_DTHDT,
    DCUT_TEMP_DCUTDTM, DCUT_TEMP_DTHCHANGE
  )

dm <- dm_expect[1:3]

dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC,
  "01-701-1015", "2014-10-20T23:59:59",
  "01-701-1023", "2014-10-20T23:59:59",
  "01-701-1028", "2014-10-20T23:59:59",
  "01-701-1033", "2014-10-20T23:59:59",
  "01-701-1047", "2014-10-20T23:59:59",
  "01-701-1057", "2014-10-20T23:59:59",
  "01-701-1097", "2014-10-20T23:59:59",
  "01-701-1111", "2014-10-20T23:59:59",
  "01-701-1118", "2014-10-20T23:59:59",
) %>%
  mutate(DCUTDTM = ymd_hms(DCUTDTC))

test_that("Tests all expected outcomes", {
  testthat::expect_equal(
    special_dm_cut(
      dataset_dm = dm,
      dataset_cut = dcut,
      cut_var = DCUTDTM
    ),
    dm_expect
  )
})

test_that("Error thrown if cut_var is not a POSIXt input", {
  expect_error(
    special_dm_cut(
      dataset_dm = dm,
      dataset_cut = dcut,
      cut_var = DCUTDTC
    ),
    regexp = "cut_var is expected to be of date type POSIXt"
  )
})

dcut_na <- tibble::tribble(
  ~USUBJID, ~DCUTDTM,
  "01-701-1015", NA,
  "01-701-1023", NA,
  "01-701-1028", NA,
  "01-701-1033", NA,
  "01-701-1047", NA,
  "01-701-1057", NA,
  "01-701-1097", NA,
  "01-701-1111", NA,
  "01-701-1115", NA,
  "01-701-1118", NA
)

dm_expect_na <- tibble::tribble(
  ~USUBJID, ~DTHDTC, ~DTHFL, ~DCUT_TEMP_REMOVE,
  ~DCUT_TEMP_DTHDT, ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_DTHCHANGE,
  "01-701-1015", "", "", NA_character_,
  NA, NA, NA_character_,
  "01-701-1023", "2014-10-20", "Y", NA_character_,
  ymd_hms("2014-10-20T00:00:00"), NA, NA_character_,
  "01-701-1028", "2014-10-21", "Y", NA_character_,
  ymd_hms("2014-10-21T00:00:00"), NA, NA_character_,
  "01-701-1033", "2014-10-19", "Y", NA_character_,
  ymd_hms("2014-10-19T00:00:00"), NA, NA_character_,
  "01-701-1047", "2014-10-31", "Y", NA_character_,
  ymd_hms("2014-10-31T00:00:00"), NA, NA_character_,
  "01-701-1057", "2025-10-20", "Y", NA_character_,
  ymd_hms("2025-10-20T00:00:00"), NA, NA_character_,
  "01-701-1097", "2002-10-20", "Y", NA_character_,
  ymd_hms("2002-10-20T00:00:00"), NA, NA_character_,
  "01-701-1111", "", "Y", NA_character_,
  NA, NA, NA_character_,
  "01-701-1115", "", "Y", NA_character_,
  NA, NA, NA_character_,
  "01-701-1118", "2014-11-20", "", NA_character_,
  ymd_hms("2014-11-20T00:00:00"), NA, NA_character_
)

test_that("Tests all expected outcomes when datacut date is NA", {
  testthat::expect_equal(
    special_dm_cut(
      dataset_dm = dm,
      dataset_cut = dcut_na,
      cut_var = DCUTDTM
    ),
    dm_expect_na
  )
})
