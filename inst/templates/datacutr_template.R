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

# Outputs DCUT with patients, DCUTDTC, DCUTDT and DCUTDESC
FUNCTION_CREATE_DCUT()
# Inputs include
# DS source
# Date of datacut
# Description of datacut


##########################################################################
# Example construct applying cut -----------------------------------------

dm <- admiral_dm # Change for example tibbles for cut process
# Include AE, LB, VS, TS, TA.......


# Provide cut approaches --------------------------------------------------
patient_cut <- c("TA","TV")
stdtc_cut <- c("AE","DS")
dtc_cut <- c("LB","VS")

# Conduct Patient-Level Cut ----------------------------------------------
# Outputs flagging of patients to drop from analysis
# Applies to patient_cut list

lapply(FUNCTION_PATIENTCUT)
# Inputs:
# Selected SDTMv ds
# Selected DCUT ds
# Selected DCUT date from DCUT

# Conduct xxSTDTC Cut ---------------------------------------------------
# Outputs flagging of patients and obs to drop from analysis
# Applies to stdtc_cut list & dtc_cut list
# Merges on DCUTDT & flags patients to drop
# Flags obs with date after DCUTDT
# Cuts on FASTDTC or FADTC depending on populated fields
# Use FUNCTION_select_date(XXXX)?


lapply(FUNCTION_DATECUT)
# Inputs:
# Selected SDTMv ds
# Selected date from DCUT
# Selected DCUT ds
# Selected SDTMv date from SDTMv


# Conduct DM special cut ------------------------------------------------------
# Outputs flagging of patients and obs to update from analysis
# Merges on DCUTDT & flags patients to drop
# Flags obs with DEATH date after DCUTDT

FUNCTION_SPECIALDM()
# Inputs:
# Selected DM ds
# Selected date from DCUT
# Selected DCUT ds
# Selected SDTMv date from SDTMv

# Apply the cut ------------------------------------------------------
# Creates datesets with all flagged obs removed
# Updates DM flags if applicable
lapply(FUNCTION_CUT)

# Create report of cut applied and result -------------------------------------
lapply(FUNCTION_MARKDOWNREPORT)
