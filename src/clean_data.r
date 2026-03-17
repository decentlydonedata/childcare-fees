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
  filter(date >= ts_start & date <= ts_end)






