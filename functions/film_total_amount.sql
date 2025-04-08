DROP FUNCTION IF EXISTS film_total_amount;

DELIMITER $$

CREATE FUNCTION film_total_amount(
	film_id INT
)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
	DECLARE film_total_amount DECIMAL(6,2);
	SELECT SUM(p.amount)
    INTO film_total_amount
	FROM payment p 
	LEFT JOIN rental r 
		USING (rental_id)
	JOIN inventory i 
		USING (inventory_id)
	WHERE i.film_id = film_id;
    RETURN film_total_amount;
END$$

DELIMITER ;