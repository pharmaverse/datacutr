# Create Datacut Dataset (DCUT)

After filtering the input DS dataset based on the given filter
condition, any records where the SDTMv datetime variable is on or before
the datacut datetime (after imputations) will be returned in the output
datacut dataset (DCUT).

## Usage

``` r
create_dcut(dataset_ds, ds_date_var, filter = NULL, cut_date, cut_description)
```

## Arguments

- dataset_ds:

  Input DS SDTMv dataset

- ds_date_var:

  Character datetime variable in the DS SDTMv to be compared against the
  datacut date. Must be in the ISO 8601 format (YYYY-MM-DDThh:mm:ss).
  Will be imputed using the
  [`impute_sdtm()`](https://pharmaverse.github.io/datacutr/reference/impute_sdtm.md)
  function.

- filter:

  Condition to filter patients in DS, should give 1 row per patient

- cut_date:

  Datacut datetime, e.g. "2022-10-22", "22OCT2022", or NA if no date cut
  is to be applied. Must be at least a complete date (can also include
  time) in either ISO 8601 (YYYY-MM-DDThh:mm:ss) or DDMMMYYYY formats.
  Will be imputed using the
  [`impute_dcutdtc()`](https://pharmaverse.github.io/datacutr/reference/impute_dcutdtc.md)
  function.

- cut_description:

  Datacut date/time description, e.g. "Clinical Cut Off Date"

## Value

Datacut dataset containing the variables `USUBJID`, `DCUTDTC`, `DCUTDTM`
and `DCUTDESC`.

## Author

Alana Harris

## Examples

``` r
ds <- tibble::tribble(
  ~USUBJID, ~DSSEQ, ~DSDECOD, ~DSSTDTC,
  "subject1", 1, "INFORMED CONSENT", "2020-06-23",
  "subject1", 2, "RANDOMIZATION", "2020-08-22",
  "subject1", 3, "WITHDRAWAL BY SUBJECT", "2020-05-01",
  "subject2", 1, "INFORMED CONSENT", "2020-07-13",
  "subject3", 1, "INFORMED CONSENT", "2020-06-03",
  "subject4", 1, "INFORMED CONSENT", "2021-01-01",
  "subject4", 2, "RANDOMIZATION", "2023-01-01"
)

dcut <- create_dcut(
  dataset_ds = ds,
  ds_date_var = DSSTDTC,
  filter = DSDECOD == "RANDOMIZATION",
  cut_date = "2022-01-01",
  cut_description = "Clinical Cutoff Date"
)
```
