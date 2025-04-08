CREATE VIEW  monthly_revenue AS 
SELECT 
	DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(amount) AS total_sales
FROM payment
GROUP BY month
ORDER BY month DESC

