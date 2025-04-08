DROP FUNCTION IF EXISTS avg_rental_duration;

DELIMITER $$

CREATE FUNCTION avg_rental_duration(
	film_id INT
)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE avg_duration INT;
	SELECT AVG(DATEDIFF(r.return_date, r.rental_date))
    INTO avg_duration
	FROM rental r
	JOIN inventory i 
		USING (inventory_id)
	WHERE i.film_id = film_id;
    RETURN avg_duration;
END$$

DELIMITER ;