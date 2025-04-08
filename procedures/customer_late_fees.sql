DROP PROCEDURE IF EXISTS customer_late_fees;

DELIMITER $$

CREATE PROCEDURE customer_late_fees(
	customer_id INT
)
BEGIN
	SELECT 
		r.rental_id, 
		i.film_id, 
		f.title,
		r.rental_date, 
		r.return_date, 
		f.rental_duration, 
		DATEDIFF(r.return_date, r.rental_date) - f.rental_duration AS late,
		f.replacement_cost
	FROM rental r 
	JOIN inventory i 
		USING (inventory_id)
	JOIN film f 
		USING (film_id)
	WHERE DATEDIFF(r.return_date, r.rental_date) > f.rental_duration 
			AND r.customer_id = customer_id;
END$$

DELIMITER ;