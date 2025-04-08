CREATE VIEW daily_sales_report AS 
SELECT 
	DATE(payment_date) AS date,
	SUM(amount) AS total_sales
FROM payment 
GROUP BY date
ORDER BY date DESC;

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
);

CREATE VIEW  monthly_revenue AS 
SELECT 
	DATE_FORMAT(payment_date, '%Y-%m') AS month,
    SUM(amount) AS total_sales
FROM payment
GROUP BY month
ORDER BY month DESC;

CREATE VIEW monthly_sales_probability AS (
WITH film_month_sale AS (
SELECT 
	i.film_id,
	DATE_FORMAT(r.rental_date, '%Y-%m') AS month, 
	COUNT(*) AS sale_count
FROM rental r 
JOIN inventory i 
	USING (inventory_id)
WHERE r.rental_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY i.film_id, month 
),
summary AS (
	SELECT 
		fl.FID,
        fl.title,
        fl.description,
        fl.category,
        fl.price,
        fl.length,
        fl.rating,
		ROUND(AVG(sale_count),0) AS count_avg,
		(SELECT sale_count 
			FROM film_month_sale 
			ORDER BY month DESC
			LIMIT 1) AS last_month_count
	FROM film_month_sale fms
    JOIN film_list fl
		ON fms.film_id = fl.FID
	GROUP BY fl.FID, fl.title, fl.description, fl.category, fl.price, fl.length, fl.rating
)
SELECT 
	*,
	CASE
		WHEN count_avg > 10 THEN 'High'
		WHEN count_avg BETWEEN 5 AND 10 THEN 'Medium'
		WHEN count_avg < 5 THEN 'Low'
		ELSE 'Very Low'
	END AS probability
FROM summary
);

CREATE VIEW peak_rental_days AS 
SELECT DAYNAME(rental_date) AS rental_day, COUNT(*) AS rental_count
FROM rental 
GROUP BY rental_day
ORDER BY rental_count DESC;

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
WHERE fa.film_id IN (SELECT film_id FROM top10_film_by_rental_count);

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
ORDER BY rental_count DESC;

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
WHERE r.rental_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH);

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
ORDER BY rental_count DESC;

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
ORDER BY total_sale DESC;

CREATE VIEW  year_revenue AS 
SELECT YEAR(payment_date) AS year, SUM(amount) AS total_sales
FROM payment
GROUP BY year
ORDER BY year DESC;

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

DROP PROCEDURE IF EXISTS customer_late_fees;

DELIMITER $$

CREATE PROCEDURE customer_late_fees(
	customer_id INT
)
BEGIN
	SELECT 
		r.rental_id, 
		i.film_id, 
		f.title,
		r.rental_date, 
		r.return_date, 
		f.rental_duration, 
		DATEDIFF(r.return_date, r.rental_date) - f.rental_duration AS late,
		f.replacement_cost
	FROM rental r 
	JOIN inventory i 
		USING (inventory_id)
	JOIN film f 
		USING (film_id)
	WHERE DATEDIFF(r.return_date, r.rental_date) > f.rental_duration 
			AND r.customer_id = customer_id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS film_sales_probability;

DELIMITER $$

CREATE PROCEDURE film_sales_probability(
	film_id INT
)
BEGIN 
	WITH film_month_sale AS (
	SELECT 
		DATE_FORMAT(r.rental_date, '%Y-%m') AS month, 
		COUNT(*) AS sale_count
	FROM rental r 
	JOIN inventory i 
		USING (inventory_id)
	WHERE r.rental_date > DATE_SUB(CURDATE(), INTERVAL 3 MONTH) AND i.film_id = film_id
	GROUP BY month 
	),
	summary AS (
		SELECT 
			ROUND(AVG(sale_count),0) AS count_avg,
			(SELECT sale_count 
				FROM film_month_sale 
				ORDER BY month DESC
				LIMIT 1) AS last_month_count
		FROM film_month_sale 
	)
	SELECT 
		*,
		CASE
			WHEN count_avg > 10 THEN 'High'
			WHEN count_avg BETWEEN 5 AND 10 THEN 'Medium'
			WHEN count_avg < 5 THEN 'Low'
			ELSE 'Very Low'
		END AS probability
	FROM summary;
END$$

DELIMITER ;

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

DROP PROCEDURE IF EXISTS get_specefic_month_revenue;

DELIMITER $$

CREATE PROCEDURE get_specefic_month_revenue(
	month INT,
    year INT,
    OUT total_sale DECIMAL(6,2)
)
BEGIN 
	SELECT SUM(amount)
    INTO total_sale
	FROM payment 
	WHERE YEAR(payment_date) = year AND 
		MONTH(payment_date) = month;
END$$

DELIMITER ;

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

DROP FUNCTION IF EXISTS avg_rental_duration;

DELIMITER $$

CREATE FUNCTION avg_rental_duration(
	film_id INT
)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE avg_duration INT;
	SELECT AVG(DATEDIFF(r.return_date, r.rental_date))
    INTO avg_duration
	FROM rental r
	JOIN inventory i 
		USING (inventory_id)
	WHERE i.film_id = film_id;
    RETURN avg_duration;
END$$

DELIMITER ;

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

DROP FUNCTION IF EXISTS film_total_amount;

DELIMITER $$

CREATE FUNCTION film_total_amount(
	film_id INT
)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
	DECLARE film_total_amount DECIMAL(6,2);
	SELECT SUM(p.amount)
    INTO film_total_amount
	FROM payment p 
	LEFT JOIN rental r 
		USING (rental_id)
	JOIN inventory i 
		USING (inventory_id)
	WHERE i.film_id = film_id;
    RETURN film_total_amount;
END$$

DELIMITER ;
