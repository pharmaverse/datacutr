### Set up input data and expected results ###
input <- data.frame(USUBJID = rep(c("U1234567"), 4),
                    DCUTDTC = c("2022-08-10T15:13:30", "2022-08-10T15:13", "2022-08-10T15", "2022-08-10"))

expected <- data.frame(USUBJID = rep(c("U1234567"), 4),
                       DCUTDTC = c("2022-08-10T15:13:30", "2022-08-10T15:13", "2022-08-10T15", "2022-08-10"),
                       DCUTDTM = ymd_hms(c("2022-08-10T15:13:30", "2022-08-10T15:13:59", "2022-08-10T15:59:59", "2022-08-10T23:59:59")))

### Test with factor input ###
input1 <- input %>%
  mutate(DCUTDTC = as.factor(DCUTDTC))
expected1 <- expected %>%
  mutate(DCUTDTC = as.factor(DCUTDTC))

test_that("Imputation of DCUTDTC variable is working correctly when DCUTDTC is factor and dates are complete and in correct format", {
  expect_equal(
    impute_dcutdtc(dsin=input1, varin=DCUTDTC, varout=DCUTDTM),
    expected1
  )
})

### Test with character input ###
input2 <- input %>%
  mutate(DCUTDTC = as.character(DCUTDTC))
expected2 <- expected %>%
  mutate(DCUTDTC = as.character(DCUTDTC))

test_that("Imputation of DCUTDTC variable is working correctly when DCUTDTC is character and dates are complete and in correct format", {
  expect_equal(
    impute_dcutdtc(dsin=input2, varin=DCUTDTC, varout=DCUTDTM),
    expected2
  )
})

### Test with input dates in incorrect formats and incomplete dates ###
input3 <- data.frame(USUBJID = rep(c("U1234567"), 8),
                     DCUTDTC = c("2022-08-10T15:13:301", "2022-08-10T15:13:", "2022-08-10T15:", "2022-08-10T", "2022-08", "2022", "", NA))

expect_error(impute_dcutdtc(dsin=input3, varin=DCUTDTC, varout=DCUTDTM),
             regexp="Elements 1, 2, 3, 4, 5, 6, 7, 8")


