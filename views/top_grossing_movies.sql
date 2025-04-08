CREATE VIEW top_grossing_movies AS
SELECT 
	i.film_id, 
	f.title, 
    f.description,
    f.length,
    f.rating,
    f.rental_rate,
	SUM(p.amount) AS total_sale
FROM rental r 
JOIN payment p 
	USING (rental_id)
JOIN inventory i 
	USING (inventory_id)
JOIN film f 
	USING (film_id)
GROUP BY film_id
ORDER BY total_sale DESC