CREATE VIEW debt_customer_list AS
WITH debt_customer_id AS (
	SELECT DISTINCT r.customer_id AS debt_id
	FROM rental r 
	JOIN inventory i 
		USING (inventory_id)
	JOIN film f 
		USING (film_id)
	WHERE DATEDIFF(r.return_date, r.rental_date) > f.rental_duration
)
SELECT 
	c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name, 
    c.email
FROM customer c
WHERE EXISTS (
	SELECT * 
    FROM debt_customer_id
    WHERE c.customer_id = debt_customer_id.debt_id
)

		
