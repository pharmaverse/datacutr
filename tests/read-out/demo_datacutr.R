# Demo Datacutr - Exploratory Work
# Creating data to be cut ------------------------------------------------
library(datacutr)
library(admiraldev)
library(dplyr)
library(lubridate)
library(stringr)
library(purrr)

source_data <- list(ds = datacutr_ds, dm = datacutr_dm, ae = datacutr_ae, sc = datacutr_sc, lb = datacutr_lb, fa = datacutr_fa, ts = datacutr_ts)


# Name: Datacut Template Code - Modular Approach ################################################################
## Create DCUT ------------------------------------------------------------

dcut <- create_dcut(
  dataset_ds = source_data$ds,
  ds_date_var = DSSTDTC,
  filter = DSDECOD == "RANDOMIZATION",
  cut_date = "2022-06-04",
  cut_description = "Clinical Cutoff Date"
)

dcut

## Pre-processing of FA ----------------------------------------------------

## Update FA
source_data$fa <- source_data$fa %>%
  mutate(DCUT_TEMP_FAXDTC = case_when(
    FASTDTC != "" ~ FASTDTC,
    FADTC != "" ~ FADTC,
    TRUE ~ as.character(NA)
  ))


## Specify cut types ------------------------------------------------------

## Patient cut - cut applied will only be for patients existing in DCUT
patient_cut_list <- c("sc", "ds")

## Date cut - cut applied will be both for patients existing in DCUT, and date cut against DCUTDTM
date_cut_list <- rbind(
  c("ae", "AESTDTC"),
  c("lb", "LBDTC"),
  c("fa", "DCUT_TEMP_FAXDTC")
)

## No cut - data does not need to be cut
no_cut_list <- list(ts = source_data$ts)

## Create the cutting variables -------------------------------------------

## Conduct the patient cut ------------------------------------------------
patient_cut_data <- lapply(
  source_data[patient_cut_list], pt_cut,
  dataset_cut = dcut
)
patient_cut_data

## Conduct xxSTDTC or xxDTC Cut -------------------------------------------
date_cut_data <- pmap(
  .l = list(
    dataset_sdtm = source_data[date_cut_list[, 1]],
    sdtm_date_var = syms(date_cut_list[, 2])
  ),
  .f = date_cut,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)

date_cut_data

## Conduct DM special cut for DTH flags after DCUTDTM ---------------------
dm_cut <- special_dm_cut(
  dataset_dm = source_data$dm,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)

dm_cut

## Apply the cut --------------------------------

cut_data <- purrr::map(
  c(patient_cut_data, date_cut_data, list(dm = dm_cut)),
  apply_cut,
  dcutvar = DCUT_TEMP_REMOVE,
  dthchangevar = DCUT_TEMP_DTHCHANGE
)

cut_data

## Add on data which is not cut
final_data <- c(cut_data, no_cut_list, list(dcut = dcut))

final_data

# Name: Datacut Template Code - Wrapped Approach #########################################################

## Creating data to be cut ------------------------------------------------

source_data <- list(ds = datacutr_ds, dm = datacutr_dm, ae = datacutr_ae, sc = datacutr_sc, lb = datacutr_lb, fa = datacutr_fa, ts = datacutr_ts)

## Create DCUT ------------------------------------------------------------

dcut <- create_dcut(
  dataset_ds = source_data$ds,
  ds_date_var = DSSTDTC,
  filter = DSDECOD == "RANDOMIZATION",
  cut_date = "2022-06-04",
  cut_description = "Clinical Cutoff Date"
)

dcut

## Pre-processing of FA ----------------------------------------------------

## Update FA
source_data$fa <- source_data$fa %>%
  mutate(DCUT_TEMP_FAXDTC = case_when(
    FASTDTC != "" ~ FASTDTC,
    FADTC != "" ~ FADTC,
    TRUE ~ as.character(NA)
  ))


## Process data cut --------------------------------------------------------

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

cut_data

gSheet_cut_data(cut_data = cut_data)

# Exporting into gSheet ###############################################################################################

gSheet_cut_data(cut_data = data)
