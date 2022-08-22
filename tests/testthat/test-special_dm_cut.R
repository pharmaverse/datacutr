
library(dplyr)
library(stringr)
library(lubridate)

test_that("special_dm_cut Test 1: <Explanation of the test>", {

  subj <- c("01-701-1015","01-701-1023","01-701-1028","01-701-1033","01-701-1047","01-701-1057","01-701-1097","01-701-1111","01-701-1115","01-701-1118")
  cutdt <- c("2014-10-20T23:59:59")
  dthdtclist <- c("","2014-10-20","2014-10-21","2014-10-19","2014-10-31","2025-10-20","2002-10-20","","2014","2014-11-20")
  dthflglist <- c("","Y","Y","Y","Y","Y","Y","Y","Y","")

  dcut <- data.frame(USUBJID=subj,
                     DCUTDTC=cutdt) %>%
    mutate(DCUTDT = ymd_hms(DCUTDTC)) %>%
    as_tibble()

  dm <- data.frame(USUBJID=subj,
                   DTHDTC=dthdtclist,
                   DTHFL=dthflglist) %>%
    mutate(DTHDT = ymd(DTHDTC)) %>%
    as_tibble()

  expected_output <- mutate(dm_temp, )

  expect_dfs_equal(speci <- al_dm_cut(dataset_dm=dm_temp,
                                  dataset_cut=dcut,
                                  cut_var=DCUTDT,
                                  dthcut_var=DCUT_TEMP_DTHDT)
                   , expected_output)

})
