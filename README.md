# childcare-fees
Empirical economics project understanding the impact of childcare subsidy implementation on childcare fees in Australia between 2018 and 2024

The respository is features the data necessary for analysis collected via the Department of Education and the Australian Bureau of Statistics, src which is the source code of the project in the programming language R, docs which is where the finalised report documents are housed and output which are the tables graphs etc. exported during analysis.

/data
    /clean
        clean_data.csv: Combined quarterly fee and cpi data
        codebook.md: Codebook for clean_data.csv
    /raw
        /cpi: Quarterly CPI data by Sub-group and State
        /fees: Quarterly reports on usage, services, fees and subsidies
        README.md: Information about raw data variables names, descriptions and sources
/docs
/output
/src
    clean_data.r: R source code to clean data
    eda.r: R source code for intial exploratory data analysis including indexing, outliers and scope discussion

R Libraries necessary:
- tidyverse
- read_xl
- read_abs

Steps for repoduction:
1. Download the quarterly reports on usage, services, fees and subsidies from the Department of Education
https://www.education.gov.au/early-childhood/about/data-and-reports/quarterly-reports
2. Download Table 9 of the ABS Consumer Price index 6401.0 or use the read_abs package R Studio
https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/consumer-price-index-australia/sep-quarter-2025
3. Run src/clean_data.r 
    Loads CPI and Child Care CPI between time series start date (2018-12-1) and end date (2024-12-1) for every capital city and Australia.
    Seperates the city from the CPI type into two columns via pivot longer and pivot wider.
    Loads Fee data from every quarterly report (except December 2018) into one dataframe, taking care to skip different columns in each as the format changes between years. Each loading of a file has its year extracted into a year column.
    Adds December 2018 seperately to the dataframe with specific range of cells since the formatting differs so much.
    Adds month variable by string detection, and therefore creates a date variable in lubridate format.
    Removes NA values of Statistical Area 3 as they are relics of source notes and footers from the Excel spreadsheets. 
    Using string detect on Statistical Area 4 a capital city is assigned to metropolitan fee observations and Australia is set for all others. 
    The Fee dataframe is then combined with CPI and Child Care CPI dataframe and exported as data/clean/clean_data.csv
4. Run src/eda.r

