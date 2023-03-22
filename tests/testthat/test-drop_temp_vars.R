testdf <- data.frame(USUBJID = c(""), TEMP_XYZ = c(""), DCUT_TEMP_XYZ = c(""))

test_that("removing temp_ and dcut_temp_ variables works without giving drop_dcut_temp as input", {
  expect_equal(
    drop_temp_vars(dsin = testdf),
    select(testdf, USUBJID)
  )
})

test_that("removing temp_ and dcut_temp_ variables works", {
  expect_equal(
    drop_temp_vars(dsin = testdf, drop_dcut_temp = TRUE),
    select(testdf, USUBJID)
  )
})

test_that("removing temp_ variables works", {
  expect_equal(
    drop_temp_vars(dsin = testdf, drop_dcut_temp = FALSE),
    select(testdf, USUBJID, DCUT_TEMP_XYZ)
  )
})

test_that("still works even if no temp_ or dcut_temp_ variables in the input dataset", {
  testdf2 <- data.frame(USUBJID = c(""))
  expect_equal(
    drop_temp_vars(dsin = testdf2),
    testdf2
  )
})

test_that("still works even if resulting dataset would have no columns left", {
  testdf3 <- data.frame(TEMP_XYZ = c(""))
  expect_equal(
    drop_temp_vars(dsin = testdf3),
    select(testdf3, -TEMP_XYZ)
  )
})

test_that("still drop_dcut_temp must be either TRUE or FALSE", {
  expect_error(drop_temp_vars(dsin = testdf, drop_dcut_temp = "FALSE"),
    regexp = "drop_dcut_temp must be either TRUE or FALSE"
  )
})
