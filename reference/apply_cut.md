# Applies the datacut based on the datacut flagging variables

Removes any records where the datacut flagging variable, usually called
DCUT_TEMP_REMOVE, is marked as "Y". Also, sets the death related
variables in DM (DTHDTC and DTHFL) to NA if the death after datacut
flagging variable, usually called DCUT_TEMP_DTHCHANGE, is marked as "Y".

## Usage

``` r
apply_cut(dsin, dcutvar, dthchangevar)
```

## Arguments

- dsin:

  Name of input dataframe

- dcutvar:

  Name of datacut flagging variable created by `pt_cut` and `date_cut`
  functions - usually called DCUT_TEMP_REMOVE.

- dthchangevar:

  Name of death after datacut flagging variable created by
  `special_dm_cut` function - usually called DCUT_TEMP_DTHCHANGE.

## Value

Returns the input dataframe, excluding any rows in which `dcutvar` is
flagged as "Y". DTHDTC and DTHFL are set to NA for any records where
`dthchangevar` is flagged as "Y". Any variables with the "DCUT_TEMP"
prefix are removed.

## Examples

``` r
ae <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123c", "UXYZ123d"),
  DCUT_TEMP_REMOVE = c("Y", "", "NA", NA)
)
ae_final <- apply_cut(dsin = ae, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = DCUT_TEMP_DTHCHANGE)

dm <- data.frame(
  USUBJID = c("UXYZ123a", "UXYZ123b", "UXYZ123b"),
  DTHDTC = c("2014-10-20", "2014-10-21", "2013-09-08"),
  DTHFL = c("Y", "Y", "Y"),
  DCUT_TEMP_REMOVE = c(NA, NA, "Y"),
  DCUT_TEMP_DTHCHANGE = c(NA, "Y", "")
)
dm_final <- apply_cut(dsin = dm, dcutvar = DCUT_TEMP_REMOVE, dthchangevar = DCUT_TEMP_DTHCHANGE)
```
