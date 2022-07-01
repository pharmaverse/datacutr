#' Patient Cut
#'
#' Apply a patient cut and add a datacut date variable to an SDTMv dataset
#'
#' @param dataset_sdtm Input SDTMv dataset
#' @param dataset_cut Input datacut dataset, default is `dcut`
#' @param cut_var Datacut date variable found in the `dataset_cut` dataset, default is `TEMP_DCUTDT`
#' @param cut_type Set to either "cut" or "drop", "cut" will keep all the patients that are in the datacut dataset 
#' "drop" will keep all the patients that are dropped by applying the patient cut
#'
#' @author Alana Harris
#'
#' @return A dataset containing either the records kept or removed after applying the datacut
#' 
#' @export
#'
#' @keywords assertion
#'
#' @examples
#' 
#' 

pt_cut <- function(dataset_sdtm,
                   dataset_cut = dcut ,
                   cut_var = DCUTDT,
                   cut_type = "cut") {
  
  cut_var <- assert_symbol(enquo(cut_var))
  assert_data_frame(dataset_sdtm,
                    required_vars = vars(USUBJID))
  assert_data_frame(dataset_cut,
                    required_vars = admiral:::quo_c(vars(USUBJID), cut_var))
  assert_character_scalar(cut_type,
                          values = c("cut", "drop"),
                          case_sensitive = FALSE)
  
  dcut <- dataset_cut %>%
    mutate(TEMP_DCUTDT = DCUTDT) %>%
    subset(select = c(USUBJID, TEMP_DCUTDT))
  
  if (cut_type == "cut") {
    dataset <- dataset_sdtm %>%
      inner_join(x = dcut,
                 y = .,
                 by = "USUBJID",
                 all.x = TRUE)
  }
  
  if (cut_type == "drop") {
    dataset <- dataset_sdtm %>%
      anti_join(x = .,
                y = dcut,
                by = "USUBJID")
  }
  
  dataset
}