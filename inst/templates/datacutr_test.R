# Name: Datacut Template Code
#
# Label: XXX
#
# Input: xx, xx, xx

library(rice)

ent_path <- "root/clinical_studies/RO4877533/CDT30169/CA42481/data_processing/SDTMv_testarea/work/work_datacutr_test/outdata_prod"

##########################################################################
# Create DCUT ------------------------------------------------------------

# Read in DS and create temporary datetime variable
ds <- rice_read(paste0(ent_path,"/ds.sas7bdat"))

# Create DCUT base datacut dataset
dcut <- create_dcut(dataset_ds = ds,
                            ds_date_var = DSSTDTC,
                    ds_date_var_imp = DCUT_TEMP_DSSTDTM,
                            filter = DSDECOD == "RANDOMIZED",
                            cut_date = "2020-05-29",
                            cut_description = "Interim Analysis")


# Read in SDTM source data ---------------------------------------------
source_data <- rice_read(
  paste0(
    ent_path, "/", c("dm", "ae", "lb", "fa", "sc"), ".sas7bdat"
  )
)


# Provide cut approaches --------------------------------------------------

# Patient cut - cut applied will only be for patients existing in DCUT
patient_cut <- c("sc")

# Date cut - cut applied will be both for patients existing in DCUT, and date cut against DCUTDTM
date_cut <- rbind(c("ae", "AESTDTC"),
                  c("lb", "LBDTC"))

# Conduct Patient-Level Cut ----------------------------------------------

# Code loop

patient_cut_data <- lapply(
  source_data["sc"], pt_cut, dataset_cut = dcut
)


source_data$fa <- source_data$fa %>%
  mutate(DCUT_TEMP_FAXDTC = case_when(
    FASTDTC!="" ~ FASTDTC,
    FADTC!=""   ~ FADTC,
    TRUE        ~ as.character(NA)
  ))


# Conduct xxSTDTC or xxDTC Cut ---------------------------------------------------
date_cut_data <- purrr::map2(
  source_data[c("ae", "lb", "fa")],
  dplyr::quos(AESTDTC, LBDTC, DCUT_TEMP_FAXDTC),
  date_cut,
  dataset_cut = dcut,
  cut_var = DCUTDTM

)



# Conduct DM special cut for DTH flags after DCUTDTM ------------------------------

dm_cut <- special_dm_cut(dataset_dm = dm,
               dataset_cut = dcut,
               cut_var = DCUTDTM,
               dthcut_var = DTHDTC)

# Apply the cut ------------------------------------------------------
# Produce markdown report of what records will be dropped from each SDTM domain
# FUNCTION_MARKDOWN(dataset_sdtm_list,
#                   report_name)

# Create list of all domains
all_cut <- c(patient_cut, date_cut[,1], "fa", "dm")



# Creates datasets with all flagged obs removed
# Updates DM flags if applicable

cut_data <- purrr::map(
  c(patient_cut_data, date_cut_data,  list(dm = dm_cut)),
  apply_cut,
  dcutvar = DCUT_TEMP_REMOVE,
  dthchangevar = DCUT_TEMP_DTHCHANGE
)



##############################################################################################
# Compare with SAS utility macro on entimICE #################################################
cut_path <- "root/clinical_studies/RO4877533/CDT30169/CA42481/data_processing/SDTMv_testarea/work/work_datacutr_test/outdata_cut"

compare_cut <- rice_read(
  paste0(
    cut_path, "/", c("dcut","sc", "ae", "lb", "fa", "dm"), ".sas7bdat"
  )
)



library(diffdf)

comps <- purrr::pmap(
  list(compare_cut,
  c(
    list(dcut = dcut), cut_data)
  ,
  list(
    "USUBJID",
    c("USUBJID","SCSEQ"),
    c("USUBJID","AESTDTC","AESEQ"),
    c("USUBJID","LBDTC","LBSEQ"),
    c("USUBJID","FASTDTC","FADTC","FASEQ"),
    "USUBJID"

  )),
  diffdf

)


#' if we want to extract all of the cut datasets as variables, we can do
#'
list2env(cut_data, envir = globalenv())



