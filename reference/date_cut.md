# xxSTDTC or xxDTC Cut

Use to apply a datacut to either an xxSTDTC or xxDTC SDTM date variable.
The datacut date from the datacut dataset is merged on to the input
SDTMv dataset and renamed to `TEMP_DCUT_DCUTDTM`. A flag
`TEMP_DCUT_REMOVE` is added to the dataset to indicate the observations
that would be removed when the cut is applied. Note that this function
applies a patient level datacut at the same time (using the
[`pt_cut()`](https://pharmaverse.github.io/datacutr/reference/pt_cut.md)
function), and also imputes dates in the specified SDTMv dataset (using
the
[`impute_sdtm()`](https://pharmaverse.github.io/datacutr/reference/impute_sdtm.md)
function).

## Usage

``` r
date_cut(dataset_sdtm, sdtm_date_var, dataset_cut, cut_var)
```

## Arguments

- dataset_sdtm:

  Input SDTMv dataset

- sdtm_date_var:

  Input date variable found in the `dataset_sdtm` dataset

- dataset_cut:

  Input datacut dataset

- cut_var:

  Datacut date variable

## Value

Input dataset plus a flag `TEMP_DCUT_REMOVE` to indicate which
observations would be dropped when a datacut is applied

## Author

Alana Harris

## Examples

``` r
library(lubridate)
#> 
#> Attaching package: ‘lubridate’
#> The following objects are masked from ‘package:base’:
#> 
#>     date, intersect, setdiff, union
dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTM, ~DCUTDTC,
  "subject1", ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
  "subject2", ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
  "subject4", ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59"
)

ae <- tibble::tribble(
  ~USUBJID, ~AESEQ, ~AESTDTC,
  "subject1", 1, "2020-01-02T00:00:00",
  "subject1", 2, "2020-08-31T00:00:00",
  "subject1", 3, "2020-10-10T00:00:00",
  "subject2", 2, "2020-02-20T00:00:00",
  "subject3", 1, "2020-03-02T00:00:00",
  "subject4", 1, "2020-11-02T00:00:00",
  "subject4", 2, ""
)

ae_out <- date_cut(
  dataset_sdtm = ae,
  sdtm_date_var = AESTDTC,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)
```
