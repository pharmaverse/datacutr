# Name: Datacut Template Code - Wrapped Approach

# Creating data to be cut ------------------------------------------------
li
source(here::here("inst/templates/dummy_data.R"))
source_data <- list(ds = ds, dm = dm, ae = ae, sc = sc, lb = lb, fa = fa, ts = ts)


# Create DCUT ------------------------------------------------------------

dcut <- create_dcut(
  dataset_ds = ds,
  ds_date_var = DSSTDTC,
  filter = DSDECOD == "RANDOMIZATION",
  cut_date = "2022-06-04",
  cut_description = "Clinical Cutoff Date"
)


# Pre-processing of FA ----------------------------------------------------

# Update FA
source_data$fa <- source_data$fa %>%
  mutate(DCUT_TEMP_FAXDTC = case_when(
    FASTDTC != "" ~ FASTDTC,
    FADTC != "" ~ FADTC,
    TRUE ~ as.character(NA)
  ))


# Process data cut --------------------------------------------------------

cut_data <- process_cut(
  source_sdtm_data = source_data,
  patient_cut_v = c("sc", "ds"),
  date_cut_m = rbind(
    c("ae", "AESTDTC"),
    c("lb", "LBDTC"),
    c("fa", "DCUT_TEMP_FAXDTC")
  ),
  no_cut_v = c("ts"),
  dataset_cut = dcut,
  cut_var = DCUTDTM,
  special_dm = TRUE
)


# Save cut SDTMs to environment -------------------------------------------

list2env(cut_data, envir = globalenv())
