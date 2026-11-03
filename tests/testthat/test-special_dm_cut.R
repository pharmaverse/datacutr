library(stringr)
library(dplyr)
library(lubridate)

dm_expect <- tibble::tribble(
  ~USUBJID, ~DTHDTC, ~DTHFL,
)

dm <- dm_expect

dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC,
  "01-701-1015", "2014-10-20T23:59:59",
  "01-701-1023", "2014-10-20T23:59:59",
  "01-701-1028", "2014-10-20T23:59:59",
) %>%
  mutate(DCUTDTM = ymd_hms(DCUTDTC))

test_that("Outcome if DM is empty", {
  testthat::expect_equal(
    special_dm_cut(
      dataset_dm = dm,
      dataset_cut = dcut,
      cut_var = DCUTDTM
    ),
    dm_expect
  )
})


dm_expect <- tibble::tribble(
  ~USUBJID, ~DTHDTC, ~DTHFL, ~DCUT_TEMP_DTHCHANGE, ~DCUT_TEMP_REMOVE, ~DCUTDTC,
  "01-701-1015", "", "", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1023", "2014-10-20", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1028", "2014-10-21", "Y", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1033", "2014-10-19", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1047", "2014-10-31", "Y", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1057", "2025-10-20", "Y", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1097", "2002-10-20", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1111", "", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
  "01-701-1115", "", "Y", NA_character_, "Y", NA_character_,
  "01-701-1118", "2014-11-20", "", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1118", "2014-11", "Y", "Y", NA_character_, "2014-10-20T23:59:59",
  "01-701-1118", "2014-01", "Y", NA_character_, NA_character_, "2014-10-20T23:59:59",
)

dm_expect <- impute_sdtm(dsin=dm_expect,varin=DTHDTC, varout=DCUT_TEMP_DTHDT) %>%
  mutate(DCUT_TEMP_DCUTDTM = ymd_hms(DCUTDTC)) %>%
  # mutate(DCUT_TEMP_DTHDTC = if_else(DTHDTC != "", str_c(DTHDTC, "T00:00:00"), "")) %>%
  # mutate(DCUT_TEMP_DTHDT = impute_sdtm(dsin=.,varin=DTHDTC, varout=DCUT_TEMP_DTHDT)) %>%
  select(
    USUBJID, DTHDTC, DTHFL, DCUT_TEMP_REMOVE, DCUT_TEMP_DTHDT,
    DCUT_TEMP_DCUTDTM, DCUT_TEMP_DTHCHANGE
  )

dm <- dm_expect[1:3]

dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC,
  "01-701-1015", "2014-10-20T23:59:59",
  "01-701-1023", "2014-10-20T23:59:59",
  "01-701-1028", "2014-10-20T23:59:59",
  "01-701-1033", "2014-10-20T23:59:59",
  "01-701-1047", "2014-10-20T23:59:59",
  "01-701-1057", "2014-10-20T23:59:59",
  "01-701-1097", "2014-10-20T23:59:59",
  "01-701-1111", "2014-10-20T23:59:59",
  "01-701-1118", "2014-10-20T23:59:59",
) %>%
  mutate(DCUTDTM = ymd_hms(DCUTDTC))

test_that("Tests all expected outcomes", {
  testthat::expect_equal(
    special_dm_cut(
      dataset_dm = dm,
      dataset_cut = dcut,
      cut_var = DCUTDTM
    ),
    dm_expect
  )
})

test_that("Error thrown if cut_var is not a POSIXt input", {
  expect_error(
    special_dm_cut(
      dataset_dm = dm,
      dataset_cut = dcut,
      cut_var = DCUTDTC
    ),
    regexp = "cut_var is expected to be of date type POSIXt"
  )
})

dcut_na <- tibble::tribble(
  ~USUBJID, ~DCUTDTM,
  "01-701-1015", NA,
  "01-701-1023", NA,
  "01-701-1028", NA,
  "01-701-1033", NA,
  "01-701-1047", NA,
  "01-701-1057", NA,
  "01-701-1097", NA,
  "01-701-1111", NA,
  "01-701-1115", NA,
  "01-701-1118", NA
)

dm_expect_na <- tibble::tribble(
  ~USUBJID, ~DTHDTC, ~DTHFL, ~DCUT_TEMP_REMOVE,
  ~DCUT_TEMP_DTHDT, ~DCUT_TEMP_DCUTDTM, ~DCUT_TEMP_DTHCHANGE,
  "01-701-1015", "", "", NA_character_,
  NA, NA, NA_character_,
  "01-701-1023", "2014-10-20", "Y", NA_character_,
  ymd_hms("2014-10-20T00:00:00"), NA, NA_character_,
  "01-701-1028", "2014-10-21", "Y", NA_character_,
  ymd_hms("2014-10-21T00:00:00"), NA, NA_character_,
  "01-701-1033", "2014-10-19", "Y", NA_character_,
  ymd_hms("2014-10-19T00:00:00"), NA, NA_character_,
  "01-701-1047", "2014-10-31", "Y", NA_character_,
  ymd_hms("2014-10-31T00:00:00"), NA, NA_character_,
  "01-701-1057", "2025-10-20", "Y", NA_character_,
  ymd_hms("2025-10-20T00:00:00"), NA, NA_character_,
  "01-701-1097", "2002-10-20", "Y", NA_character_,
  ymd_hms("2002-10-20T00:00:00"), NA, NA_character_,
  "01-701-1111", "", "Y", NA_character_,
  NA, NA, NA_character_,
  "01-701-1115", "", "Y", NA_character_,
  NA, NA, NA_character_,
  "01-701-1118", "2014-11-20", "", NA_character_,
  ymd_hms("2014-11-20T00:00:00"), NA, NA_character_
)

dm <- dm_expect_na[1:3]

test_that("Tests all expected outcomes when datacut date is NA", {
  testthat::expect_equal(
    special_dm_cut(
      dataset_dm = dm,
      dataset_cut = dcut_na,
      cut_var = DCUTDTM
    ),
    dm_expect_na
  )
})

# ---------------------------------------------------------------------------
# LALIVEDT / Rule B tests (section 5.4.2)
# ---------------------------------------------------------------------------

# dcut with LALIVEDT — one subject per scenario (1-7 from the plan)
dcut_lkad <- tibble::tribble(
  ~USUBJID, ~DCUTDTM,                       ~LALIVEDT,
  "S01",    ymd_hms("2014-10-20T23:59:59"), as.Date("2014-09-15"), # 1: Rule A wins
  "S02",    ymd_hms("2014-10-20T23:59:59"), as.Date("2014-10-05"), # 2: Rule B wins
  "S03",    ymd_hms("2014-10-20T23:59:59"), as.Date("2014-10-31"), # 3: conflict, missing day
  "S04",    ymd_hms("2014-10-20T23:59:59"), as.Date("2014-06-15"), # 4: Rule B wins, missing month+day
  "S05",    ymd_hms("2014-10-20T23:59:59"), as.Date("2014-12-31"), # 5: conflict, missing month+day
  "S06",    ymd_hms("2014-10-20T23:59:59"), as.Date("2014-10-25"), # 6: complete DTHDTC
  "S07",    ymd_hms("2014-10-20T23:59:59"), as.Date("2014-10-25"), # 7: completely missing DTHDTC
)

dm_lkad <- tibble::tribble(
  ~USUBJID, ~DTHDTC,       ~DTHFL,
  "S01",    "2014-10",     "Y",
  "S02",    "2014-10",     "Y",
  "S03",    "2014-10",     "Y",
  "S04",    "2014",        "Y",
  "S05",    "2014",        "Y",
  "S06",    "2014-10-20",  "Y",
  "S07",    "",            "Y",
)

dm_expect_lkad <- tibble::tribble(
  ~USUBJID, ~DTHDTC,       ~DTHFL, ~DCUT_TEMP_REMOVE, ~DCUT_TEMP_DTHDT,               ~DCUT_TEMP_DCUTDTM,             ~DCUT_TEMP_DTHCONFLICT, ~DCUT_TEMP_DTHCHANGE,
  # 1: Rule A wins — LKAD+1 (Sep 16) ≤ Rule A (Oct 01), no conflict
  "S01", "2014-10",    "Y", NA_character_, ymd_hms("2014-10-01T00:00:00"), ymd_hms("2014-10-20T23:59:59"), NA_character_, NA_character_,
  # 2: Rule B wins — LKAD+1 (Oct 06) > Rule A (Oct 01), no conflict
  "S02", "2014-10",    "Y", NA_character_, ymd_hms("2014-10-06T00:00:00"), ymd_hms("2014-10-20T23:59:59"), NA_character_, NA_character_,
  # 3: Conflict — LKAD (Oct 31) >= last permitted (Oct 31); LKAD+1 (Nov 01) used; after cut
  "S03", "2014-10",    "Y", NA_character_, ymd_hms("2014-11-01T00:00:00"), ymd_hms("2014-10-20T23:59:59"), "Y",           "Y",
  # 4: Rule B wins — LKAD+1 (Jun 16) > Rule A (Jan 01), no conflict
  "S04", "2014",       "Y", NA_character_, ymd_hms("2014-06-16T00:00:00"), ymd_hms("2014-10-20T23:59:59"), NA_character_, NA_character_,
  # 5: Conflict — LKAD (Dec 31) >= last permitted (Dec 31); LKAD+1 (Jan 01 2015) used; after cut
  "S05", "2014",       "Y", NA_character_, ymd_hms("2015-01-01T00:00:00"), ymd_hms("2014-10-20T23:59:59"), "Y",           "Y",
  # 6: Complete DTHDTC — Rule B not applied; but LALIVEDT (Oct 25) >= DTHDTC (Oct 20) → conflict
  "S06", "2014-10-20", "Y", NA_character_, ymd_hms("2014-10-20T00:00:00"), ymd_hms("2014-10-20T23:59:59"), "Y",           NA_character_,
  # 7: Completely missing DTHDTC (5.4.3) — always retained, no flagging
  "S07", "",           "Y", NA_character_, NA,                             ymd_hms("2014-10-20T23:59:59"), NA_character_, NA_character_,
)

test_that("Tests Rule B (LALIVEDT) imputation scenarios 1-7", {
  testthat::expect_equal(
    special_dm_cut(
      dataset_dm = dm_lkad,
      dataset_cut = dcut_lkad,
      cut_var = DCUTDTM
    ),
    dm_expect_lkad
  )
})

# ---------------------------------------------------------------------------
# Additional LALIVEDT scenarios from Partial_Death_Date_Scenarios.pptx
# (covering gaps not addressed by S01–S07 above)
# ---------------------------------------------------------------------------

.run_dm_scen <- function(dthdtc, lalivedt, ccod_date) {
  dm   <- tibble::tibble(USUBJID = "S", DTHDTC = dthdtc, DTHFL = "Y")
  dcut <- tibble::tibble(
    USUBJID  = "S",
    DCUTDTM  = ymd_hms(paste0(ccod_date, " 23:59:59")),
    LALIVEDT = as.Date(lalivedt)
  )
  special_dm_cut(dm, dcut, cut_var = DCUTDTM)
}

# --- Group 1: Day missing (YYYY-MM) ---

test_that("G1-3: LALIVEDT+1 = first of reported month — Rule A and B agree", {
  out <- .run_dm_scen("2026-05", "2026-04-30", "2026-06-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-05-01T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("G1-4: Month straddles CCOD; Rule B date = CCOD — retained", {
  out <- .run_dm_scen("2026-06", "2026-06-14", "2026-06-15")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-15T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("G1-5: Month straddles CCOD; Rule B date = CCOD + 1 day — removed", {
  out <- .run_dm_scen("2026-06", "2026-06-15", "2026-06-15")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-16T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   "Y")
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("G1-6: Entire reported month is after CCOD — Rule A governs, removed", {
  out <- .run_dm_scen("2026-07", "2026-05-05", "2026-06-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-07-01T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   "Y")
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

# --- Group 2: Month and day missing (YYYY) ---

test_that("G2-2: LALIVEDT = CCOD — Rule B gives CCOD + 1, removed", {
  out <- .run_dm_scen("2026", "2026-06-01", "2026-06-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-02T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   "Y")
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("G2-3: LALIVEDT after CCOD (uncut data not capped) — Rule B, removed", {
  out <- .run_dm_scen("2026", "2026-06-25", "2026-06-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-26T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   "Y")
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("G2-4: At a later CCOD the same subject's death is retained", {
  out <- .run_dm_scen("2026", "2026-06-25", "2026-09-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-26T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("G2-5: Reported year is after CCOD year — Rule A (Jan 1) governs, removed", {
  out <- .run_dm_scen("2027", "2026-05-05", "2026-06-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2027-01-01T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   "Y")
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("G2-6: LALIVEDT a year earlier than reported year — Rule A wins, retained", {
  out <- .run_dm_scen("2026", "2025-10-20", "2026-03-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-01-01T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

# --- Group 3: Conflicts that are retained ---

test_that("G3-1: Conflict (YYYY-MM), LALIVEDT+1 = CCOD — conflict flag set, retained", {
  out <- .run_dm_scen("2026-05", "2026-05-31", "2026-06-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-01T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, "Y")
})

test_that("G3-3: Conflict (YYYY), LALIVEDT in following year, LALIVEDT+1 <= CCOD — conflict flag set, retained", {
  out <- .run_dm_scen("2025", "2026-05-05", "2026-06-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-05-06T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, "Y")
})

# --- Complete date conflict ---

test_that("Complete date: LALIVEDT >= DTHDTC — conflict flag set, date unchanged", {
  out <- .run_dm_scen("2026-06-10", "2026-06-15", "2026-09-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-10T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, "Y")
})

test_that("Complete date: LALIVEDT < DTHDTC — no conflict", {
  out <- .run_dm_scen("2026-06-10", "2026-06-09", "2026-09-01")
  expect_equal(out$DCUT_TEMP_DTHDT,       ymd_hms("2026-06-10T00:00:00"))
  expect_equal(out$DCUT_TEMP_DTHCHANGE,   NA_character_)
  expect_equal(out$DCUT_TEMP_DTHCONFLICT, NA_character_)
})

test_that("Rule A only and no DCUT_TEMP_DTHCONFLICT when LALIVEDT absent from dataset_cut", {
  dcut_no_lkad <- tibble::tribble(
    ~USUBJID, ~DCUTDTM,
    "S01",    ymd_hms("2014-10-20T23:59:59"),
  )
  dm_no_lkad <- tibble::tribble(
    ~USUBJID, ~DTHDTC,    ~DTHFL,
    "S01",    "2014-10",  "Y",
  )
  result <- special_dm_cut(dataset_dm = dm_no_lkad, dataset_cut = dcut_no_lkad)
  # Rule A: imputed to 2014-10-01, before cut date -> not flagged
  testthat::expect_equal(result$DCUT_TEMP_DTHDT, ymd_hms("2014-10-01T00:00:00"))
  testthat::expect_equal(result$DCUT_TEMP_DTHCHANGE, NA_character_)
  testthat::expect_false("DCUT_TEMP_DTHCONFLICT" %in% names(result))
})
