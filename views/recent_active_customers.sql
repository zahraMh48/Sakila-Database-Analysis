CREATE VIEW recent_active_customers AS 
SELECT 
	r.rental_id, 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name, 
    c.email, 
    r.rental_date
FROM rental r
JOIN customer c
	USING (customer_id)
WHERE r.rental_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH)