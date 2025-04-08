DROP FUNCTION IF EXISTS customer_total_amount;

DELIMITER $$

CREATE FUNCTION customer_total_amount(
	customer_id INT
)
RETURNS DECIMAL(6,2) 
READS SQL DATA
BEGIN
	DECLARE total_amount DECIMAL(6,2) DEFAULT 0;
	SELECT SUM(p.amount)
    INTO total_amount
	FROM payment p 
	LEFT JOIN rental r 
		USING (rental_id)
	WHERE p.customer_id = customer_id;
    RETURN total_amount;
END$$

DELIMITER ;