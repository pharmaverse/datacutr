# Exporting into gSheet ###############################################################################################
install.packages("googlesheets4")
library(googlesheets4)
#creating gSheet
# ss2 <- gs4_create("Datacutr TEST", sheets = ls(cut_data))
# ss2 = gs4_get("https://docs.google.com/spreadsheets/d/1ICkxExmwFeGgw0onDKwHKhgbYHmEDadKAXS4RW0LoyE/edit#gid=554606597")

## export into existing gSheet ----
cut_data$dcut %>%
  write_sheet(ss2,sheet = "dcut")
cut_data$dm %>%
  write_sheet(ss2,sheet = "dm")
cut_data$sc %>%
  write_sheet(ss2,sheet = "sc")
cut_data$ds %>%
  write_sheet(ss2,sheet = "ds")
cut_data$ae%>%
  write_sheet(ss2,sheet = "ae")
cut_data$lb %>%
  write_sheet(ss2,sheet = "lb")
cut_data$fa %>%
  write_sheet(ss2,sheet = "fa")
cut_data$ts %>%
  write_sheet(ss2,sheet = "ts")

#export into existing gSheet
cut_data$dcut %>%
  write_sheet(ss = gs4_get("https://docs.google.com/spreadsheets/d/14V9u2Rwiq4tGdZoChEx_dAc91KUIEPGn-VWDkkYfzmQ/edit#gid=0"),
              sheet = "dcut")
cut_data$dm %>%
  write_sheet(ss = gs4_get("https://docs.google.com/spreadsheets/d/14V9u2Rwiq4tGdZoChEx_dAc91KUIEPGn-VWDkkYfzmQ/edit#gid=0"),
              sheet = "dm")
cut_data$sc %>%
  write_sheet(ss = gs4_get("https://docs.google.com/spreadsheets/d/14V9u2Rwiq4tGdZoChEx_dAc91KUIEPGn-VWDkkYfzmQ/edit#gid=0"),
              sheet = "sc")
cut_data$ae%>%
  write_sheet(ss = gs4_get("https://docs.google.com/spreadsheets/d/14V9u2Rwiq4tGdZoChEx_dAc91KUIEPGn-VWDkkYfzmQ/edit#gid=0"),
              sheet = "ae")
cut_data$lb %>%
  write_sheet(ss = gs4_get("https://docs.google.com/spreadsheets/d/14V9u2Rwiq4tGdZoChEx_dAc91KUIEPGn-VWDkkYfzmQ/edit#gid=0"),
              sheet = "lb")
cut_data$fa %>%
  write_sheet(ss = gs4_get("https://docs.google.com/spreadsheets/d/14V9u2Rwiq4tGdZoChEx_dAc91KUIEPGn-VWDkkYfzmQ/edit#gid=0"),
              sheet = "fa")
cut_data$ts %>%
  write_sheet(ss = gs4_get("https://docs.google.com/spreadsheets/d/14V9u2Rwiq4tGdZoChEx_dAc91KUIEPGn-VWDkkYfzmQ/edit#gid=0"),
              sheet = "ts")

## FUNCTION creation ----
gSheet_cut_data <- function(cut_data){
  result <- gs4_create("Datacutr RESULT", sheets = ls(cut_data))
  cut_data$dcut %>%
    write_sheet(result,sheet = "dcut")
  cut_data$dm %>%
    write_sheet(result,sheet = "dm")
  cut_data$sc %>%
    write_sheet(result,sheet = "sc")
  cut_data$ds %>%
    write_sheet(result,sheet = "ds")
  cut_data$ae%>%
    write_sheet(result,sheet = "ae")
  cut_data$lb %>%
    write_sheet(result,sheet = "lb")
  cut_data$fa %>%
    write_sheet(result,sheet = "fa")
  cut_data$ts %>%
    write_sheet(result,sheet = "ts")
}

## Attempt 2 - FUNCTION creation ----
gSheet_cut_data <- function(cut_data){
  result <- gs4_create("Datacutr RESULT", sheets = ls(cut_data))
  cyc_num <- 1
  for (df in cut_data){
    df %>% write_sheet(result, sheet = ls(cut_data)[cyc_num])
    cyc_num <- cyc_num + 1
  }
}

gSheet_cut_data(cut_data = patient_cut_data)
