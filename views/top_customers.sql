CREATE VIEW top_customers AS
SELECT 
	r.customer_id AS ID, 
    c.name AS full_name,
    c.phone,
	COUNT(customer_id) AS rental_count
FROM rental r
JOIN customer_list c
	ON c.ID = r.customer_id
GROUP BY customer_id
ORDER BY rental_count DESC