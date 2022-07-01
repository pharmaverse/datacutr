# Name: Datacut Template Code
#
# Label: XXX
#
# Input: xx, xx, xx
library(admiral)
library(admiral.test) # Contains example datasets from the CDISC pilot project


# Example construct creating DCUT

library(dplyr)
library(rice)

# Read in source DS
ds <- rice_read("root/clinical_studies/RO7200220/CDT70193/BP40899/data_analysis/BASE/data/sdtmv/ds.sas7bdat")

# Filter DS as appropriate - default DSTERM="RANDOMIZATION" but may differ
# Select USUBJID, DSSTDTC

ds_select <- ds %>%
  # filter(DSTERM=="RANDOMIZATION") %>%
  filter(DSTERM=="ENROLLMENT") %>%
  select(USUBJID, DSSTDTC)

# Assign DCUTDTC in ISO format
dcutdate <- "2022-01-01"

ds_addcut <- ds_select %>%
  mutate(DCUTDTC=dcutdate)

# Create DCUTDT
# Impute time if not given
FUNCTION_create_dcut_datetime(DCUTDT)

# Create new temp var for date of DSSTDTC
FUNCTION_create_sdtmv_datetime(DSSDTC, TEMP_DSSDT)

# Remove records from DS where DSSTDTC is after cut DCUTDTC
FUNCTION_PATIENTCUT(DCUTDT, TEMP_DSSDT)

# Assign DCUTDESC
dcutdesc <- "Primary Analysis Cut"
ds_adddesc <- ds_cut %>%
  mutate(DCUTDESC=dcutdesc)

# Return dataframe with USUBJID, DCUTDTC, DCUTDT and DCUTDESC
dcut_final <- ds_adddesc %>%
  select(USUBJID,DCUTDTC,DCUTDT,DCUTDESC)




# Example construct applying cut


library(dplyr)
library(rice)

# Read in source SDTM
ae <- rice_read("root/clinical_studies/RO7200220/CDT70193/BP40899/data_analysis/BASE/data/sdtmv/ae.sas7bdat", prolong=TRUE)
dm <- rice_read("root/clinical_studies/RO7200220/CDT70193/BP40899/data_analysis/BASE/data/sdtmv/dm.sas7bdat")

# Read in DCUT
dcut <- final_dcut

# Provide cut approaches
patient_cut <- c("YI","TV")
stdtc_cut <- c("AE","DS")
dtc_cut <- c("LB","VS")

# Conduct Patient-Level Cut - output cut dataset plus records removed dataset
FUNCTION_PATIENTCUT(patient_cut)
# or
lapply(patient_cut,FUNCTION_PATIENTCUT) - Probably this approach

# Conduct xxSTDTC Cut - output cut dataset plus records removed dataset
FUNCTION_create_sdtmv_datetime(xxSTDTC, TEMP_DT)

FUNCTION_PATIENTCUT(patient_cut)
FUNCTION_SDTMVCUT(TEMP_DT)

# Conduct xxDTC Cut - output cut dataset plus records removed dataset
FUNCTION_create_sdtmv_datetime(xxDTC, TEMP_DT)

FUNCTION_PATIENTCUT(patient_cut)
FUNCTION_SDTMVCUT(TEMP_DT)

# FA approach
FUNCTION_select_date(xxSTDTC, xxDTC, TEMP_NEWDTC)

FUNCTION_create_sdtmv_datetime(TEMP_NEWDTC, TEMP_DT)

FUNCTION_PATIENTCUT(patient_cut)
FUNCTION_SDTMVCUT(TEMP_DT)

# Conduct DM special cut - output cut dataset plus records removed dataset (plus records altered dataset)
FUNCTION_create_sdtmv_datetime(DMDTC, TEMP_DMTC)

FUNCTION_PATIENTCUT(patient_cut)
FUNCTION_SPECIALDM(dm, dmdtc)

# Create report of cut applied and result
FUNCTION_MARKDOWNREPORT()
