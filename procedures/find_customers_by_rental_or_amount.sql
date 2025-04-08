 DROP PROCEDURE IF EXISTS find_customers_by_rental_or_amount;
 
 DELIMITER $$
 
 CREATE PROCEDURE find_customers_by_rental_or_amount(
	min_rental_count INT,
    min_total_amount DECIMAL(6,2)
 )
 BEGIN
	 SELECT 
		r.customer_id, 
		CONCAT(c.first_name, ' ', c.last_name) AS full_name,
		c.email,
		COUNT(r.customer_id) AS rental_count,
		customer_total_amount(r.customer_id) AS total_amount
	FROM rental r 
	JOIN customer c 
		USING (customer_id)
	GROUP BY customer_id
	HAVING rental_count >= min_rental_count OR total_amount >= min_total_amount;
END$$

DELIMITER ;