# Name: Datacut Template Code - Modular Approach

# Creating data to be cut ------------------------------------------------

library(here)
source(here("inst/templates/dummy_data.R"))
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


# Specify cut types ------------------------------------------------------

# Patient cut - cut applied will only be for patients existing in DCUT
patient_cut_list <- c("sc", "ds")

# Date cut - cut applied will be both for patients existing in DCUT, and date cut against DCUTDTM
date_cut_list <- rbind(
  c("ae", "AESTDTC"),
  c("lb", "LBDTC"),
  c("fa", "DCUT_TEMP_FAXDTC")
)

# No cut - data does not need to be cut
no_cut_list <- list(ts = source_data$ts)


# Create the cutting variables -------------------------------------------

# Conduct the patient cut ------------------------------------------------
patient_cut_data <- lapply(
  source_data[patient_cut_list], pt_cut,
  dataset_cut = dcut
)

# Conduct xxSTDTC or xxDTC Cut -------------------------------------------
date_cut_data <- pmap(
  .l = list(
    dataset_sdtm = source_data[date_cut_list[, 1]],
    sdtm_date_var = syms(date_cut_list[, 2])
  ),
  .f = date_cut,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)

# Conduct DM special cut for DTH flags after DCUTDTM ---------------------
dm_cut <- special_dm_cut(
  dataset_dm = source_data$dm,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)


# Apply the cut and create the RMD report --------------------------------

# Produce markdown report of what records will be dropped from each SDTM domain
# FUNCTION_MARKDOWN(dataset_sdtm_list,
#                   report_name)

cut_data <- purrr::map(
  c(patient_cut_data, date_cut_data, list(dm = dm_cut)),
  apply_cut,
  dcutvar = DCUT_TEMP_REMOVE,
  dthchangevar = DCUT_TEMP_DTHCHANGE
)

# Add on data which is not cut
final_data <- c(cut_data, no_cut_list, list(dcut = dcut))

list2env(final_data, envir = globalenv())
