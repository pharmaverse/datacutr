library(stringr)
library(dplyr)
library(lubridate)

test_that("special_dm_cut Test 1: Test outcomes", {

  dm_expect <- tibble::tribble(
    ~USUBJID,      ~DTHDTC,      ~DTHFL, ~DCUT_TEMP_DTHCHANGE, ~DCUT_TEMP_REMOVE, ~DCUTDTC,
    "01-701-1015",           "",  "",    NA,                   NA, "2014-10-20T23:59:59",
    "01-701-1023", "2014-10-20", "Y",    NA,                   NA, "2014-10-20T23:59:59",
    "01-701-1028", "2014-10-21", "Y",    "Y",                  NA, "2014-10-20T23:59:59",
    "01-701-1033", "2014-10-19", "Y",    NA,                   NA, "2014-10-20T23:59:59",
    "01-701-1047", "2014-10-31", "Y",    "Y",                  NA, "2014-10-20T23:59:59",
    "01-701-1057", "2025-10-20", "Y",    "Y",                  NA, "2014-10-20T23:59:59",
    "01-701-1097", "2002-10-20", "Y",    NA,                   NA, "2014-10-20T23:59:59",
    "01-701-1111",           "", "Y",    NA,                   NA, "2014-10-20T23:59:59",
    "01-701-1115",           "", "Y",    NA,                  "Y", NA,
    "01-701-1118", "2014-11-20",  "",    "Y",                  NA, "2014-10-20T23:59:59",
  ) %>%
    mutate(DCUT_TEMP_DCUTDTM = ymd_hms(DCUTDTC)) %>%
    mutate(DCUT_TEMP_DTHDTC = if_else(DTHDTC!="",str_c(DTHDTC,"T00:00:00"),"")) %>%
    mutate(DCUT_TEMP_DTHDT = ymd_hms(DCUT_TEMP_DTHDTC)) %>%
    select(USUBJID,DTHDTC,DTHFL,DCUT_TEMP_REMOVE,DCUT_TEMP_DTHDT,
           DCUT_TEMP_DCUTDTM,DCUT_TEMP_DTHCHANGE)

  dm <- dm_expect[1:3]

  dcut <- tibble::tribble(
    ~USUBJID,      ~DCUTDTC,
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

  testthat::expect_equal(special_dm_cut(dataset_dm=dm,
                                  dataset_cut=dcut,
                                  cut_var=DCUTDTM),
               dm_expect)

})
