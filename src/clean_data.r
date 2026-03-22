# Libraries necessary
library(tidyverse)
library(readxl)
library(readabs)

setwd("C:/Users/Chloe/Downloads/ECC3479/childcare-fees/data/raw/cpi")

ts_start <- ymd("2018-12-1")
ts_end <- ymd("2024-12-1")

raw_cpi <- read_abs(cat_no = "6401.0", tables = 9)

path <- "C:/Users/Chloe/Downloads/ECC3479/childcare-fees/data/raw/cpi/640107.xlsx"

id_map <- tibble(
  id = c("A2331566X", "A2331571T", "A2331576C", "A2331581W", 
         "A2331586J", "A2331591A", "A2331596L", "A2331601V", "A2331606F",
         "A2325806K","A2325811C","A2325816R","A2325821J","A2325826V", 
         "A2325831L","A2325836X", "A2325841T", "A2325846C"
         ),
  sheet = c("Data1", "Data1", "Data2", "Data3", 
            "Data3", "Data4", "Data4", "Data5", "Data6",
            "Data1", "Data2", "Data2", "Data3", 
            "Data3", "Data4", "Data5", "Data5", "Data6")
)

get_cpi_col <- function(target_id, target_sheet) {
  read_excel(path, sheet = target_sheet, skip = 9) %>%
    select(all_of(c("Series ID", target_id)))
}

all_states <- id_map %>%
  mutate(data = map2(id, sheet, ~get_cpi_col(.x, .y))) %>%
  pull(data) %>%
  reduce(left_join, by = "Series ID")

all_states <- all_states %>%
  rename(syd_cccpi = "A2331566X",
         mel_cccpi = "A2331571T", 
         bri_cccpi = "A2331576C", 
         ade_cccpi = "A2331581W", 
         per_cccpi = "A2331586J",
         dar_cccpi = "A2331591A", 
         hob_cccpi = "A2331596L", 
         can_cccpi = "A2331601V", 
         aus_cccpi = "A2331606F",
         syd_cpi = "A2325806K",
         mel_cpi = "A2325811C",
         bri_cpi = "A2325816R",
         ade_cpi = "A2325821J",
         per_cpi = "A2325826V", 
         dar_cpi = "A2325831L",
         hob_cpi = "A2325836X", 
         can_cpi = "A2325841T", 
         aus_cpi = "A2325846C",
         date = "Series ID"
         ) %>%
  mutate(date = ymd(date)) %>%
  filter(date >= ts_start & date <= ts_end) %>%
  pivot_longer(contains("cpi")) %>%
  rename(city = name) %>%
  separate(
    col = city,
    into = c("city", "stat"),
    sep = "_") %>%
  pivot_wider(names_from = stat, values_from = value)

file_names <- tibble(
              file_name = 
              c("excel_tables_-_december_quarter_2018_v2",
              "excel_tables_-_march_quarter_2019",
              "june_quarter_2019",
              "september_quarter_2019",
              "december_quarter_2019_0",
              "march_quarter_2020_0",
              "September quarter 2020",
              "December quarter 2020",
              "March quarter 2021",
              "June quarter 2021",
              "September quarter 2021",
              "December quarter 2021",
              "March quarter 2022",
              "June quarter 2022",
              "September quarter 2022 data tables",
              "Child Care Subsidy data tables – December quarter 2022",
              "Child Care Subsidy data tables - March qtr 2023",
              "Child Care Subsidy data tables - June qtr 2023",
              "Child Care Subsidy data tables - Sep qtr 2023",
              "December quarter 2023 data tables",
              "March quarter 2024 data tables",
              "Child Care Subsidy data tables - June quarter 2024",
              "Attachment C - Tables to be published on the website - Sep qtr 2024",  
              "Child Care Subsidy data tables - December quarter 2024"), 
               skip_value = 
  c(6,1,1,1,2,2,1,2,2,1,1,1,1,2,2,1,1,1,1,2,1,1,1,1)
)

get_fees <- function(target_path, skip_value) {
  read_excel(target_path, sheet = "CBDC Fees", skip = skip_value) %>%
      select(
        mean_fee = contains("per"), 
        service_count = contains("count"), 
        above_cap = contains("cap"),
        sa3 = contains("SA3"),
        sa4 = contains("SA4")
      ) %>%
      mutate(
        mean_fee = as.numeric(mean_fee),
        file_source = basename(target_path),
        year = stringr::str_extract(file_source, "\\d{4}")
      )
}

full_paths <- set_names(file_names) %>% 
  paste0("C:/Users/Chloe/Downloads/ECC3479/childcare-fees/data/raw/fees/", ., ".xlsx") 

all_fees <- file_names %>%
  mutate(full_path = paste0("C:/Users/Chloe/Downloads/ECC3479/childcare-fees/data/raw/fees/", file_name, ".xlsx")) %>%
  # pmap iterates over the columns of the tibble
  pmap_dfr(function(file_name, skip_value, full_path) {
    tryCatch({
      get_fees(full_path, skip_value)
    }, error = function(e) {
      message(paste("Error in file:", file_name, "-", e$message))
      return(NULL)
    })
  })

dec_2018 <- read_excel("C:/Users/Chloe/Downloads/ECC3479/childcare-fees/data/raw/fees/excel_tables_-_december_quarter_2018_v2.xlsx", 
           range = "CBDC fees!B7:K340") %>%
  select(
    mean_fee = as.numeric(contains("per")), 
    service_count = contains("count"), 
    above_cap = contains("cap"),
    sa3 = contains("SA3"),
    sa4 = contains("SA4")
  ) %>%
    mutate(
      file_source = "excel_tables_-_december_quarter_2018_v2",
      year = 2018) %>%
  filter(!is.na(mean_fee))
all_fees <- rbind(all_fees, dec_2018)

all_fees <- all_fees %>%
  mutate(month = case_when(
    str_detect(file_source, "june") ~ 6,
    str_detect(file_source, "June") ~ 6,
    str_detect(file_source, "Sep") ~ 9,
    str_detect(file_source, "sep") ~ 9,
    str_detect(file_source, "Dec") ~ 12,
    str_detect(file_source, "dec") ~ 12,
    str_detect(file_source, "Mar") ~ 3,
    str_detect(file_source, "mar") ~ 3),
    date = make_date(year,month,"1")) %>%
  rename(
    sa3_code = sa31,
    sa3_name = sa32,
    sa4_code = sa41,
    sa4_name = sa42,
    above_cap = above_cap1)%>%
  filter(!is.na(sa3_code),# Filters out excel source and notes
        !is.na(mean_fee)) %>%
  mutate(city = case_when(
    str_detect(sa4_name, "Sydney") ~ "syd",
    str_detect(sa4_name, "Melbourne") ~ "mel",
    str_detect(sa4_name, "Brisbane") ~ "bri",
    str_detect(sa4_name, "Adelaide") ~ "ade",
    str_detect(sa4_name, "Perth") ~ "per",
    str_detect(sa4_name, "Darwin") ~ "dar",
    str_detect(sa4_name, "Hobart") ~ "hob",
    str_detect(sa3_name, "Canberra") ~ "can",
    .default = "aus"),
    above_cap = replace(above_cap, above_cap == ".","0"),
    above_cap = replace_na(above_cap, "0")
  ) %>%
  select(-above_cap2)

all_states <- all_states %>% group_by(date)

all_data <- left_join(all_fees, all_states, by = c("date", "city"))

small <- all_fees %>% filter(is.na(mean_fee)) # Postcodes with less that 5 services and therefore without fees




summary(all_fees)
table(all_fees$file_source)
