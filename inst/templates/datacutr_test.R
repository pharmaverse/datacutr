# Name: Datacut Template Code
#
# Label: XXX
#
# Input: xx, xx, xx

library(admiral)
library(rice)

ent_path <- "root/clinical_studies/RO4877533/CDT30169/CA42481/data_processing/SDTMv_testarea/work/work_datacutr_test/outdata_prod"

##########################################################################
# Create DCUT ------------------------------------------------------------

# Read in DS
ds <- rice_read(paste0(ent_path,"/ds.sas7bdat"))

ds_temp <- ds %>%
  impute_sdtm(varin=DSSTDTC,
              varout=DCUT_TEMP_DSSDT)

# Create DCUT base datacut dataset
dcut <- create_dcut(dataset_ds = ds_temp,
                            filter = DSDECOD == "RANDOMIZED" & DCUTDT>=DCUT_TEMP_DSSDT,
                            cut_date = "2020-05-29",
                            cut_description = "Interim Analysis")


# Read in data
dm <- rice_read(paste0(ent_path,"/dm.sas7bdat"),prolong=TRUE)
ae <- rice_read(paste0(ent_path,"/ae.sas7bdat"),prolong=TRUE)
lb <- rice_read(paste0(ent_path,"/lb.sas7bdat"),prolong=TRUE)
fa <- rice_read(paste0(ent_path,"/fa.sas7bdat"),prolong=TRUE)
sc <- rice_read(paste0(ent_path,"/sc.sas7bdat"))

# Provide cut approaches --------------------------------------------------

# Patient cut
patient_cut <- c("sc")

# Date cut
date_cut <- rbind(c("ae", "AESTDTC"),
                  c("lb", "LBDTC"))

# Conduct Patient-Level Cut ----------------------------------------------

# Code loop
for (i in 1:length(patient_cut)) {
  assign(noquote(patient_cut[i]),
         pt_cut(dataset_sdtm = get(patient_cut[i]),
                dataset_cut = dcut))
}


# Conduct xxSTDTC or xxDTC Cut ---------------------------------------------------

# Code loop
for (i in 1:nrow(date_cut)) {
  assign(noquote(date_cut[i,1]),
         sdtm_cut(dataset_sdtm = get(date_cut[i,1]),
                  sdtm_date_var = !!as.symbol(date_cut[i,2]),
                  dataset_cut = dcut,
                  cut_var = DCUTDT))
}

# Special FA CUT to cut on either xxSTDTC or xxDTC depending on data ------------

fa <- fa %>%
  mutate(DCUT_TEMP_FAXDTC = case_when(
    FASTDTC!="" ~ FASTDTC,
    FADTC!=""   ~ FADTC,
    TRUE        ~ as.character(NA)
  ))

fa <- sdtm_cut(dataset_sdtm=fa,
         sdtm_date_var=DCUT_TEMP_FAXDTC,
         dataset_cut = dcut,
         cut_var = DCUTDT)


# Conduct DM special cut for DTH flags ------------------------------------------------------

dm <- special_dm_cut(dataset_dm = DM,
               dataset_cut = dcut,
               cut_var = DCUTDT,
               dthcut_var = DTHDTC)

# Apply the cut ------------------------------------------------------
# Produce markdown report of what records will be dropped from each SDTM domain
# FUNCTION_MARKDOWN(dataset_sdtm_list,
#                   report_name)

# Create list of all domains
all_cut <- c(patient_cut, date_cut[,1], "fa", "dm")

# Creates datasets with all flagged obs removed
# Updates DM flags if applicable
for (i in 1:length(all_cut)) {
  assign(noquote(all_cut[i]),
         apply_cut(dsin = get(all_cut[i]),
                dcutvar = DCUT_TEMP_REMOVE,
                dthchangevar = DCUT_TEMP_DTHCHANGE))
}


# Compare with SAS utility #################################################
cut_path <- "root/clinical_studies/RO4877533/CDT30169/CA42481/data_processing/SDTMv_testarea/work/work_datacutr_test/outdata_cut"

dcut_ent <- rice_read(paste0(cut_path,"/dcut.sas7bdat"), prolong=TRUE)
ae_ent <- rice_read(paste0(cut_path,"/ae.sas7bdat"), prolong=TRUE)
lb_ent <- rice_read(paste0(cut_path,"/lb.sas7bdat"), prolong=TRUE)
fa_ent <- rice_read(paste0(cut_path,"/fa.sas7bdat"), prolong=TRUE)
sc_ent <- rice_read(paste0(cut_path,"/sc.sas7bdat"), prolong=TRUE)
dm_ent <- rice_read(paste0(cut_path,"/dm.sas7bdat"))

library(diffdf)
diffdf(dcut_ent,dcut, keys = "USUBJID")
diffdf(ae_ent,ae, keys = c("USUBJID","AESTDTC","AESEQ"))
diffdf(lb_ent,lb, keys = c("USUBJID","LBDTC","LBSEQ"))
diffdf(fa_ent,fa, keys = c("USUBJID","FASTDTC","FADTC","FASEQ"))
diffdf(sc_ent,sc, keys = c("USUBJID","SCSEQ"))
diffdf(dm_ent,dm, keys = c("USUBJID"))
