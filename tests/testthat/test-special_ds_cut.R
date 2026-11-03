library(dplyr)
library(lubridate)

dcut <- tibble::tribble(
  ~USUBJID,      ~DCUTDTC,              ~DCUTDTM,
  "01-701-1015", "2014-10-20T23:59:59", ymd_hms("2014-10-20T23:59:59"),
  "01-701-1023", "2014-10-20T23:59:59", ymd_hms("2014-10-20T23:59:59"),
  "01-701-1028", "2014-10-20T23:59:59", ymd_hms("2014-10-20T23:59:59")
)

dm <- tibble::tribble(
  ~USUBJID,      ~DTHDTC,      ~DTHFL,
  "01-701-1015", "2014-10-20", "Y",   # death on cut date — retained
  "01-701-1023", "2014-10-21", "Y",   # death after cut — cleared
  "01-701-1028", NA_character_, NA    # no death
)

ds_base <- tibble::tribble(
  ~USUBJID,      ~DSSEQ, ~DSDECOD,
  "01-701-1015", 1,      "COMPLETED",
  "01-701-1015", 2,      "DEATH",
  "01-701-1023", 1,      "COMPLETED",
  "01-701-1023", 2,      "DEATH",
  "01-701-1028", 1,      "COMPLETED"
)

dm_cut <- special_dm_cut(
  dataset_dm  = dm,
  dataset_cut = dcut,
  cut_var     = DCUTDTM
)

test_that("DS DEATH record flagged when death cleared in DM", {
  result <- special_ds_cut(dataset_ds = ds_base, dataset_dm_cut = dm_cut)

  # 01-701-1023 death after cut — DS DEATH record should be flagged
  expect_equal(
    result %>%
      filter(USUBJID == "01-701-1023", DSDECOD == "DEATH") %>%
      pull(DCUT_TEMP_REMOVE),
    "Y"
  )
})

test_that("DS DEATH record not flagged when death is within cut", {
  result <- special_ds_cut(dataset_ds = ds_base, dataset_dm_cut = dm_cut)

  # 01-701-1015 death on cut date — DS DEATH record should not be flagged
  expect_equal(
    result %>%
      filter(USUBJID == "01-701-1015", DSDECOD == "DEATH") %>%
      pull(DCUT_TEMP_REMOVE),
    NA_character_
  )
})

test_that("Non-DEATH DS records are never flagged by special_ds_cut", {
  result <- special_ds_cut(dataset_ds = ds_base, dataset_dm_cut = dm_cut)

  expect_true(all(
    is.na(result %>% filter(DSDECOD != "DEATH") %>% pull(DCUT_TEMP_REMOVE))
  ))
})

test_that("Existing DCUT_TEMP_REMOVE = 'Y' is preserved for non-DEATH records", {
  ds_preflagged <- ds_base %>%
    mutate(DCUT_TEMP_REMOVE = if_else(USUBJID == "01-701-1015" & DSSEQ == 1, "Y", NA_character_))

  result <- special_ds_cut(dataset_ds = ds_preflagged, dataset_dm_cut = dm_cut)

  expect_equal(
    result %>%
      filter(USUBJID == "01-701-1015", DSSEQ == 1) %>%
      pull(DCUT_TEMP_REMOVE),
    "Y"
  )
})

test_that("Subject with no death in DM has DS records unchanged", {
  result <- special_ds_cut(dataset_ds = ds_base, dataset_dm_cut = dm_cut)

  expect_true(all(
    is.na(result %>% filter(USUBJID == "01-701-1028") %>% pull(DCUT_TEMP_REMOVE))
  ))
})

test_that("Empty DS dataset returns empty dataset unchanged", {
  ds_empty <- ds_base[0, ]
  result <- special_ds_cut(dataset_ds = ds_empty, dataset_dm_cut = dm_cut)
  expect_equal(nrow(result), 0L)
  expect_equal(names(result), names(ds_empty))
})
