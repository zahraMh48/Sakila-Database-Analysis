CREATE VIEW  year_revenue AS 
SELECT YEAR(payment_date) AS year, SUM(amount) AS total_sales
FROM payment
GROUP BY year
ORDER BY year DESC