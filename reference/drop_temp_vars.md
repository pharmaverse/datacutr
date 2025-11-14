# Drops Temporary Variables From a Dataset

Drops all the temporary variables (variables beginning with TEMP\_) from
the input dataset. Also allows the user to specify whether or not to
drop the temporary variables needed throughout multiple steps of the
datacut process (variables beginning with DCUT_TEMP\_).

## Usage

``` r
drop_temp_vars(dsin, drop_dcut_temp = TRUE)
```

## Arguments

- dsin:

  Name of input dataframe

- drop_dcut_temp:

  Whether or not to drop variables beginning with DCUT_TEMP\_
  (TRUE/FALSE).

## Value

Returns the input dataframe, excluding the temporary variables.

## Details

The other functions within this package use `drop_temp_vars` with the
`drop_dcut_temp` argument set to FALSE so that the variables needed
across multiple steps of the process are kept. The final datacut takes
place in the `apply_cut` function, at which point `drop_temp_vars` is
used with the `drop_dcut_temp` argument set to TRUE, so that all
temporary variables are dropped.

## Examples

``` r
ae <- tibble::tribble(
  ~USUBJID, ~AESEQ, ~TEMP_FLAG, ~DCUT_TEMP_REMOVE,
  "subject1", 1, "Y", NA,
  "subject1", 2, "Y", NA,
  "subject1", 3, NA, "Y",
  "subject2", 2, "Y", NA,
  "subject3", 1, NA, "Y",
  "subject4", 1, NA, "Y"
)
drop_temp_vars(dsin = ae) # Drops temp_ and dcut_temp_ variables
#> # A tibble: 6 × 2
#>   USUBJID  AESEQ
#>   <chr>    <dbl>
#> 1 subject1     1
#> 2 subject1     2
#> 3 subject1     3
#> 4 subject2     2
#> 5 subject3     1
#> 6 subject4     1
drop_temp_vars(dsin = ae, drop_dcut_temp = TRUE) # Drops temp_ and dcut_temp_ variables
#> # A tibble: 6 × 2
#>   USUBJID  AESEQ
#>   <chr>    <dbl>
#> 1 subject1     1
#> 2 subject1     2
#> 3 subject1     3
#> 4 subject2     2
#> 5 subject3     1
#> 6 subject4     1
drop_temp_vars(dsin = ae, drop_dcut_temp = FALSE) # Drops temp_ variables
#> # A tibble: 6 × 3
#>   USUBJID  AESEQ DCUT_TEMP_REMOVE
#>   <chr>    <dbl> <chr>           
#> 1 subject1     1 NA              
#> 2 subject1     2 NA              
#> 3 subject1     3 Y               
#> 4 subject2     2 NA              
#> 5 subject3     1 Y               
#> 6 subject4     1 Y               
```
