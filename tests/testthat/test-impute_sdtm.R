### Set up input data and expected results ###
input <- data.frame(
  USUBJID = rep(c("UXYZ123a"), 13),
  EXSTDTC = c(
    "", "2022", "2022-06", "2022-06-23", "2022-06-23T16", "2022-06-23T16:57",
    "2022-06-23T16:57:30", "2022-06-23T16:57:30.123", "2022-06-23T16:-:30",
    "2022-06-23T-:57:30", "2022-06--T16:57:30", "2022---23T16:57:30", "--06-23T16:57:30"
  )
)

expected <- data.frame(
  USUBJID = rep(c("UXYZ123a"), 13),
  EXSTDTC = c(
    "", "2022", "2022-06", "2022-06-23", "2022-06-23T16", "2022-06-23T16:57",
    "2022-06-23T16:57:30", "2022-06-23T16:57:30.123", "2022-06-23T16:-:30",
    "2022-06-23T-:57:30", "2022-06--T16:57:30", "2022---23T16:57:30", "--06-23T16:57:30"
  ),
  DCUT_TEMP_EXSTDTC = ymd_hms(c(
    NA_character_, "2022-01-01T00:00:00", "2022-06-01T00:00:00", "2022-06-23T00:00:00",
    "2022-06-23T16:00:00", "2022-06-23T16:57:00", "2022-06-23T16:57:30",
    "2022-06-23T16:57:30", "2022-06-23T16:00:30", "2022-06-23T00:57:30", "2022-06-01T16:57:30",
    "2022-01-23T16:57:30", NA_character_
  ))
)

### Test with factor input ###
input1 <- input %>%
  mutate(EXSTDTC = as.factor(EXSTDTC))
expected1 <- expected %>%
  mutate(EXSTDTC = as.factor(EXSTDTC))

test_that("Test that imputation of SDTM date/time variables is working correctly
when input variable is factor and
          date/times are in ISO 8601 format", {
  expect_equal(
    impute_sdtm(dsin = input1, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC),
    expected1
  )
})

### Test with character input ###
input2 <- input %>%
  mutate(EXSTDTC = as.character(EXSTDTC))
expected2 <- expected %>%
  mutate(EXSTDTC = as.character(EXSTDTC))

test_that("Test that imputation of SDTM date/time variables is working correctly
when input variable is character and
          date/times are in ISO 8601 format", {
  expect_equal(
    impute_sdtm(dsin = input2, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC),
    expected2
  )
})

### Test with input dates in incorrect format (not ISO 8601) ###
input3 <- data.frame(
  USUBJID = c("U1234567"),
  EXSTDTC = c("2022-08-10T15:13:30/2022-08-11T15:13:30")
)

test_that("Test that impute_sdtm function errors when varin contains interval dates", {
  expect_error(impute_sdtm(dsin = input3, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC),
    regexp = "The varin variable contains datetimes in the incorrect format"
  )
})

input4 <- data.frame(
  USUBJID = c("U1234567"),
  EXSTDTC = c("2022-08-10T15:")
)

test_that("Test that impute_sdtm function errors when varin contains dates
          in incorrect format (not ISO 8601)", {
  expect_error(impute_sdtm(dsin = input4, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC),
    regexp = "The varin variable contains datetimes in the incorrect format"
  )
})

input5 <- data.frame(
  USUBJID = c("U1234567"),
  EXSTDTC = c("2022-08-10T")
)

test_that("Test that impute_sdtm function errors when varin contains dates
          in incorrect format (not ISO 8601)", {
  expect_error(impute_sdtm(dsin = input5, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC),
    regexp = "The varin variable contains datetimes in the incorrect format"
  )
})
