# Imputes Partial Date/Time SDTMv Variables

Imputes partial date/time SDTMv variables, as required by the datacut
process.

## Usage

``` r
impute_sdtm(dsin, varin, varout)
```

## Arguments

- dsin:

  Name of input SDTMv dataframe

- varin:

  Name of input SDTMv character date/time variable, which must be in ISO
  8601 extended format (YYYY-MM-DDThh:mm:ss). The use of date/time
  intervals are not permitted.

- varout:

  Name of imputed output variable

## Value

Returns the input SDTMv dataframe, with the addition of one extra
variable (varout) in POSIXct datetime format, which is the imputed
version of varin.

## Examples

``` r
ex <- data.frame(
  USUBJID = rep(c("UXYZ123a"), 13),
  EXSTDTC = c(
    "", "2022", "2022-06", "2022-06-23", "2022-06-23T16", "2022-06-23T16:57",
    "2022-06-23T16:57:30", "2022-06-23T16:57:30.123", "2022-06-23T16:-:30",
    "2022-06-23T-:57:30", "2022-06--T16:57:30", "2022---23T16:57:30", "--06-23T16:57:30"
  )
)
ex_imputed <- impute_sdtm(dsin = ex, varin = EXSTDTC, varout = DCUT_TEMP_EXSTDTC)
```
