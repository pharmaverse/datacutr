# Patient Cut

Use to apply a patient cut to an SDTMv dataset (i.e. subset SDTMv
observations on patients included in the dataset_cut input dataset)

## Usage

``` r
pt_cut(dataset_sdtm, dataset_cut)
```

## Arguments

- dataset_sdtm:

  Input SDTMv dataset

- dataset_cut:

  Input datacut dataset, e.g. dcut

## Value

Input dataset plus a flag `DCUT_TEMP_REMOVE` to indicate which
observations would be dropped when a patient level datacut is applied

## Author

Alana Harris

## Examples

``` r
library(lubridate)
dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTM,
  "subject1", ymd_hms("2020-10-11T23:59:59"),
  "subject2", ymd_hms("2020-10-11T23:59:59"),
  "subject4", ymd_hms("2020-10-11T23:59:59")
)

ae <- tibble::tribble(
  ~USUBJID, ~AESEQ, ~AESTDTC,
  "subject1", 1, "2020-01-02T00:00:00",
  "subject1", 2, "2020-08-31T00:00:00",
  "subject1", 3, "2020-10-10T00:00:00",
  "subject2", 2, "2020-02-20T00:00:00",
  "subject3", 1, "2020-03-02T00:00:00",
  "subject4", 1, "2020-11-02T00:00:00"
)

ae_out <- pt_cut(
  dataset_sdtm = ae,
  dataset_cut = dcut
)
```
