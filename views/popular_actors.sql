CREATE VIEW popular_actors AS 
WITH top10_film_by_rental_count AS (
SELECT i.film_id, COUNT(i.film_id) AS rental_count
FROM rental r 
JOIN inventory i 
	USING (inventory_id)
GROUP BY film_id
ORDER BY rental_count DESC
LIMIT 10
)
SELECT a.actor_id, a.first_name, a.last_name
FROM film_actor fa 
JOIN actor a 
	USING (actor_id)
WHERE fa.film_id IN (SELECT film_id FROM top10_film_by_rental_count)