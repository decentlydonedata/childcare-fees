# Codebook for clean_data.csv

| Variable Name | Data Type | Description | Units | Min | Max |
| :--- | :--- | :--- | :--- | :---: | :---: |
| `mean_fee` | Numeric | Mean fee charged per hour of child care | AUD ($) | 4.03 | 17.82 |
| `service_count` | Integer | Total number of child care services in the region | Count | 5 | 120 |
| `above_cap` | Integer | Number of services charging above the hourly fee cap | Count | 0 | 86 |
| `sa3_code` | Integer | ABS Statistical Area Level 3 (Region ID) | ID | 10101 | 90104 |
| `sa3_name` | String | Name of the Statistical Area Level 3 | Name | N/A | N/A |
| `sa4_code` | Integer | ABS Statistical Area Level 4 (Larger Region ID) | ID | 101 | 901 |
| `sa4_name` | String | Name of the Statistical Area Level 4 | Name | N/A | N/A |
| `file_source` | String | The source Excel filename for the data point | Text | N/A | N/A |
| `year` | Integer | Calendar year of the observation | YYYY | 2018 | 2024 |
| `month` | String/Int | Month of the observation or quarter-end | MM / Name | 1 | 12 |
| `date` | Date | Standardized date for the observation | YYYY-MM-DD | 2018-01-01 | 2024-12-31 |
| `city` | String | Australian capital city (e.g., Melbourne, Sydney) | Name | N/A | N/A |
| `cccpi` | Numeric | Child Care Consumer Price Index | Index | 49.7 | 183.7 |
| `cpi` | Numeric | Consumer Price Index (All Groups) | Index | 110.1 | 140.6 |

# Codebook for capital_city_data.csv


