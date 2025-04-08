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