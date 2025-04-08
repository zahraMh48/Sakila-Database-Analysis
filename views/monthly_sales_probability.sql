CREATE VIEW monthly_sales_probability AS (
WITH film_month_sale AS (
SELECT 
	i.film_id,
	DATE_FORMAT(r.rental_date, '%Y-%m') AS month, 
	COUNT(*) AS sale_count
FROM rental r 
JOIN inventory i 
	USING (inventory_id)
WHERE r.rental_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY i.film_id, month 
),
summary AS (
	SELECT 
		fl.FID,
        fl.title,
        fl.description,
        fl.category,
        fl.price,
        fl.length,
        fl.rating,
		ROUND(AVG(sale_count),0) AS count_avg,
		(SELECT sale_count 
			FROM film_month_sale 
			ORDER BY month DESC
			LIMIT 1) AS last_month_count
	FROM film_month_sale fms
    JOIN film_list fl
		ON fms.film_id = fl.FID
	GROUP BY fl.FID, fl.title, fl.description, fl.category, fl.price, fl.length, fl.rating
)
SELECT 
	*,
	CASE
		WHEN count_avg > 10 THEN 'High'
		WHEN count_avg BETWEEN 5 AND 10 THEN 'Medium'
		WHEN count_avg < 5 THEN 'Low'
		ELSE 'Very Low'
	END AS probability
FROM summary
)