# Creating dummy data to be cut ------------------------------------------------
# To be updated in future to embed the data into the package

ds <- tibble::tribble(
  ~USUBJID,     ~DSDECOD,       ~DSSTDTC,
  "AB12345-001", "RANDOMIZATION", "2022-06-01",
  "AB12345-002", "RANDOMIZATION", "2022-06-02",
  "AB12345-003", "RANDOMIZATION", "2022-06-03",
  "AB12345-004", "RANDOMIZATION", "2022-06-04",
  "AB12345-005", "RANDOMIZATION", "2022-10-05",
)
dm <- tibble::tribble(
  ~USUBJID, ~DTHFL, ~DTHDTC,
  "AB12345-001", "Y", "2022-06-01",
  "AB12345-002", "", "",
  "AB12345-003", "Y", "2022-07-01",
  "AB12345-004", "", "",
  "AB12345-005", "Y", "2022-12-01",
)
ae <- tibble::tribble(
  ~USUBJID, ~AETERM, ~AESTDTC,
  "AB12345-001", "AE1", "2022-06-01",
  "AB12345-002", "AE2", "2022-06-30",
  "AB12345-003", "AE3", "2022-07-01",
  "AB12345-004", "AE4", "2022-05-04",
  "AB12345-005", "AE5", "2022-12-01",
)
sc <- tibble::tribble(
  ~USUBJID, ~SCORRES,
  "AB12345-001", "A",
  "AB12345-002", "B",
  "AB12345-003", "C",
  "AB12345-004", "D",
  "AB12345-005", "E",
)
lb <- tibble::tribble(
  ~USUBJID, ~LBORRES, ~LBDTC,
  "AB12345-001", 1, "2022-06-01",
  "AB12345-002", 2, "2022-06-30",
  "AB12345-003", 3, "2022-07-01",
  "AB12345-004", 4, "2022-05-04",
  "AB12345-005", 5, "2022-12-01",
)
ts <- tibble::tribble(
  ~USUBJID, ~TSORRES,
  "AB12345-001", 1,
  "AB12345-002", 2,
  "AB12345-003", 3,
  "AB12345-004", 4,
  "AB12345-005", 5,
)

# Store all input data as a list
source_data <- list(ds = ds, dm = dm, ae = ae, sc = sc, lb = lb, ts = ts)

# Create dcut dataset
dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM, ~DCUTDESC,
  "AB12345-001", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-002", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-003", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
  "AB12345-004", "2022-06-04", as.POSIXct("2022-06-04 23:59:59"), "Clinical Cutoff Date",
)

# Expected final data --------- ------------------------------------------------

ds_cut <- tibble::tribble(
  ~USUBJID,     ~DSDECOD,       ~DSSTDTC,
  "AB12345-001", "RANDOMIZATION", "2022-06-01",
  "AB12345-002", "RANDOMIZATION", "2022-06-02",
  "AB12345-003", "RANDOMIZATION", "2022-06-03",
  "AB12345-004", "RANDOMIZATION", "2022-06-04",
)
dm_cut <- tibble::tribble(
  ~USUBJID, ~DTHFL, ~DTHDTC,
  "AB12345-001", "Y", "2022-06-01",
  "AB12345-002", "", "",
  "AB12345-003", "", "",
  "AB12345-004", "", "",
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
  ~USUBJID, ~TSORRES,
  "AB12345-001", 1,
  "AB12345-002", 2,
  "AB12345-003", 3,
  "AB12345-004", 4,
  "AB12345-005", 5,
)

# Store all expected data as a list
expected <- list(dcut = dcut, dm = dm_cut, sc = sc_cut, ds = ds_cut,
                 ae = ae_cut, lb = lb_cut, ts = ts_cut)

# Test every type of datacut gives the expected result  ------------------------

test_that("Test every type of datacut gives the expected result", {
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


