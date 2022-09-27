### Test whether records are correctly removed where DCUT_TEMP_REMOVE='Y' ###
input1 <- data.frame(USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c"),
                    DCUT_TEMP_REMOVE=c("Y", "", NA))

expected1 <- data.frame(USUBJID = factor(c("UXYZ123b", "UXYZ123c"), levels=c("UXYZ123a", "UXYZ123b", "UXYZ123c")))

test_that("Test whether records are correctly removed where DCUT_TEMP_REMOVE='Y'", {
  expect_equal(
    apply_cut(dsin=input1, dcutvar=DCUT_TEMP_REMOVE),
    expected1
  )
})

