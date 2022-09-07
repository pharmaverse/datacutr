# Name: Datacut Template Code
#
# Label: XXX
#
# Input: xx, xx, xx

library(admiral.test) # To be removed

library(dplyr)
library(stringr)
library(lubridate)

###########################################################################
# Create DCUT ------------------------------------------------------------

# Read in DS
ds <- admiral_ds  # To be updated to test tibble

# Outputs DCUT with patients USUBJID, DCUTDTC, DCUTDT and DCUTDESC
FUNCTION_CREATE_DCUT(ds_source,
                     ds_condition,
                     dsstdtc_input,
                     dcutdtc_value,
                     dcutdesc_value,
                     dcutname_out)
# Inputs include
# DS source
# Date of datacut
# Description of datacut
# Checks to ensure no duplicate USUBJID in file
# Runs impute_dcutdtc to create DCUTDT
# Runs imputation function on DSSTDTC - impute_sdtm


##########################################################################
# Example construct applying cut -----------------------------------------

dm <- admiral_dm # Change for example tibbles for cut process
# Include AE, LB, VS, TS, TA.......


# Provide cut approaches --------------------------------------------------
patient_cut <- c("ta","tv")
date_cut <- c("ae","STDTC")
            c("lb","DTC")

# stdtc_cut <- c("AE","DS") - Not used?
# dtc_cut <- c("LB","VS")

# Conduct Patient-Level Cut ----------------------------------------------
# Outputs flagging of patients to drop from analysis
# Applies to patient_cut list

lapply(pt_cut(dataset_sdtm,
              dataset_cut = dcut)
       )

# Inputs:
# Selected SDTMv for patient cut
# Selected DCUT reference
# Outputs:
# Patient cut flagging (DCUT_TEMP_REMOVE)

# Conduct xxSTDTC or xxDTC Cut ---------------------------------------------------

# Create new list based on xxSTDTC to create stdtc_dateref

lapply(sdtm_cut(dataset_sdtm,
                sdtm_date_var,
                dataset_cut = dcut,
                cut_var = DCUTDT)
       )
# Outputs:
# Use impute_sdtm to create temp_date eg. DCUT_TEMP_AESTDT version of AESTDTC
# Adds DCUTDT from reference dcut as DCUT_TEMP_DCUTDT and also applies manually the patient cut flagging (DCUT_TEMP_REMOVE)

# Special FA CUT - New DCUT_TEMP_FAXDTC cmobo of STDTC and DTC - TO BE DEMONSTRATED OR FUNCTION?
sdtm_cut(dataset_sdtm=FA,
         sdtm_date_var=DCUT_TEMP_FAXDTC,
         dataset_cut = dcut,
         cut_var = DCUTDT)

# Cuts on FASTDTC or FADTC depending on populated fields
# Use sdtm_cut


# Conduct DM special cut ------------------------------------------------------
# Outputs flagging of patients and obs to update from analysis
# Merges on DCUTDT & flags patients to drop
# Flags obs with DEATH date after DCUTDT

special_dm_cut(dataset_dm = DM,
               dataset_cut = dcut,
               cut_var = DCUTDT,
               dthcut_var = DTHDTC)
# Outputs:
# DCUT_TEMP_DTHDT created by impute_sdtm function
# Patient cut applied whilst adding on DCUT_TEMP_DCUTDT
# DCUT_TEMP_DTHCHANGE flag

# Apply the cut ------------------------------------------------------
# Creates datesets with all flagged obs removed
# Updates DM flags if applicable
FUNCTION_MARKDOWN(dataset_sdtm_list,
                  report_name)
lapply(FUNCTION_CUT(dataset_sdtm))

# Creates cut versions of data - where do they write to? Do we need to write somewhere physical?
# Drops temporary variables DCUT_TEMP_xxx
# Creates overall report
