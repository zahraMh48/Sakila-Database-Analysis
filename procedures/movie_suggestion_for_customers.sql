DROP PROCEDURE IF EXISTS movie_suggestion_for_customers;

DELIMITER $$

CREATE PROCEDURE movie_suggestion_for_customers(
	customer_id INT 
)
BEGIN
	
--     DECLARE genre VARCHAR(25);
	WITH most_visited_category AS (
		SELECT 
			fl.category, 
			COUNT(fl.FID) AS film_count
		FROM film_list fl 
		WHERE fl.FID IN (
			SELECT DISTINCT i.film_id
			FROM rental r 
			JOIN inventory i 
				USING (inventory_id)
			WHERE r.customer_id = customer_id
		)
		GROUP BY fl.category
		ORDER BY film_count DESC
		LIMIT 1
	)
    SELECT 
		tgm.film_id,
		tgm.title,
		tgm.description,
		tgm.length,
		tgm.rating,
		tgm.rental_rate,
		c.name AS genres,
		tgm.total_sale
	FROM top_grossing_movies tgm
	JOIN film_category fc
		USING (film_id)
	JOIN category c 
		USING (category_id)
	WHERE c.name = (SELECT category FROM most_visited_category) AND 
			tgm.film_id NOT IN (
				SELECT DISTINCT i.film_id
				FROM rental r 
				JOIN inventory i 
					USING (inventory_id)
				WHERE r.customer_id = customer_id
			)
	ORDER BY total_sale DESC
	LIMIT 5;
	
END$$

DELIMITER ;