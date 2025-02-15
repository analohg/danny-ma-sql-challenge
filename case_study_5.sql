/*
1. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
1. Convert the week_date to a DATE format

2. Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

3. Add a month_number with the calendar month for each week_date value as the 3rd column

4. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

5. Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

segment	age_band
1	Young Adults
2	Middle Aged
3 or 4	Retirees

6. Add a new demographic column using the following mapping for the first letter in the segment values:
segment	demographic
C	Couples
F	Families

7. Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

8. Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
*/

-- 1
CREATE TABLE cleaned_weekly_sales AS 
SELECT *,
TO_CHAR(week_date, 'WW') AS week_number,
EXTRACT('month' FROM week_date) AS month_number,
EXTRACT('year'FROM week_date) AS calendar_year,
CASE 
	WHEN RIGHT(segment,1)='1' THEN 'Young Adults'
	WHEN RIGHT(segment,1)='2' THEN 'Middle Aged'
	WHEN RIGHT(segment,1) IN ('3','4') THEN 'Retirees'
	ELSE segment END AS age_band,
CASE 
	WHEN LEFT(segment,1)='C' THEN 'Couples'
	WHEN LEFT(segment,1)='F' THEN 'Families'
	ELSE segment END AS demographic,
ROUND(sales/transactions::NUMERIC,2) AS avg_transaction
FROM (
	SELECT CONCAT('20'||SPLIT_PART(week_date,'/',3),
			'-',SPLIT_PART(week_date,'/',2),
			'-',SPLIT_PART(week_date,'/',1)
			)::DATE AS week_date,
	region,
	platform,
	CASE WHEN segment = 'null' OR segment IS NULL THEN 'unknown'
	ELSE segment END AS segment,
	customer_type,
	transactions,
	sales
	FROM datamart_weekly_sales 
) AS clean_weekdate;

