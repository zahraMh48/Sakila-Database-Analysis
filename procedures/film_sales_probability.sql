DROP PROCEDURE IF EXISTS film_sales_probability;

DELIMITER $$

CREATE PROCEDURE film_sales_probability(
	film_id INT
)
BEGIN 
	WITH film_month_sale AS (
	SELECT 
		DATE_FORMAT(r.rental_date, '%Y-%m') AS month, 
		COUNT(*) AS sale_count
	FROM rental r 
	JOIN inventory i 
		USING (inventory_id)
	WHERE r.rental_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH) AND i.film_id = film_id
	GROUP BY month 
	),
	summary AS (
		SELECT 
			ROUND(AVG(sale_count),0) AS count_avg,
			(SELECT sale_count 
				FROM film_month_sale 
				ORDER BY month DESC
				LIMIT 1) AS last_month_count
		FROM film_month_sale 
	)
	SELECT 
		*,
		CASE
			WHEN count_avg > 10 THEN 'High'
			WHEN count_avg BETWEEN 5 AND 10 THEN 'Medium'
			WHEN count_avg < 5 THEN 'Low'
			ELSE 'Very Low'
		END AS probability
	FROM summary;
END$$

DELIMITER ;
