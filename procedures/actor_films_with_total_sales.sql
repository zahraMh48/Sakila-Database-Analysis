DROP PROCEDURE IF EXISTS actor_films_with_total_sales;

DELIMITER $$

CREATE PROCEDURE actor_films_with_total_sales(
	actor_id INT
)
BEGIN
	SELECT 
		f.film_id, 
		f.title, 
		c.name AS genres,
		f.length, 
		f.rating,
		f.release_year,
		film_total_amount(f.film_id) AS total_sales
	FROM film f 
	JOIN film_category fc 
		USING (film_id)
	JOIN category c 
		USING (category_id)
	JOIN film_actor fa 
		USING (film_id)
	WHERE fa.actor_id = actor_id
	ORDER BY total_sales DESC;
END$$

DELIMITER ;