# Imputes Partial Date/Time Data Cutoff Variable (DCUTDTC)

Imputes partial date/time data cutoff variable (DCUTDTC), as required by
the datacut process.

## Usage

``` r
impute_dcutdtc(dsin, varin, varout)
```

## Arguments

- dsin:

  Name of input data cut dataframe (i.e; DCUT)

- varin:

  Name of input data cutoff variable (i.e; DCUTDTC) which must be in ISO
  8601 extended format (YYYY-MM-DDThh:mm:ss). All values of the data
  cutoff variable must be at least a complete date, or NA.

- varout:

  Name of imputed output variable

## Value

Returns the input data cut dataframe, with the additional of one extra
variable (varout) in POSIXct datetime format, which is the imputed
version of varin.

## Examples

``` r
dcut <- data.frame(
  USUBJID = rep(c("UXYZ123a"), 7),
  DCUTDTC = c(
    "2022-06-23", "2022-06-23T16", "2022-06-23T16:57", "2022-06-23T16:57:30",
    "2022-06-23T16:57:30.123", "2022-06-23T16:-:30", "2022-06-23T-:57:30"
  )
)
dcut_final <- impute_dcutdtc(dsin = dcut, varin = DCUTDTC, varout = DCUTDTM)
```
