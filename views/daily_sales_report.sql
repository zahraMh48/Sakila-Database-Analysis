CREATE VIEW daily_sales_report AS 
SELECT 
	DATE(payment_date) AS date,
	SUM(amount) AS total_sales
FROM payment 
GROUP BY date
ORDER BY date DESC
