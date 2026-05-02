library(tidyverse)
library(here)
library(fpp3)
library(lubridate)
library(plm)

setwd(here("data/clean"))

all_data <- read.csv("capital_city_data.csv")

data <- all_data %>% select(mean_fee, sa3_code, date, city)

subsidy1 <- yearquarter("2022-03-01")
subsidy2 <- yearquarter("2023-06-01")

test <- data %>% filter(sa3_code == "80106") %>% arrange(date)
pacf(test$mean_fee)
acf(test$mean_fee)

time_index <- tibble(date = c(
                    "2018-12-01",
                    "2019-03-01", 
                    "2019-06-01",
                    "2019-09-01",
                    "2019-12-01",
                    "2020-03-01",
                    "2020-12-01",
                    "2021-03-01",
                    "2021-06-01",
                    "2021-09-01",
                    "2021-12-01",
                    "2022-03-01",
                    "2022-06-01",
                    "2022-09-01",
                    "2022-12-01",
                    "2023-03-01",
                    "2023-06-01",
                    "2023-09-01",
                    "2023-12-01",
                    "2024-03-01",
                    "2024-06-01",
                    "2024-09-01",
                    "2024-12-01"),
                    time = 1:23)
data <- left_join(data, time_index, by = join_by(date))

data <- data %>% 
  arrange(date) %>% 
  group_by(sa3_code) %>%
  mutate(
         timesince1 = time - 12,
         timesince1 = ifelse(timesince1<0,1,timesince1),
         timesince2 = time - 17,
         timesince2 = ifelse(timesince2<0,0,timesince2),
         date = yearquarter(date),
         treatment1 = case_when(date >= subsidy1 ~ 1,
                                  date < subsidy1 ~ 0),
         treatment2 = case_when(date >=subsidy2 ~ 1,
                                date < subsidy2 ~ 0))


mod0 <- lm(mean_fee ~ time_index, data = data0)

summary(mod0)

mod1 <- lm(mean_fee ~ treatment1 + time_index + timesince1, data = data)
mod2 <- lm(mean_fee ~ treatment2 + time_index + timesince2, data = data)
mod3 <- lm(mean_fee ~ treatment1 + treatment2 + time_index + timesince1 + timesince2, data = data)

summary(mod1)
summary(mod2)
summary(mod3)

pdata <- pdata.frame(data, index = c("sa3_code", "time")) %>%
  mutate(time = as.numeric(time))

pmod1 <- plm(mean_fee ~ treatment1 + time + timesince1, 
             data = pdata,
             index = index,
             model = "within")
pmod2 <- plm(mean_fee ~ treatment2 + time + timesince2, 
            data = pdata,
            index = index,
            model = "within")
pmod3 <- plm(mean_fee ~ treatment1 + treatment2 + time + timesince1 + timesince2, 
             data = pdata,
             index = index,
             model = "within")

summary(pmod1)
summary(pmod2)
summary(pmod3)

pdata







