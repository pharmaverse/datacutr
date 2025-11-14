# Function to generate datacut summary file

Produces a .html file summarizing the changes applied to data during a
data cut. The file will contain an overview for the change in number of
records for each dataset, the types of cut applied and the opportunity
to inspect the removed records.

## Usage

``` r
read_out(
  dcut = NULL,
  patient_cut_data = NULL,
  date_cut_data = NULL,
  dm_cut = NULL,
  no_cut_list = NULL,
  out_path = tempdir()
)
```

## Arguments

- dcut:

  The output datacut dataset (DCUT), created via the
  [`create_dcut()`](https://pharmaverse.github.io/datacutr/reference/create_dcut.md)
  function, containing the variable DCUTDTC.

- patient_cut_data:

  A list of quoted SDTMv domain names in which a patient cut has been.
  applied (via the
  [`pt_cut()`](https://pharmaverse.github.io/datacutr/reference/pt_cut.md)
  function). To be left blank if a patient cut has not been performed on
  any domains.

- date_cut_data:

  A list of quoted SDTMv domain names in which a date cut has been
  applied. (via the
  [`date_cut()`](https://pharmaverse.github.io/datacutr/reference/date_cut.md)
  function). To be left blank if a date cut has not been performed on
  any domains.

- dm_cut:

  The output dataset, created via the
  [`special_dm_cut()`](https://pharmaverse.github.io/datacutr/reference/special_dm_cut.md)
  function, containing the variables DCUT_TEMP_REMOVE and
  DCUT_TEMP_DTHCHANGE.

- no_cut_list:

  List of of quoted SDTMv domain names in which no cut should be
  applied. To be left blank if no domains are to remain exactly as
  source.

- out_path:

  A character vector of file save path for the summary file; the default
  corresponds to a temporary directory,
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

## Value

Returns a .html file summarizing the changes made to data during a
datacut.

## Examples

``` r
if (FALSE) { # \dontrun{
dcut <- tibble::tribble(
  ~USUBJID, ~DCUTDTM, ~DCUTDTC,
  "subject1", lubridate::ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
  "subject2", lubridate::ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59",
  "subject4", lubridate::ymd_hms("2020-10-11T23:59:59"), "2020-10-11T23:59:59"
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

dm <- tibble::tribble(
  ~USUBJID, ~DTHDTC, ~DTHFL,
  "subject1", "2020-10-11", "Y",
  "subject2", "2020-10-12", "Y",
)

dt_ae <- date_cut(
  dataset_sdtm = ae,
  sdtm_date_var = AESTDTC,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)

pt_ae <- pt_cut(
  dataset_sdtm = ae,
  dataset_cut = dcut
)

dm_cut <- special_dm_cut(
  dataset_dm = dm,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)

read_out(dcut, patient_cut_data = list(ae = pt_ae), date_cut_data = list(ae = dt_ae), dm_cut)
} # }
```
