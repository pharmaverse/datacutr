# Special DM Cut to reset Death variable information past cut date

Applies patient cut if patient not in source DCUT, as well as clearing
death information within DM if death occurred after datacut date

## Usage

``` r
special_dm_cut(dataset_dm, dataset_cut, cut_var = DCUTDTM)
```

## Arguments

- dataset_dm:

  Input DM SDTMv dataset

- dataset_cut:

  Input datacut dataset

- cut_var:

  Datacut date variable found in the `dataset_cut` dataset, default is
  `DCUTDTM`

## Value

Input dataset plus a flag `DCUT_TEMP_REMOVE` to indicate which
observations would be dropped when a datacut is applied, and a flag
`DCUT_TEMP_DTHCHANGE` to indicate which observations have death
occurring after data cut date for clearing

## Author

Tim Barnett

## Examples

``` r
dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTC, ~DCUTDTM,
  "01-701-1015", "2014-10-20T23:59:59", lubridate::ymd_hms("2014-10-20T23:59:59"),
  "01-701-1023", "2014-10-20T23:59:59", lubridate::ymd_hms("2014-10-20T23:59:59")
)

dm <- tibble::tribble(
  ~USUBJID, ~DTHDTC, ~DTHFL,
  "01-701-1015", "2014-10-20", "Y",
  "01-701-1023", "2014-10-21", "Y",
)

special_dm_cut(
  dataset_dm = dm,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)
#> # A tibble: 2 × 7
#>   USUBJID  DTHDTC DTHFL DCUT_TEMP_REMOVE DCUT_TEMP_DTHDT     DCUT_TEMP_DCUTDTM  
#>   <chr>    <chr>  <chr> <chr>            <dttm>              <dttm>             
#> 1 01-701-… 2014-… Y     NA               2014-10-20 00:00:00 2014-10-20 23:59:59
#> 2 01-701-… 2014-… Y     NA               2014-10-21 00:00:00 2014-10-20 23:59:59
#> # ℹ 1 more variable: DCUT_TEMP_DTHCHANGE <chr>
```
