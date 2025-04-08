CREATE VIEW popular_genres AS 
SELECT 
	c.name AS genre, 
    COUNT(film_id) AS rental_count
FROM rental r
JOIN inventory i
	USING (inventory_id)
JOIN film_category f
	USING (film_id)
JOIN category c
	USING (category_id)
GROUP BY c.name
ORDER BY rental_count DESC

