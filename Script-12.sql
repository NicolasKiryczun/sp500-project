CREATE VIEW sp_by_year AS (
SELECT 
	YEAR(start_date) AS `year`,
	perc_change
FROM (
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
SELECT 
	min_date AS start_date, 
	min_price AS start_price,
	max_date AS end_date, 
	max_price AS end_price, 
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
