
library(dplyr)
library(stringr)
library(lubridate)

test_that("special_dm_cut Test 1: Test outcomes", {

  subj <- c("01-701-1015","01-701-1023","01-701-1028","01-701-1033","01-701-1047","01-701-1057","01-701-1097","01-701-1111","01-701-1115","01-701-1118")
  cutdt <- c("2014-10-20T23:59:59")
  dthdtclist <- c("","2014-10-20","2014-10-21","2014-10-19","2014-10-31","2025-10-20","2002-10-20","","","2014-11-20")
  dthflglist <- c("","Y","Y","Y","Y","Y","Y","Y","Y","")

  tibble::tribble(
    ~USUBJID, ~DTHDTC, ~DTHFL, ~DTHDT, ~DCUTDT, ~DCUT_TEMP_DTHCHANGE, ~DCUT_TEMP_REMOVE,
    "01-701-1015",           "",  "",           NA,                    "",  "", "Y",
    "01-701-1023", "20/10/2014", "Y", "20/10/2014", "2014-10-20T23:59:60", "Y", "",
    "01-701-1028", "21/10/2014", "Y", "21/10/2014", "2014-10-20T23:59:61",  "", "",
    "01-701-1033", "19/10/2014", "Y", "19/10/2014", "2014-10-20T23:59:62", "Y", "",
    "01-701-1047", "31/10/2014", "Y", "31/10/2014", "2014-10-20T23:59:63",  "", "",
    "01-701-1057", "20/10/2025", "Y", "20/10/2025", "2014-10-20T23:59:64",  "", "",
    "01-701-1097", "20/10/2002", "Y", "20/10/2002", "2014-10-20T23:59:65", "Y", "",
    "01-701-1111",           "", "Y",           NA, "2014-10-20T23:59:66", "Y", "",
    "01-701-1115",           "", "Y",           NA, "2014-10-20T23:59:67", "Y", "",
    "01-701-1118", "20/11/2014",  "", "20/11/2014", "2014-10-20T23:59:68",  "", "",
  )

  dcut <- data.frame(USUBJID=subj,
                     DCUTDTC=cutdt) %>%
    mutate(DCUTDT = ymd_hms(DCUTDTC)) %>%
    as_tibble()

  dm <- data.frame(USUBJID=subj,
                   DTHDTC=dthdtclist,
                   DTHFL=dthflglist) %>%
    mutate(DTHDT = ymd(DTHDTC)) %>%
    as_tibble()

  exp_resultlist <- c("","Y","","Y","","","Y","Y","Y","")
  expected_output <- data.frame(dm,
                                exp_resultlist)


  testthat::expect_equal(special_dm_cut(dataset_dm=dm,
                                  dataset_cut=dcut,
                                  cut_var=DCUTDT,
                                  dthcut_var=DTHDT),
               expected_output)


})
