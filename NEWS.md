# datacutr 0.2.2

## Updates of Existing Functions
None

## Various
Tests using temporary directories cleaned up

# datacutr 0.2.1

## Updates of Existing Functions
- Update `read_out` to write to temporary drive

# datacutr 0.2.0

## New Features
- Added a "Report a bug" link to `{datacutr}` website (#182)
- Added a `read_out` function that enables the generation of a read-out file (.html), to summarize changes applied to data during a datacut. (#107)

## Updates of Existing Functions
- Update to `impute_dcutdtc()`, `date_cut()` and `special_dm_cut()` functions to allow for 
datacut date to be null. In this case, all records for this patient 
will be kept/left unchanged. (#179, #189, #190)
- Warning added to `process_cut` if expected dataset `dm` is missing (#172)
- Warning added to `create_dcut` if cut date being passed as `NULL`, 
and not valid date or `NA`/`""` (#181)
- `process_cut` updated so that the `patient_cut_v`, `date_cut_m` and `no_cut_v`
arguments have a default value of `NULL` (#188)
- `process_cut` updated to have more detailed error messages when incorrect datasets 
are fed in (#180)
- `process_cut` updated to have arguments `read_out` and `out_path` to integrate the `read_out` function into the wrapper function; enabling auto-generation of the datacutr read-out file (#107)

## Breaking Changes
- Added dependency on `admiraldev` >= 0.3.0 (#173)
- Added dependency on R version >= 4.1 due to an update in `admiraldev` to use R native pipe

## Documentation
- Added notes on SDTM compatibility (#171)
- Cleaned install packages code format (#177)
- Fixed broken link to source (#184)
- Added report a bug link to site (#182)

## Various
- Added CRAN badge to site (#174)
- Pull Request template updated (#192)

# datacutr 0.1.0

## New Features
- First release of functions for SDTM datacut
- New {datacutr} website created

## Updates of Existing Functions
- N/A

## Breaking Changes
- N/A

## Documentation
- N/A

## Various
- N/A

