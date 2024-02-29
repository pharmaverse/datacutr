# Combining the cut data ###############
## Conduct the patient cut ------------------------------------------------
patient_cut_data <- lapply(
  source_data[patient_cut_list], pt_cut,
  dataset_cut = dcut,
)

patient_cut_data

patient_cut_data2 <- lapply(
  seq_along(patient_cut_data), function(i){
    patient_cut_data[[i]]$CUT_TYPE <- "Patient"
    return(patient_cut_data)
  }
)

for (df in patient_cut_data2){
  print(df)
}

patient_cut_data2 <- cut_label(cut_data = patient_cut_data)

## Conduct xxSTDTC or xxDTC Cut -------------------------------------------
date_cut_data <- pmap(
  .l = list(
    dataset_sdtm = source_data[date_cut_list[, 1]],
    sdtm_date_var = syms(date_cut_list[, 2])
  ),
  .f = date_cut,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)

date_cut_data

## Conduct DM special cut for DTH flags after DCUTDTM ---------------------
dm_cut <- special_dm_cut(
  dataset_dm = source_data$dm,
  dataset_cut = dcut,
  cut_var = DCUTDTM
)

dm_cut
