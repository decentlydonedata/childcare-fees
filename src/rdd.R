library(tidyverse)
library(here)
library(fpp3)
library(lubridate)
library(plm)
library(lmtest)
library(sandwich)

setwd(here("data/clean"))

all_data <- read.csv("capital_city_data.csv")

data <- all_data %>% select(mean_fee,real_fee, sa3_code, date, city)

subsidy1 <- yearquarter("2022-03-01") # 
subsidy2 <- yearquarter("2023-06-01") # 
subsidyp <- yearquarter("2021-03-01") # Placebo

index <- c("sa3_code", "time")

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
         timesince1 = ifelse(timesince1<0,0,timesince1),
         timesince2 = time - 17,
         timesince2 = ifelse(timesince2<0,0,timesince2),
         date = yearquarter(date),
         treatment1 = case_when(date >= subsidy1 ~ 1,
                                  date < subsidy1 ~ 0),
         treatment2 = case_when(date >=subsidy2 ~ 1,
                                date < subsidy2 ~ 0),
         sa3_code = as.factor(sa3_code),
         unit_id = as.numeric(sa3_code),
         unit_time = time * unit_id)

### Visualisation purposes
data0 <- data %>% filter(date<=subsidy1)
data1 <- data %>% filter(date>=subsidy1)
data2 <- data %>% filter(date>=subsidy2)

mod0 <- lm(real_fee ~ time, data = data0)
mod1 <- lm(real_fee ~ treatment1 + time + timesince1, data = data1)
mod2 <- lm(real_fee ~ treatment2 + time + timesince2, data = data2)

newdf <- tibble(time = 1:23, 
                treatment1 = c(rep(0,12),rep(1,11)),
                treatment2 = c(rep(0,17),rep(1,6)),
                timesince1 = c(rep(0,12),1:11),
                timesince2 = c(rep(0,17),1:6))
newdf <- newdf %>% mutate(m0 = predict(mod0, newdf),
                          m1 = predict(mod1, newdf),
                          m2 = predict(mod2, newdf)) %>%
  pivot_longer(c(m0,m1,m2))

temp <- newdf %>% 
  filter(timesince2 == 0, name == "m2")
newdf <- anti_join(newdf,temp)
temp <- newdf %>%
  filter(timesince1 == 0, name == "m1")
newdf <- anti_join(newdf,temp)
temp <- newdf %>%
  filter(name == "m1", treatment2 == 1)
newdf <- anti_join(newdf, temp)

vis <- newdf %>% ggplot(
  aes(x=time, y=value, colour = name)) +
  geom_line() +
  geom_vline(xintercept = 12) +
  geom_vline(xintercept = 17)

vis

## Panel Data

pdata <- pdata.frame(data, index = c("sa3_code", "time")) %>%
  mutate(time = as.numeric(time))

pmod1 <- plm(real_fee ~ treatment1 + time + timesince1, 
             data = pdata,
             index = index,
             model = "within")
pmod2 <- plm(real_fee ~ treatment2 + time + timesince2, 
            data = pdata,
            index = index,
            model = "within") 

summary(pmod1)
summary(pmod2)
coeftest(pmod1, vcov = vcovHC(pmod1, type = "HC1", cluster = "group")) 
coeftest(pmod2, vcov = vcovHC(pmod2, type = "HC1", cluster = "group")) 

### MAIN RESULTS
# Clustered Standard  Errors
pmod3 <- plm(real_fee ~ treatment1 + treatment2 + time + timesince1 + timesince2, 
             data = pdata,
             index = index,
             model = "within")
coeftest(pmod3, vcov = vcovHC(pmod3, type = "HC1", cluster = "group")) 

### Robustness
# Without Inflation adjustment
pmod4 <- plm(mean_fee ~ treatment1 + treatment2 + time + timesince1 + timesince2, 
             data = pdata,
             index = index,
             model = "within")
coeftest(pmod4, vcov = vcovHC(pmod4, type = "HC1", cluster = "group")) 


# Driscoll–Kraay standard errors
pmod_dk <- coeftest(pmod3, vcov = vcovSCC(pmod3, type = "HC1")) 
pmod_dk

# Geographic Adjustments
pmod_geo <- plm(real_fee ~ treatment1 + treatment2 + time + timesince1 + timesince2 + unit_time, 
             data = pdata,
             index = index,
             model = "within")
summary(pmod_geo)
coeftest(pmod_geo, vcov = vcovHC(pmod_geo, type = "HC1", cluster = "group")) 

# Flexible time robustness
pmod_timeflex <- plm(real_fee ~ treatment1 + treatment2 + factor(time), 
             data = pdata,
             index = index,
             model = "within")

coefficients(pmod_timeflex)
summary(pmod_timeflex)

## Robustness 
get_coefs <- function(model, vcov_mat, label) {
  ct <- coeftest(model, vcov = vcov_mat)
  
  data.frame(
    term = rownames(ct),
    estimate = ct[, "Estimate"],
    std_error = ct[, "Std. Error"],
    model = label,
    row.names = NULL
  )
}

df_list <- list(
  get_coefs(pmod3, vcovHC(pmod3, type = "HC1", cluster = "group"), "pmod3_HC1"),
  get_coefs(pmod4, vcovHC(pmod4, type = "HC1", cluster = "group"), "pmod4_HC1"),
  get_coefs(pmod3, vcovSCC(pmod3, type = "HC1"), "pmod3_SCC"),
  get_coefs(pmod_geo, vcovHC(pmod_geo, type = "HC1", cluster = "group"), "pmod_geo"),
  get_coefs(pmod_timeflex, vcovHC(pmod_timeflex, type = "HC1", cluster = "group"), "pmod_timeflex")
)

table <- bind_rows(df_list) %>%
  filter(!str_detect(term, "factor"))

setwd(here())
write_csv(table, file = "output/robustness_table.csv")

# Subsections of data
## Time series slicing
pmod_

## Subgroup by state
cities <- c("syd", "mel", "bri", "ade", "per", "dar", "hob")

run_model <- function(city_name) {
  pdata_city <- pdata %>% filter(city == city_name)
  
  pmod <- plm(real_fee ~ treatment1 + treatment2 + time + timesince1 + timesince2, 
              data = pdata_city,
              index = index,
              model = "within")
  
  result <- coeftest(pmod, vcov = vcovHC(pmod, type = "HC1", cluster = "group"))
  
  return(result)
}

results <- lapply(cities, run_model)
names(results) <- cities

results$syd

# Functional Forms


# Placebo

fake_dates1 <- c(4, 6, 8)   # placebo for treatment1
fake_dates2 <- c(8, 10, 12) # placebo for treatment2

placebo_results <- list()

for (d1 in fake_dates1) {
  for (d2 in fake_dates2) {
    
    df_placebo <- data %>%
      mutate(
        # fake treatment indicators
        treatment1p = ifelse(time >= d1, 1, 0),
        treatment2p = ifelse(time >= d2, 1, 0),
        
        # fake post-trend (your timesince structure)
        timesince1p = pmax(time - d1, 0),
        timesince2p = pmax(time - d2, 0)
      )
    
    pdata_placebo <- pdata.frame(df_placebo, index = c("sa3_code", "time")) %>%
      mutate(time = as.numeric(time))
    
    model <- plm(
      real_fee ~ treatment1p + treatment2p + time + timesince1p + timesince2p,
      data = pdata_placebo,
      model = "within"
    )
    
    placebo_results[[paste(d1, d2, sep = "_")]] <- summary(model)
  }
}

placebo_results

summary(pmod3)





