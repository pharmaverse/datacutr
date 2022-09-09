# Name: Datacut Template Code
#
# Label: XXX
#
# Input: xx, xx, xx

library(admiral.test) # To be removed
library(dplyr)
library(stringr)
library(lubridate)

##########################################################################
# Create DCUT ------------------------------------------------------------
# Inputs include
# DS source
# Date of datacut
# Description of datacut
# Checks to ensure no duplicate USUBJID in file (not added yet!)
# Runs impute_dcutdtc to create DCUTDT

# Read in DS
ds <- admiral_ds  # To be updated to test tibble

# Dummy dcut dataset for purpose of running code - to be removed
dcut <- dcut <- create_dcut(dataset_ds = ds,
                            filter = DSDECOD == "ADVERSE EVENT",
                            cut_date = "2022-01-01",
                            cut_description = "Clinical Cutoff Date")%>%
        impute_dcutdtc(dsin=., varin=DCUTDTC, varout=DCUTDT)


##########################################################################
# Example construct applying cut -----------------------------------------

# Read in data - include DM, AE, LB, VS, TS, TA.......
dm <- admiral_dm # Change for example tibbles for cut process
ae <- admiral_ae
vs <- admiral_vs
lb <- admiral_lb
ts <- admiral_ts
sv <- admiral_sv
ex <- admiral_ex


# Provide cut approaches --------------------------------------------------
patient_cut <- list(sv = sv,
                    ex = ex)

date_cut <- list(ae = c(ae, var = "AESTDTC"),
                 vs = c(vs, var = "VSDTC"),
                 lb = c(lb, var = "LBDTC"))


# Old Code
# patient_cut <- c("sv", "ex")
#
# date_cut <- rbind(c("ae", "AESTDTC"),
#                   c("vs", "VSDTC"),
#                   c("lb", "LBDTC"))



# Conduct Patient-Level Cut ----------------------------------------------
# Outputs flagging of patients to drop from analysis
# Applies to patient_cut list
# Inputs:
#    Selected SDTMv for patient cut
#    Selected DCUT reference
# Outputs:
#    Patient cut flagging (DCUT_TEMP_REMOVE)


doutlist <- lapply(patient_cut,function(x){
  pt_cut(dataset_sdtm = x[1], dataset_cut = dcut)
})

list2env(doutlist, envir = globalenv())

# Doesn't work since x[1] is a list and function expects a data frame?

# Old Code
# for (i in 1:length(patient_cut)) {
#   assign(noquote(patient_cut[i]), pt_cut(dataset_sdtm = get(patient_cut[i]),
#                                          dataset_cut = dcut))
# }


# Conduct xxSTDTC or xxDTC Cut ---------------------------------------------------
# Create new list based on xxSTDTC to create stdtc_dateref
# Outputs:
#    Use impute_sdtm to create temp_date eg. DCUT_TEMP_AESTDT version of AESTDTC
#    Adds DCUTDT from reference dcut as DCUT_TEMP_DCUTDT and also applies manually the patient cut flagging (DCUT_TEMP_REMOVE)


doutlist <- lapply(date_cut,function(x){
  sdtm_cut(dataset_sdtm = x[1],
           sdtm_date_var = x[2],
           dataset_cut = dcut,
           cut_var = DCUTDT)
})

list2env(doutlist, envir = globalenv())

# Not picking up date variable? Not sure this picks out the list elements correctly?

#Old Code
# for (i in 1:nrow(date_cut)) {
#   assign(noquote(date_cut[i,1]), sdtm_cut(dataset_sdtm = get(date_cut[i,1]),
#                                           sdtm_date_var = !!as.symbol(date_cut[i,2]),
#                                           dataset_cut = dcut,
#                                           cut_var = DCUTDT))
# }

# Special FA CUT - --------------------------------------------------------------
# New DCUT_TEMP_FAXDTC cmobo of STDTC and DTC - TO BE DEMONSTRATED OR FUNCTION?
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
