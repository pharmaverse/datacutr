### Set up input data and expected results ###
input <- data.frame(
  USUBJID = rep(c("UXYZ123a"), 8),
  DCUTDTC = c(
    "2022-06-23", "2022-06-23T16", "2022-06-23T16:57", "2022-06-23T16:57:30",
    "2022-06-23T16:57:30.123", "2022-06-23T16:-:30", "2022-06-23T-:57:30", NA
  )
)
expected <- data.frame(
  USUBJID = rep(c("UXYZ123a"), 8),
  DCUTDTC = c(
    "2022-06-23", "2022-06-23T16", "2022-06-23T16:57", "2022-06-23T16:57:30",
    "2022-06-23T16:57:30.123", "2022-06-23T16:-:30", "2022-06-23T-:57:30", NA
  ),
  DCUTDTM = ymd_hms(c(
    "2022-06-23T23:59:59", "2022-06-23T16:59:59", "2022-06-23T16:57:59",
    "2022-06-23T16:57:30", "2022-06-23T16:57:30", "2022-06-23T16:59:30",
    "2022-06-23T23:57:30", NA
  ))
)

### Test with factor input ###
input1 <- input %>%
  mutate(DCUTDTC = as.factor(DCUTDTC))
expected1 <- expected %>%
  mutate(DCUTDTC = as.factor(DCUTDTC))

test_that("Test that imputation of data cutoff variable (DCUTDTC) is working correctly
when input variable is factor and
          contains at least a complete date in ISO 8601 format", {
  expect_equal(
    impute_dcutdtc(dsin = input1, varin = DCUTDTC, varout = DCUTDTM),
    expected1
  )
})

### Test with character input ###
input2 <- input %>%
  mutate(DCUTDTC = as.character(DCUTDTC))
expected2 <- expected %>%
  mutate(DCUTDTC = as.character(DCUTDTC))

test_that("Test that imputation of data cutoff variable (DCUTDTC) is working correctly
when input variable is character and
          contains at least a complete date in ISO 8601 format", {
  expect_equal(
    impute_dcutdtc(dsin = input2, varin = DCUTDTC, varout = DCUTDTM),
    expected2
  )
})

### Test with input dates in incorrect format (not ISO 8601) ###
input3 <- data.frame(
  USUBJID = c("U1234567"),
  DCUTDTC = c("2022-08-10T15:13:30/2022-08-11T15:13:30")
)

test_that("Test that impute_dcutdtc function errors when varin contains interval dates", {
  expect_error(impute_dcutdtc(dsin = input3, varin = DCUTDTC, varout = DCUTDTM),
    regexp = "The varin variable contains datetimes in the incorrect format"
  )
})

input4 <- data.frame(
  USUBJID = c("U1234567"),
  DCUTDTC = c("2022-08-10T15:")
)

test_that("Test that impute_dcutdtc function errors when varin contains dates in
          incorrect format (not ISO 8601)", {
  expect_error(impute_dcutdtc(dsin = input4, varin = DCUTDTC, varout = DCUTDTM),
    regexp = "The varin variable contains datetimes in the incorrect format"
  )
})

input5 <- data.frame(
  USUBJID = c("U1234567"),
  DCUTDTC = c("2022-08-10T")
)

test_that("Test that impute_dcutdtc function errors when varin contains dates in
          incorrect format (not ISO 8601)", {
  expect_error(impute_dcutdtc(dsin = input5, varin = DCUTDTC, varout = DCUTDTM),
    regexp = "The varin variable contains datetimes in the incorrect format"
  )
})

### Test with input dates that do not contain a complete date ###
input6 <- data.frame(
  USUBJID = c("U1234567"),
  DCUTDTC = c("2022-06")
)

test_that("Test that impute_dcutdtc function errors when varin does not contain
          at least a complete date", {
  expect_error(impute_dcutdtc(dsin = input6, varin = DCUTDTC, varout = DCUTDTM),
    regexp = "All values of the data cutoff variable must be at least a complete date"
  )
})

input7 <- data.frame(
  USUBJID = c("U1234567"),
  DCUTDTC = c("2022-06--T16:57:30")
)

test_that("Test that impute_dcutdtc function errors when varin does not contain
          at least a complete date", {
  expect_error(impute_dcutdtc(dsin = input7, varin = DCUTDTC, varout = DCUTDTM),
    regexp = "All values of the data cutoff variable must be at least a complete date"
  )
})
