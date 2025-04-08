CREATE VIEW peak_rental_days AS 
SELECT DAYNAME(rental_date) AS rental_day, COUNT(*) AS rental_count
FROM rental 
GROUP BY rental_day
ORDER BY rental_count DESC