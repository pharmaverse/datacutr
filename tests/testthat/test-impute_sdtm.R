### Set up input data and expected results ###
input <- data.frame(
  USUBJID = rep(c("U1234567"), 6),
  EXSTDTC = c("2022-08-10T15:13:30", "2022-08-10T15:13", "2022-08-10T15", "2022-08-10", "2022-08", "2022")
)

expected <- data.frame(
  USUBJID = rep(c("U1234567"), 6),
  EXSTDTC = c("2022-08-10T15:13:30", "2022-08-10T15:13", "2022-08-10T15", "2022-08-10", "2022-08", "2022"),
  DCUT_TEMP_EXSTDTC = ymd_hms(c(
    "2022-08-10T15:13:30", "2022-08-10T15:13:00", "2022-08-10T15:00:00", "2022-08-10T00:00:00",
    "2022-08-01T00:00:00", "2022-01-01T00:00:00"
  ))
)

### Test with factor input ###
input1 <- input %>%
  mutate(EXSTDTC = as.factor(EXSTDTC))
expected1 <- expected %>%
  mutate(EXSTDTC = as.factor(EXSTDTC))

test_that("Imputation of SDTM variables is working correctly when input variable is factor and dates in correct format", {
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

test_that("Imputation of SDTM variables is working correctly when input variable is character and dates in correct format", {
  expect_equal(
    impute_sdtm(dsin = input2, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC),
    expected2
  )
})

### Test with input dates in incorrect formats ###
input3 <- data.frame(
  USUBJID = rep(c("U1234567"), 7),
  EXSTDTC = c("2022-08-10T15:13:301", "2022-08-10T15:13:", "2022-08-10T15:", "2022-08-10T", "2022-08-", "2022-", "")
)

expected3 <- data.frame(
  USUBJID = rep(c("U1234567"), 7),
  EXSTDTC = c("2022-08-10T15:13:301", "2022-08-10T15:13:", "2022-08-10T15:", "2022-08-10T", "2022-08-", "2022-", ""),
  DCUT_TEMP_EXSTDTC = ymd_hms(rep(c(""), 7))
)

test_that("Dates in incorrect format or missing dates are always set to NA", {
  expect_equal(
    impute_sdtm(dsin = input3, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC),
    expected3
  )
})
