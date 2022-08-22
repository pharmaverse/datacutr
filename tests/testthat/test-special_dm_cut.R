test_that("special_dm_cut Test 1: <Explanation of the test>", {
  input <- tibble::tribble(
    ~inputvar1, ~inputvar2, ...
    <Add Test Data Scenarios>
      ...
  )

  expected_output <- mutate(input, outputvar = c(<Add Expected Outputs>))

  expect_dfs_equal(<function name>(input), expected_output)

})
