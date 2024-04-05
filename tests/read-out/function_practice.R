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

## Summary Table ----

df_tabs <- function(data){
  cyc_num <- 1
  for (df in data){
    name <- names(data)[cyc_num]
    table <- data[cyc_num]
    cat("####", name, " \n")
    print(knitr::kable(table))
    cat(' \n\n')
    cyc_num <- cyc_num + 1
  }
}

summary <- function(data){
  cyc_num <- 1
  for (df in data){
    name <- names(data)[cyc_num]
    print(df)
    x <- length(which(df$DCUT_TEMP_REMOVE == "Y"))
    print(paste("Number of records removed in ", name, " is ", x))
    cyc_num <- cyc_num + 1
  }
}


summary(patient_cut_data)

sep_dfs(patient_cut_data)

patient_cut_data$sc

tb <- patient_cut_data[1]
tb2 <- data.frame(tb)
x <- length(which(patient_cut_data$sc$DCUT_TEMP_REMOVE == "Y"))
x <- length(which(dm_cut$DCUT_TEMP_REMOVE == "Y"))

patient_cut_data[name]
patient_cut_data$sc

patient_cut_data[i]
patient_cut_data["sc"]
