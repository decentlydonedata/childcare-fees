# Codebook for raw data sets
Temporal Scope: December Quarter 2018 – December Quarter 2024

Geography: Australian Statistical Geography Standard (ASGS) SA3, SA4, and Capital City levels.

## Fees data
### Data Sources: 
Australian Department of Education - Quarterly Reports (Accessed 13/03/2026)

https://www.education.gov.au/early-childhood/about/data-and-reports/quarterly-reports

| Variable Name | Data Type | Description | Units |
| :--- | :--- | :--- | :--- |
| `SA4 Code` | String | Statistical Area 4 code defined by the ASGS | ID |
| `SA4 Name` | String | Name of Statistical Area 4 | Name |
| `State` | String | Australian State or Territory | Name |
| `SA3 Code` | String | Statistical Area 3 code (Pop. 30k–130k) | ID |
| `SA3 Name` | String | Name of Statistical Area 3 | Name |
| `service count` | Integer | Approved childcare services overseen by ACECQA | Count |
| `Mean fee per hour` | Double | Average gross fee per child per hour | AUD ($) |
| `% Growth in Mean fee` | Double | Percentage change in nominal fees from previous year's quarter | % |
| `Number of services above cap` | Integer | Services charging higher than the CCS fee cap | Count |
| `% services above the cap` | Double | Proportion of total services charging higher than the CCS fee cap | % |

### Limitations:
Temporal Gaps: Data for the June 2020 period is missing and excluded from the series.

Geospatial Shifts: ASGS boundaries changed between the 2016 and 2021 editions; longitudinal analysis at the SA3 level may experience minor loss of accuracy during the transition.

## CPI data
### Data Sources:
Australian Bureau of Statistics - Consumer Price Index (Accessed 13/03/2026)

https://www.abs.gov.au/statistics/economy/price-indexes-and-inflation/consumer-price-index-australia/sep-quarter-2025

| Variable Name | Data Type | Description | Units |
| :--- | :--- | :--- | :--- |
| `Index numbers; Childcare; [City]` | Double | Net Childcare Fees for specific capital city | Index |
| `Index numbers; Childcare; Australia` | Double | Weighted average of Net Childcare Fees for all capital cities | Index |
| `Index numbers; All groups; [City]` | Double | Weighted average of all CPI prices for specific capital city | Index |
| `Index numbers; All groups; Australia` | Double | Weighted average of prices for all capital cities | Index |

### Limitations:
Regional CPI: CPI is measured only for capital cities. Analysis for non-capital city localities (regional SA3s) requires estimation or assumption based on the nearest capital city or the national weighted average.

## Definitions
Geography (ASGS)
SA3: Designed to represent functional areas (regional cities or major hubs) with populations between 30,000 and 130,000.

SA4: Larger labor market regions.

Capital Cities: Includes Sydney, Melbourne, Brisbane, Adelaide, Perth, Hobart, Darwin, and Canberra.

Inflation & Fees
Gross vs. Net: The Department of Education data reports Gross Fees (pre-subsidy). The ABS CPI data reports Net Fees (out-of-pocket expenses after CCS/Rebate).

All Groups CPI: Represents the broader inflationary environment used to compare child care price growth against general cost-of-living increases.