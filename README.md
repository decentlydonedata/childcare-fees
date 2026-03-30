# Impact of Childcare Subsidy Implementation on Fees (2018–2024)

## Project Overview
This empirical economics project investigates the relationship between childcare subsidy policy changes and gross childcare fees in Australia. The analysis spans from **December 2018 to December 2024**, utilizing regional data to track fee elasticity and inflationary trends.

## Repository Structure
* **data/**
    * **clean/**
        * `clean_data.csv`: Combined quarterly fee and CPI data.
        * `codebook.md`: Detailed metadata and variable definitions.
    * **raw/**
        * **cpi/**: Quarterly ABS Consumer Price Index data by sub-group.
        * **fees/**: Department of Education quarterly reports on usage and fees.
* **docs/**: Finalized report documents and academic papers.
* **output/**: Exported analysis artifacts (tables, graphs, and regression outputs).
* **src/**: R source code.
    * `clean_data.r`: Script for data ingestion, cleaning, and merging.
    * `eda.r`: Script for exploratory data analysis, indexing, and outlier detection.
* `README.md`: Project documentation and reproduction steps.

---

## Getting Started

### Prerequisites
The following R libraries are required to run the scripts in `src/`:
```r
library(tidyverse)
library(readxl)
library(readabs)
library(lubridate)

---
### Data Acquisition

1.  **Childcare Reports:** Download the quarterly "Usage, Services, Fees, and Subsidies" reports from the [Department of Education](https://www.education.gov.au/early-childhood/about/data-and-reports/quarterly-reports). Save these files into the `data/raw/fees/` directory.
    * *Note:* The analysis covers the period from December Quarter 2018 to December Quarter 2024.
2.  **CPI Data:** Access the [ABS Consumer Price Index (6401.0)](https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/consumer-price-index-australia/) and download **Table 9**. Alternatively, use the `read_abs` package in R to pull the "Index Numbers; Childcare" and "Index Numbers; All groups" series for all capital cities. Save or point these to the `data/raw/cpi/` directory.

---

## Steps for Reproduction

### 1. Data Cleaning (`src/clean_data.r`)
Run this script to generate the analytical dataset. The pipeline includes:

* **CPI Processing:** Loads National and Capital City CPI (All Groups and Child Care) for the 2018–2024 time series. It reshapes the data using `pivot_longer` and `pivot_wider` to separate city and index type into distinct columns.
* **Fee Ingestion:** Iterates through every quarterly report, extracting the `year` from the filename. 
    * *Note:* The December 2018 report is processed separately with a specific cell range due to significant formatting differences compared to later years.
* **Wrangling & Feature Engineering:**
    * **Temporal:** Detects months/quarters via string patterns to create a standardized `lubridate` date variable.
    * **Filtering:** Removes `NA` values in Statistical Area 3 (SA3) columns, which are typically relics of source notes and footers in the Excel sheets.
    * **Spatial Mapping:** Uses string detection on `SA4` to assign a capital city to metropolitan observations, while "Australia" is set for all others to align with CPI availability.
* **Merge & Export:** Combines the Fee and CPI dataframes and exports the final file to `data/clean/clean_data.csv`.

### 2. Exploratory Analysis (`src/eda.r`)
Run this script to perform initial data validation and visualization:
* Generates initial indexing of fee growth against inflation.
* Conducts outlier detection and discusses the project scope.
* Exports tables and graphs to the `output/` folder.

---

## Limitations
* **Temporal Gaps:** Data for the **June 2020** period is missing from source reports and is excluded from the time series.
* **Geospatial Accuracy:** Changes in ABS Statistical Geography Standard (ASGS) editions between 2016 and 2021 may result in a minor loss of accuracy for longitudinal analysis at the SA3 level.
* **CPI Attribution:** Since CPI is measured via a weighted average of capital cities, inflation for non-capital city (regional) localities is estimated based on the