# Modular Approach

## Introduction

This article describes how to cut study SDTM data using a modular
approach to enable any further study or project specific customization.

## Programming Flow

- [Read in Data](#readdata)
- [Create DCUT Dataset](#dcut)
- [Preprocess Datasets](#preprocess)
- [Specify Cut Types](#cuttypes)
- [Patient Cut](#ptcut)
- [Date Cut](#dtcut)
- [DM Cut](#dmcut)
- [Apply Cut](#applycut)
- [Output Final List of Cut Datasets](#output)

### Read in Data

To start, all SDTM data to be cut needs to be stored in a list.

``` r
library(datacutr)
library(admiraldev)
library(dplyr)
library(lubridate)
library(stringr)
library(purrr)
library(rlang)

source_data <- list(
  ds = datacutr_ds, dm = datacutr_dm, ae = datacutr_ae, sc = datacutr_sc,
  lb = datacutr_lb, fa = datacutr_fa, ts = datacutr_ts
)
```

### Create DCUT Dataset

The next step is to create the DCUT dataset containing the datacut date
and description.

``` r
dcut <- create_dcut(
  dataset_ds = source_data$ds,
  ds_date_var = DSSTDTC,
  filter = DSDECOD == "RANDOMIZATION",
  cut_date = "2022-06-04",
  cut_description = "Clinical Cutoff Date"
)
```

### Preprocess Datasets

If any pre-processing of datasets is needed, for example in the case of
FA, where there are multiple date variables, this should be done next.

``` r
source_data$fa <- source_data$fa %>%
  mutate(DCUT_TEMP_FAXDTC = case_when(
    FASTDTC != "" ~ FASTDTC,
    FADTC != "" ~ FADTC,
    TRUE ~ as.character(NA)
  ))
```

### Specify Cut Types

We’ll next specify the cut types for each dataset (patient cut, date cut
or no cut) and in the case of date cut which date variable should be
used.

``` r
patient_cut_list <- c("sc", "ds")

date_cut_list <- rbind(
  c("ae", "AESTDTC"),
  c("lb", "LBDTC"),
  c("fa", "DCUT_TEMP_FAXDTC")
)

no_cut_list <- list(ts = source_data$ts)
```

### Patient Cut

Next we’ll apply the patient cut.

``` r
patient_cut_data <- lapply(
  source_data[patient_cut_list], pt_cut,
  dataset_cut = dcut
)
```

This adds on temporary flag variables indicating which observations will
be removed, for example for SC:

### Date Cut

Next we’ll apply the date cut.

``` r
date_cut_data <- pmap(
  .l = list(
    dataset_sdtm = source_data[date_cut_list[, 1]],
    sdtm_date_var = syms(date_cut_list[, 2])
  ),
  .f = date_cut,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)
```

This again adds on temporary flag variables indicating which
observations will be removed, for example for AE:

### DM Cut

Then lastly we’ll apply the special DM cut which also updates the death
related variables.

``` r
dm_cut <- special_dm_cut(
  dataset_dm = source_data$dm,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)
```

This adds on temporary variables indicating any death records that would
change as a result of applying a datacut:

### Apply Cut

The last step is to create the RMD report, to summarize which patients
and observations will be cut, and then apply the cut to strip out all
observations flagged as to be removed.

``` r
cut_data <- purrr::map(
  c(patient_cut_data, date_cut_data, list(dm = dm_cut)),
  apply_cut,
  dcutvar = DCUT_TEMP_REMOVE,
  dthchangevar = DCUT_TEMP_DTHCHANGE
)
```

### Output Final List of Cut Datasets

Lastly, we create the final list of all the cut SDTM data, adding in the
SDTM where no cut was needed.

``` r
final_data <- c(cut_data, no_cut_list, list(dcut = dcut))
```
