# Name: Datacut Template Code
#
# Label: XXX
#
# Input: xx, xx, xx

library(admiral)
library(admiral.test) # Contains example datasets from the CDISC pilot project

library(dplyr)
library(stringr)
library(lubridate)

###########################################################################
# Create DCUT ------------------------------------------------------------

# Read in DS
ds <- admiral_ds

# Filter DS as appropriate, default DSTERM="RANDOMIZATION" but may differ ----
# Select USUBJID, DSSTDTC

ds_select <- ds %>%
  # filter(DSTERM=="RANDOMIZATION") %>%
  filter(DSTERM!="PROTOCOL COMPLETED") %>%
  select(USUBJID, DSSTDTC) %>%
  # group_by(USUBJID) %>%
  # filter(row_number()==1) %>%
  # ungroup()

# Assign DCUTDTC in ISO format --------------------------------------------
dcutdate <- "2014-10-20T23:59:59"
ds_addcut <- ds_select %>%
  mutate(DCUTDTC=dcutdate)

# Create DCUTDT -----------------------------------------------------------
# Impute time if not given
FUNCTION_create_dcut_datetime(XXXX)

ds_adddtcut <- ds_addcut %>%
  mutate(DCUTDT = ymd_hms(DCUTDTC))

# Create new temp var for date of DSSTDTC --------------------------------
FUNCTION_create_sdtmv_datetime(XXXX)

ds_dtc <- ds_adddtcut %>%
  mutate(TEMP_DSSDT = ymd_hms(str_c(DSSTDTC,"T00:00:00")))

# Remove records from DS where DSSTDTC is after cut DCUTDTC --------------
FUNCTION_PATIENTCUT(XXXX)

ds_cut <- ds_dtc %>%
  filter(TEMP_DSSDT<=DCUTDT)

# Assign DCUTDESC --------------------------------------------------------
dcutdesc <- "Primary Analysis Cut"
ds_adddesc <- ds_cut %>%
  mutate(DCUTDESC=dcutdesc)

# Return dataframe with USUBJID, DCUTDTC, DCUTDT and DCUTDESC ------------
dcut <- ds_adddesc %>%
  select(USUBJID,DCUTDTC,DCUTDT,DCUTDESC)


##########################################################################
# Example construct applying cut -----------------------------------------

dm <- admiral_dm


# Provide cut approaches --------------------------------------------------
patient_cut <- c("YI","TV")
stdtc_cut <- c("AE","DS")
dtc_cut <- c("LB","VS")

# Conduct Patient-Level Cut ----------------------------------------------
# output cut dataset plus records removed dataset

lapply(patient_cut,FUNCTION_PATIENTCUT) # Probably this approach

# Conduct xxSTDTC Cut ---------------------------------------------------
# output cut dataset plus records removed dataset
FUNCTION_create_sdtmv_datetime(XXXX)

FUNCTION_PATIENTCUT(XXXX)
FUNCTION_SDTMVCUT(XXXX)

# Conduct xxDTC Cut -----------------------------------------------------
# output cut dataset plus records removed dataset
FUNCTION_create_sdtmv_datetime(XXXX)

FUNCTION_PATIENTCUT(XXXX)
FUNCTION_SDTMVCUT(XXXX)

# Special approach for FA -------------------------------------------------
# Cuts on FASTDTC or FADTC depending on populated fields
FUNCTION_select_date(XXXX)

FUNCTION_create_sdtmv_datetime(XXXX)

FUNCTION_PATIENTCUT(XXXX)
FUNCTION_SDTMVCUT(XXXX)

# Conduct DM special cut ------------------------------------------------------
# output cut dataset plus records removed dataset (plus records altered dataset)

FUNCTION_PATIENTCUT(XXXX)
FUNCTION_create_sdtmv_datetime(XXXX)

# dm_ptcut <- pt_cut(dataset_sdtm=dm,
#                    dataset_cut = dcut ,
#                    cut_var = DCUTDT,
#                    cut_type = "cut")
#
# dm_tempdt <- dm_ptcut %>%
#   mutate(DTHDT = case_when(
#     DTHDTC!="" ~ str_c(DTHDTC,"T00:00:00")
#   )) %>%
#   mutate(TEMP_DTHDT=ymd_hms(DTHDT)) %>%
#   select(-DTHDT)

FUNCTION_SPECIALDM(XXXX)

# Create report of cut applied and result -------------------------------------
FUNCTION_MARKDOWNREPORT(XXXX)
