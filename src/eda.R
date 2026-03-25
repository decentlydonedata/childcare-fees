library(tidyverse)
library(patchwork)

setwd("C:/Users/Chloe/Downloads/ECC3479/childcare-fees/data/clean")

all_data <- read_csv("clean_data.csv")

prices <- c("mean_fee", "cccpi", "cpi")

ggplot(all_data, aes(x = cccpi, y = mean_fee, colour = city)) + geom_point()
ggplot(all_data, aes(x = cpi, y = mean_fee, colour = city)) + geom_point()
# From analysis the variation of aus mean fees is much higher across cccpi and cpi, this is due to the limitation of the data as all non-capital city sa3
# are categorised via aus cpi and cccpi regardless of closest distance from a capital city, population, state etc. 
# Future analysis can be done to estimate or add the above variables however for this project the capital cities will only be analysed

ggplot(all_data, aes(y = cccpi, colour = city)) + geom_boxplot()
# There is a outlier of cccpi in melbourne of under 100 and a similar aus outlier under 120

ggplot(all_data, aes(y = mean_fee, colour = city)) + geom_boxplot()
# Further confirms the large variation in Australia  for mean fees

ggplot(all_data, aes(y = cpi, colour = city)) + geom_boxplot()
# Seems relatively well distributed without outliers

ggplot(all_data, aes(y = service_count, colour = city)) + geom_boxplot()
# There are low end outliers in Canberra, and many high end outliers in Australia which will not be part of the larger analysis
# For Adelaide, Melbourne and Perth the high observations of service counts are highly dense sa3s

ggplot(all_data, aes(y = above_cap, colour = city)) + geom_boxplot()

all_data %>% filter(city == "mel", cccpi < 80) %>% head()
# The outlier is September quarter of 2020 which was the height of the stage 4 restrictions where childcare was not a permitted acitivty
# Hence these Melbourne observations should be removed as no childcare was undertaken

all_data %>% filter(city == "aus", cccpi < 120 & cccpi > 80) %>% head()
# Similarly the Sepetember quarter of 2020 for the Australian wide cccpi is unusually low due to it being a weighted average of the capital cities
# Since Melbourne brought down the weighted average for this quarter

all_data %>% filter(city == "can", service_count < 12) %>% head()
# These observations can be accounted for as the Canberra East area which is largely nature reserves and has a small population.

ggplot(all_data, aes(x = date, y = mean_fee, colour = city)) + geom_point()
# There is no available data for June 2020 likely due to nation wide lock downs
# Promising increase in childcare fees
ggplot(all_data, aes(x = date, y = cccpi, colour = city)) + geom_point()
# The September cccpi for all observations seemed to be much lower due to residual Covid effects 
# For the purpose of regression analysis the whole time period will be excluded
# Can see the policy changes to siblings in June 2022 and the Cheaper Childcare Bill in late 2023


#### Adjustments and changes
trimmed_data <- all_data %>% filter(date != "2020-9-1") # Without Covid observations

target_dates <- ymd(c("2018-12-01", "2019-03-01"))

base_fees <- trimmed_data %>% filter(date == "2018-12-01") %>% select(sa3_code, mean_fee) %>%
  rename(base_fee = mean_fee)
trimmed_data <- left_join(trimmed_data, base_fees, by = "sa3_code")
trimmed_data <- trimmed_data %>%
  mutate(index_fee = mean_fee/base_fee*100)
base_cccpi <- trimmed_data %>% filter(date == "2018-12-01") %>% select(sa3_code, cccpi) %>%
  rename(base_cccpi = cccpi)
trimmed_data <- left_join(trimmed_data, base_cccpi, by = "sa3_code")
trimmed_data <- trimmed_data %>%
  mutate(index_cccpi = 100/base_cccpi*cccpi)
base_cpi <- trimmed_data %>% filter(date == "2018-12-01") %>% select(sa3_code, cpi) %>%
  rename(base_cpi = cpi)
trimmed_data <- left_join(trimmed_data, base_cpi, by = "sa3_code")
trimmed_data <- trimmed_data %>%
  mutate(index_cpi = 100/base_cpi*cpi)
base_fees <- trimmed_data %>% filter(date == "2018-12-01") %>% select(sa3_code, mean_fee) %>%
  rename(base_fee = mean_fee)
trimmed_data <- left_join(trimmed_data, base_fees, by = "sa3_code")
trimmed_data <- trimmed_data %>%
  mutate(index_fee = mean_fee/base_fee*100)
base_cccpi <- trimmed_data %>% filter(date == "2018-12-01") %>% select(sa3_code, cccpi) %>%
  rename(base_cccpi = cccpi)
trimmed_data <- left_join(trimmed_data, base_cccpi, by = "sa3_code")
trimmed_data <- trimmed_data %>%
  mutate(index_cccpi = 100/base_cccpi*cccpi)
base_prescpi <- trimmed_data %>% filter(date == "2024-12-01") %>% select(sa3_code, cpi) %>%
  rename(base_prescpi = cpi)
trimmed_data <- left_join(trimmed_data, base_prescpi, by = "sa3_code")
trimmed_data <- trimmed_data %>%
  mutate(index_prescpi = 100/base_prescpi*cpi)

trimmed_data %>% filter(is.na(index_fee)) %>% arrange(date) %>% head()
# SA3 that exceeded 5 services after 2018 and therefore have mean fee without a base 2018 fee.
# These areas are low population regional areas and will be excluded
trimmed_data <- trimmed_data %>% filter(!is.na(index_fee))

cap_data <- trimmed_data %>% filter(city != "aus")

ggplot(cap_data, aes(x = date, y = index_fee, colour = city)) + geom_point()
cap_data %>% filter(city == "mel", sa3_code == "20901") %>% select(mean_fee, index_fee, base_fee, date) %>% arrange(date)
# Banyule specifically had a high mean fee of 12.20 in 2018 which is not indicative of growth in fees in every subsequent year, as well as neighboring areas
# Elected to change the base year to the 2019-03-01

banyule_base <- trimmed_data %>% filter(date == "2019-03-01", sa3_code == "20901") %>% select(mean_fee)
base_fees <- base_fees %>% mutate(base_fee = case_when(sa3_code == "20901" ~ banyule_base$mean_fee, 
                                                       .default = base_fee))
trimmed_data <- trimmed_data %>% select(-base_fee)
trimmed_data <- left_join(trimmed_data, base_fees, by = "sa3_code")
trimmed_data <- trimmed_data %>%
  mutate(index_fee = mean_fee/base_fee*100)
cap_data <- trimmed_data %>% filter(city != "aus")

cap_data %>% filter(city == "dar", sa3_code == "70103") %>% select(mean_fee, index_fee, base_fee, date) %>% arrange(date)
# Having looked at the variability of fees which are lower relative to other areas and the map of the area
# Litchfield is significantly more regional than the other Darwin areas and will be excluded from capital city analysis
cap_data <- cap_data %>% filter(sa3_code != "70103")
cap_data <- cap_data %>%
  mutate(adj_fee = mean_fee*index_prescpi/100,
         prop_above = above_cap/service_count,
         aprox_sub = index_fee - index_cccpi)

ggplot(cap_data, aes(x = date, y = index_cccpi, colour = city)) + 
  geom_point() + # Childcare CPI indexed to 2018
  geom_vline(xintercept = ymd("2023-07-01"), linetype = "dashed") +
  geom_vline(xintercept = ymd("2022-02-01"), linetype = "dashed")
# The changes to out of pocket childcare costs have been punctuated by policy changes
# The addition of a sibling discount in 2022 and the Cheaper childcare bill in 2023
# It should be noted that the rate of child care cost growth after these policy changes are visibly higher (steeper slope)
# particularly in Canberra, Perth and Brisbane.

ggplot(cap_data, aes(x = date, y = index_cpi, colour = city)) + geom_point() + # CPI indexed to 2018
  geom_vline(xintercept = ymd("2023-07-01"), linetype = "dashed") +
  geom_vline(xintercept = ymd("2022-02-01"), linetype = "dashed")
# The CPI has increased across capital cities relatively uniformly over time with very high inflation in the post-COVID period by has since slowed

ggplot(cap_data, aes(x = date, y = index_fee, colour = city)) + geom_point() + # Fees indexed to 2018 fee price in SA4
  geom_vline(xintercept = ymd("2023-07-01"), linetype = "dashed") +
  geom_vline(xintercept = ymd("2022-02-01"), linetype = "dashed")
# Fees have grown heterogeneously across cities, with Brisbane, Perth fees growing at more than other cities

ggplot(cap_data, aes(x = date, y = adj_fee, colour = city)) + geom_point() + # Fees in 2024 $
  geom_vline(xintercept = ymd("2023-07-01"), linetype = "dashed") +
  geom_vline(xintercept = ymd("2022-02-01"), linetype = "dashed")
# After adjusting the nominal fees for inflation the hourly cost of childcare has increased by at least $6 per hour in real terms

ggplot(cap_data, aes(x = date, y = mean_fee, colour = city)) + geom_point() + # Nominal Fees
  geom_vline(xintercept = ymd("2023-07-01"), linetype = "dashed") +
  geom_vline(xintercept = ymd("2022-02-01"), linetype = "dashed")
# After the policy changes not only is there a spike in nominal fees, but also the rate of growth in nominal fees is higher than in prior periods

ggplot(cap_data, aes(x = date, y = aprox_sub, colour = city)) + geom_point() + # Approximate subsidy
  geom_vline(xintercept = ymd("2023-07-01"), linetype = "dashed") +
  geom_vline(xintercept = ymd("2022-04-01"), linetype = "dashed")

