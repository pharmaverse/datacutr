###############################################################################
# Function: drop_temp_vars.R
# Author: Nathan Rees
# Purpose: To drop temporary variables from datasets within the DCUT process.
###############################################################################
# Input Arguments:
# dsin
# drop_dcut_temp
###############################################################################

### Load packages ###
library(dplyr)

### Create Function ###
drop_temp_vars <- function(dsin, drop_dcut_temp = TRUE){

  out <- dsin %>%
    select(-starts_with("TEMP_"))

  if(drop_dcut_temp){
    out <- out %>%
      select(-starts_with("DCUT_TEMP_"))
  }
  return(out)
}

### Create test data ###
test <-  data.frame(USUBJID=c(""), TEMP_XYZ=c(""), DCUT_TEMP_XYZ=c(""))

### Test Function ###
drop_temp_vars(dsin=test)                           # Drops temp_ and dcut_temp_ variables
drop_temp_vars(dsin=test, drop_dcut_temp="TRUE")    # Drops temp_ and dcut_temp_ variables
drop_temp_vars(dsin=test, drop_dcut_temp="FALSE")   # Drops temp_ variables
