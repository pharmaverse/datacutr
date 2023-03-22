### Test whether records are correctly removed where DCUT_TEMP_REMOVE='Y' ###
input1 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  DCUT_TEMP_REMOVE = c("Y", "", NA),
  stringsAsFactors = FALSE
)

expected1 <- data.frame(USUBJID = c("UXYZ123b", "UXYZ123c"), stringsAsFactors = FALSE)

test_that("Test whether records are correctly removed where DCUT_TEMP_REMOVE='Y'", {
  expect_equal(
    apply_cut(dsin = input1, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = NULL),
    expected1
  )
})

### Test whether DTHDTC and DTHFL are correctly set to missing where DCUT_TEMP_DTHCHANGE='Y' ###
input2 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  DTHDTC = c("23MAR2022", "24MAR2022", "25MAR2022"),
  DTHFL = c("Y", "Y", "Y"),
  DCUT_TEMP_REMOVE = c("", "", ""),
  DCUT_TEMP_DTHCHANGE = c("Y", "", NA),
  stringsAsFactors = FALSE
)

expected2 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  DTHDTC = c("", "24MAR2022", "25MAR2022"),
  DTHFL = c("", "Y", "Y"),
  stringsAsFactors = FALSE
)

test_that("Test whether DTHDTC and DTHFL are correctly set to missing where
          DCUT_TEMP_DTHCHANGE='Y'", {
  expect_equal(
    apply_cut(dsin = input2, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = DCUT_TEMP_DTHCHANGE),
    expected2
  )
})

### Test when DCUT_TEMP_DTHCHANGE is specified but either DTHDTC or DTHFL do not exist  ###
input3 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  DTHDTC = c("23MAR2022", "24MAR2022", "25MAR2022"),
  DCUT_TEMP_REMOVE = c("", "", ""),
  DCUT_TEMP_DTHCHANGE = c("Y", "", NA),
  stringsAsFactors = FALSE
)

expected3 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  DTHDTC = c("", "24MAR2022", "25MAR2022"),
  stringsAsFactors = FALSE
)

test_that("Test when DCUT_TEMP_DTHCHANGE is specified but either DTHDTC or DTHFL do not exist", {
  expect_equal(
    apply_cut(dsin = input3, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = DCUT_TEMP_DTHCHANGE),
    expected3
  )
})

### Test when DCUT_TEMP_DTHCHANGE is specified but both DTHDTC and DTHFL do not exist  ###
input4 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  DCUT_TEMP_REMOVE = c("", "", ""),
  DCUT_TEMP_DTHCHANGE = c("Y", "", NA),
  stringsAsFactors = FALSE
)

expected4 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  stringsAsFactors = FALSE
)

test_that("Test when DCUT_TEMP_DTHCHANGE is specified but both DTHDTC and DTHFL do not exist", {
  expect_equal(
    apply_cut(dsin = input4, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = DCUT_TEMP_DTHCHANGE),
    expected4
  )
})

### Test when all records have DCUT_TEMP_REMOVE='Y' ###
input5 <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
  DCUT_TEMP_REMOVE = c("Y", "Y", "Y"),
  stringsAsFactors = FALSE
)

expected5 <- input5 %>%
  filter(DCUT_TEMP_REMOVE != "Y") %>%
  select(USUBJID)

test_that("Test when all records have DCUT_TEMP_REMOVE='Y'", {
  expect_equal(
    apply_cut(dsin = input5, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = NULL),
    expected5
  )
})
