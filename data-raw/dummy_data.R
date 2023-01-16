# Creating dummy data to be cut ------------------------------------------------

ds <- tibble::tribble(
  ~USUBJID, ~DSDECOD, ~DSSTDTC,
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
fa <- tibble::tribble(
  ~USUBJID, ~FAORRES, ~FADTC, ~FASTDTC,
  "AB12345-001", 1, "2022-06-01", "",
  "AB12345-002", 2, "", "2022-06-30",
  "AB12345-003", 3, "2022-07-01", "",
  "AB12345-004", 4, "", "2022-05-04",
  "AB12345-005", 5, "2022-12-01", "",
)
ts <- tibble::tribble(
  ~USUBJID, ~TSVAL,
  "AB12345-001", 1,
  "AB12345-002", 2,
  "AB12345-003", 3,
  "AB12345-004", 4,
  "AB12345-005", 5,
)

# Save data as rda files in /data folder ---------------------------------------

usethis::use_data(ds, overwrite = TRUE)
usethis::use_data(dm, overwrite = TRUE)
usethis::use_data(ae, overwrite = TRUE)
usethis::use_data(sc, overwrite = TRUE)
usethis::use_data(lb, overwrite = TRUE)
usethis::use_data(fa, overwrite = TRUE)
usethis::use_data(ts, overwrite = TRUE)
