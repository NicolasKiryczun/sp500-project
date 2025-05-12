/*

Transformation of the Microsoft Excel CSV file "sp500" 

This dataset can be found as a file in the repository

*/



-- We start with creating a VIEW statement to store relevant columns from our subquery
CREATE VIEW sp_by_year AS (
SELECT 
	YEAR(start_date) AS `year`,
	perc_change
FROM (
-- We create two new tables with a CTE 
-- "max_table" isolates the information of the final trading day of each year
WITH max_table AS (
		SELECT 
		price_date AS max_date, 
		price_close AS max_price
	FROM 
		Stocks3
	WHERE 
		price_date IN (
	SELECT 
		MAX(price_date)
	FROM 
		stocks3
	GROUP BY
		YEAR(price_date)
		)),
-- "min_table" isolates the information of the first trading day of each year
min_table AS (
	SELECT 
		price_date AS min_date, 
		price_close AS min_price
	FROM 
		Stocks3
	WHERE 
		price_date IN (
	SELECT 
		MIN(price_date)
	FROM 
		stocks3
	GROUP BY
		YEAR(price_date)
		))
-- We then select all information from both tables
SELECT 
	min_date AS start_date, 
	min_price AS start_price,
	max_date AS end_date, 
	max_price AS end_price, 
-- We also find the stock price change in percentage for each year
	ROUND((max_price - min_price)/min_price, 4) AS perc_change
FROM
	max_table
LEFT JOIN 
	min_table ON
		YEAR(max_date) = YEAR(min_date)
) AS price_change
WHERE
	YEAR(start_date) NOT IN (1927, 2025)
)
;



----------------------------------------------------------------------------------------------------



-- This second VIEW statement references the first VIEW 
-- Builds on it by categorizing years as having positive or negative returns
CREATE VIEW yearly_returns AS
SELECT
	year,
	perc_change,
	CASE
		WHEN perc_change > 0 THEN 'positive'
		WHEN perc_change < 0 THEN 'negative'
		ELSE 'neutral'
	END AS change_type 
FROM
	sp_by_year
;
