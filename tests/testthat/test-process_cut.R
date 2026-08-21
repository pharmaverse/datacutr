# Store all input data as a list ------------------------------------------------

source_data <- list(
  ds = datacutr_ds, dm = datacutr_dm, ae = datacutr_ae,
  sc = datacutr_sc, lb = datacutr_lb, ts = datacutr_ts
)

# Create dcut dataset ----------------------------------------------------------

dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "AB12345-001", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-002", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-003", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-004", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
)

# Expected final data --------- ------------------------------------------------

ds_cut <- tibble::tribble(
  ~USUBJID, ~DSDECOD, ~DSSTDTC,
  "AB12345-001", "RANDOMIZATION", "2022-06-01",
  "AB12345-002", "RANDOMIZATION", "2022-06-02",
  "AB12345-003", "RANDOMIZATION", "2022-06-03",
  "AB12345-004", "RANDOMIZATION", "2022-06-04",
)
dm_cut <- tibble::tribble(
  ~USUBJID, ~DTHFL, ~DTHDTC,
  "AB12345-001", "Y", "2022-06-01",
  "AB12345-002", NA_character_, NA_character_,
  "AB12345-003", NA_character_, NA_character_,
  "AB12345-004", NA_character_, NA_character_,
)
ae_cut <- tibble::tribble(
  ~USUBJID, ~AETERM, ~AESTDTC,
  "AB12345-001", "AE1", "2022-06-01",
  "AB12345-004", "AE4", "2022-05-04",
)
sc_cut <- tibble::tribble(
  ~USUBJID, ~SCORRES,
  "AB12345-001", "A",
  "AB12345-002", "B",
  "AB12345-003", "C",
  "AB12345-004", "D",
)
lb_cut <- tibble::tribble(
  ~USUBJID, ~LBORRES, ~LBDTC,
  "AB12345-001", 1, "2022-06-01",
  "AB12345-004", 4, "2022-05-04",
)
ts_cut <- tibble::tribble(
  ~USUBJID, ~TSVAL,
  "AB12345-001", 1,
  "AB12345-002", 2,
  "AB12345-003", 3,
  "AB12345-004", 4,
  "AB12345-005", 5,
)

# Store all expected data as a list
expected <- list(
  dcut = dcut, dm = dm_cut, sc = sc_cut, ds = ds_cut,
  ae = ae_cut, lb = lb_cut, ts = ts_cut
)

# Test that every type of datacut gives the expected result, when special_dm=TRUE -----------

test_that("Test that every type of datacut gives the expected result, when special_dm=TRUE", {
  expect_equal(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    expected
  )
})

# Test that process_cut() errors when a source SDTM dataset is not referenced
# in any input list

test_that("Test that process_cut() errors when a source SDTM dataset is not
          referenced in any input list", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("ds"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "sc exists in source_sdtm_data but no cut method has been assigned"
  )
})

# Test that process_cut() errors when an input list includes a source SDTMv
# dataset that does not exist

test_that("Test that process_cut() errors when an input list includes a source
           SDTMv dataset that does not exist in the source SDTMv data", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds", "vs"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "Cut types have been assigned for vs which does not exist in source_sdtm_data"
  )
})

# Test that process_cut() errors when a source SDTMv dataset is referenced in
# more than one input list

test_that("Test that process_cut() errors when a source SDTMv dataset is
          referenced in more than one input list", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds", "ae"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "Multiple cut types have been assigned for ae"
  )
})

# Test that process_cut() errors when special_dm = TRUE and dm is also referenced
# in an input list

test_that("Test that process_cut() errors when special_dm = TRUE and dm is also
          referenced in an input list", {
  expect_error(
    process_cut(
      source_sdtm_data = source_data,
      patient_cut_v = c("sc", "ds", "dm"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "Multiple cut types have been assigned for dm"
  )
})

# Test Read-out file -------------
# Test that read-out file is ran successfully when special_dm = TRUE
test_that("Test that Correct .Rmd file is ran successfully when read_out = TRUE", {
  # Create temporary directory for testing output file
  temp_dir <- tempdir()
  # Run test
  process_cut(
    source_sdtm_data = source_data,
    patient_cut_v = c("sc", "ds"),
    date_cut_m = rbind(
      c("ae", "AESTDTC"),
      c("lb", "LBDTC")
    ),
    no_cut_v = c("ts"),
    dataset_cut = dcut,
    cut_var = DCUTDTM,
    special_dm = TRUE,
    read_out = TRUE,
    out_path = paste0(temp_dir)
  )
  expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir))) > 0)
  unlink(temp_dir, recursive = TRUE)
})

# Test that every type of datacut gives the expected result, when special_dm=FALSE -----------

local({
  source_data_no_dm <- source_data
  source_data_no_dm["dm"] <- NULL
  expected_no_dm <- expected
  expected_no_dm["dm"] <- NULL

  test_that("Test that every type of datacut gives the expected result, when special_dm=FALSE", {
    expect_equal(
      process_cut(
        source_sdtm_data = source_data_no_dm,
        patient_cut_v = c("sc", "ds"),
        date_cut_m = rbind(
          c("ae", "AESTDTC"),
          c("lb", "LBDTC")
        ),
        no_cut_v = c("ts"),
        dataset_cut = dcut,
        cut_var = DCUTDTM,
        special_dm = FALSE
      ),
      expected_no_dm
    )
  })

  # Test that Read-out file is ran successfully when special_dm = FALSE
  test_that("Test that Correct .Rmd file is ran successfully when read_out = TRUE", {
    # Create temporary directory for testing output file
    temp_dir <- tempdir()
    # Run test
    process_cut(
      source_sdtm_data = source_data_no_dm,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = FALSE,
      read_out = TRUE,
      out_path = temp_dir
    )
    expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir)) > 0))
    unlink(temp_dir, recursive = TRUE)
  })
})


# Testing when ae dataset is empty
local({
  ae_empty <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~AESEQ, ~AESTDTC,
  )
  source_data_empty_ae <- list(
    ds = datacutr_ds, dm = datacutr_dm, ae = ae_empty,
    sc = datacutr_sc, lb = datacutr_lb, ts = datacutr_ts
  )

  test_that("Test if a date_cut dataset is null and creating report", {
    # Create temporary directory for testing output file
    temp_dir <- tempdir()
    # Run test
    process_cut(
      source_sdtm_data = source_data_empty_ae,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(
        c("ae", "AESTDTC"),
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE,
      read_out = TRUE,
      out_path = temp_dir
    )
    expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir)) > 0))
    unlink(temp_dir, recursive = TRUE)
  })


  test_that("Test if a pt_cut dataset is null and creating report", {
    # Create temporary directory for testing output file
    temp_dir <- tempdir()
    # Run test
    process_cut(
      source_sdtm_data = source_data_empty_ae,
      patient_cut_v = c("sc", "ds", "ae"),
      date_cut_m = rbind(
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE,
      read_out = TRUE,
      out_path = temp_dir
    )
    expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir)) > 0))
    unlink(temp_dir, recursive = TRUE)
  })


  test_that("Test if a no_cut dataset is null and creating report", {
    # Create temporary directory for testing output file
    temp_dir <- tempdir()
    # Run test
    process_cut(
      source_sdtm_data = source_data_empty_ae,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ae", "ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE,
      read_out = TRUE,
      out_path = temp_dir
    )
    expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir)) > 0))
    unlink(temp_dir, recursive = TRUE)
  })
})


# Testing when dm dataset is empty
local({
  dm_empty <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~DTHFL, ~DTHDTC,
  )
  source_data_empty_dm <- list(
    ds = datacutr_ds, dm = dm_empty,
    sc = datacutr_sc, lb = datacutr_lb, ts = datacutr_ts
  )

  test_that("Test if a dm dataset is null and creating report", {
    # Create temporary directory for testing output file
    temp_dir <- tempdir()
    # Run test
    process_cut(
      source_sdtm_data = source_data_empty_dm,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(
        c("lb", "LBDTC")
      ),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE,
      read_out = TRUE,
      out_path = temp_dir
    )
    expect_true(dir.exists(temp_dir) & (length(list.files(temp_dir)) > 0))
    unlink(temp_dir, recursive = TRUE)
  })
})


# Input validation tests -------------------------------------------------------
# Fresh minimal datasets so the tests below are not affected by state mutations
# earlier in this file.

min_source_data <- list(
  ds = data.frame(USUBJID = "AB12345-001", DSSTDTC = "2022-06-01", stringsAsFactors = FALSE),
  dm = data.frame(
    USUBJID = "AB12345-001", DTHDTC = NA_character_, DTHFL = NA_character_,
    stringsAsFactors = FALSE
  ),
  ae = data.frame(USUBJID = "AB12345-001", AESTDTC = "2022-06-01", stringsAsFactors = FALSE),
  sc = data.frame(USUBJID = "AB12345-001", stringsAsFactors = FALSE),
  ts = data.frame(USUBJID = "AB12345-001", stringsAsFactors = FALSE)
)

# Test: source_sdtm_data is not a list

test_that("Error thrown when source_sdtm_data is not a list", {
  expect_error(
    process_cut(
      source_sdtm_data = "not_a_list",
      patient_cut_v = NULL,
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = FALSE
    ),
    regexp = "source_sdtm_data must be of class list"
  )
})

# Test: source_sdtm_data contains non-data-frame elements

test_that("Error thrown when source_sdtm_data contains non-data-frame elements", {
  expect_error(
    process_cut(
      source_sdtm_data = list(ds = "not_a_dataframe"),
      patient_cut_v = c("ds"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = FALSE
    ),
    regexp = "All elements of source_sdtm_data must be a dataframe"
  )
})

# Test: patient_cut_v contains an empty string

test_that("Error thrown when patient_cut_v contains an empty string", {
  expect_error(
    process_cut(
      source_sdtm_data = min_source_data,
      patient_cut_v = c("sc", ""),
      date_cut_m = rbind(c("ae", "AESTDTC")),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "patient_cut_v must be a vector or NULL"
  )
})

# Test: date_cut_m has the wrong number of columns (not 2)

test_that("Error thrown when date_cut_m does not have exactly two columns", {
  expect_error(
    process_cut(
      source_sdtm_data = min_source_data,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = matrix(c("ae", "AESTDTC", "extra"), nrow = 1, ncol = 3),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "date_cut_m must be a matrix with two columns or NULL"
  )
})

# Test: no_cut_v contains an empty string

test_that("Error thrown when no_cut_v contains an empty string", {
  expect_error(
    process_cut(
      source_sdtm_data = min_source_data,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(c("ae", "AESTDTC")),
      no_cut_v = c("ts", ""),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "no_cut_v must be a vector or NULL"
  )
})

# Test: special_dm is not logical

test_that("Error thrown when special_dm is not logical", {
  expect_error(
    process_cut(
      source_sdtm_data = min_source_data,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(c("ae", "AESTDTC")),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = "TRUE"
    ),
    regexp = "special_dm must be either TRUE or FALSE"
  )
})

# Test: special_dm = TRUE but dm absent from source_sdtm_data

min_source_data_no_dm <- min_source_data[names(min_source_data) != "dm"]

test_that("Error thrown when special_dm=TRUE but dm is absent from source_sdtm_data", {
  expect_error(
    process_cut(
      source_sdtm_data = min_source_data_no_dm,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(c("ae", "AESTDTC")),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "dataset `dm` is missing from source_sdtm_data"
  )
})

# Test: source_sdtm_data contains duplicate dataset names

min_source_data_dup_names <- c(
  min_source_data,
  list(ds = data.frame(
    USUBJID = "AB12345-001", DSSTDTC = "2022-06-01",
    stringsAsFactors = FALSE
  ))
)

test_that("Error thrown when source_sdtm_data contains duplicate dataset names", {
  expect_error(
    process_cut(
      source_sdtm_data = min_source_data_dup_names,
      patient_cut_v = c("sc", "ds"),
      date_cut_m = rbind(c("ae", "AESTDTC")),
      no_cut_v = c("ts"),
      dataset_cut = dcut,
      cut_var = DCUTDTM,
      special_dm = TRUE
    ),
    regexp = "exists more than once in source_sdtm_data"
  )
})
