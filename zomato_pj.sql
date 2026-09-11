SHOW databases;
CREATE DATABASE zomato_db;
USE zomato_db;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurents;
CREATE TABLE restaurants (
restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
restaurent_name VARCHAR(100) NOT NULL,
city VARCHAR(50),
opening_hours VARCHAR(50)
);
CREATE TABLE customers (
customer_id INT AUTO_INCREMENT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
reg_date DATE 
);
CREATE TABLE riders (
rider_id INT AUTO_INCREMENT PRIMARY KEY,
rider_name VARCHAR(100) NOT NULL,
sign_date DATE 
);
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_item VARCHAR(255),
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);
SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM riders;
SELECT * FROM deliveries;

SELECT COUNT(*) FROM customers
WHERE customer_id IS NULL
OR customer_name IS NULL
OR reg_date IS NULL  
;
SELECT COUNT(*) FROM restaurants
WHERE restaurant_id IS NULL
OR restaurent_name IS NULL
OR city IS NULL
OR opening_hours IS NULL
;
SELECT COUNT(*) FROM orders
WHERE order_id IS NULL
OR customer_id IS NULL
OR restaurant_id IS NULL
OR order_item IS NULL
OR  order_date IS NULL
OR  order_time IS NULL
OR  order_status IS NULL
OR  total_amount IS NULL
;
SELECT COUNT(*) FROM riders
WHERE rider_id IS NULL
OR rider_name IS NULL
OR sign_date IS NULL  
;
SELECT COUNT(*) FROM deliveries
WHERE delivery_id IS NULL
OR order_id IS NULL
OR delivery_status IS NULL
OR delivery_time IS NULL
OR rider_id IS NULL
;

SELECT *
FROM orders as o
JOIN customers as c
ON c.customer_id = o.customer_id ;

SELECT CURRENT_DATE - INTERVAL 2 Year;
SELECT 
	c.customer_id,
	c.customer_name,
	o.order_item as dishes,
	COUNT(*) as total_orders
FROM orders as o
JOIN customers as c
ON c.customer_id = o.customer_id
WHERE
	o.order_date >= CURRENT_DATE - INTERVAL 3 Year
    AND
    c.customer_name = 'Arjun Mehta'
GROUP BY 1, 2, 3
ORDER BY 1, 4 	DESC;

SELECT 
		c.customer_id,
		c.customer_name,
		o.order_item as dishes,
		COUNT(*) as total_orders,
		DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as 'rank'
	FROM orders as o
	JOIN
	customers as c
	ON c.customer_id = o.customer_id
	WHERE 
		o.order_date >= CURRENT_DATE - INTERVAL 3 Year
		AND 
		c.customer_name = 'Arjun Mehta'
	GROUP BY 1, 2, 3
	ORDER BY 1, 4 DESC;
    SELECT 
	customer_name,
	dishes,
	total_orders
FROM -- table name
	(SELECT 
		c.customer_id,
		c.customer_name,
		o.order_item as dishes,
		COUNT(*) as total_orders,
		DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as 'rank'
	FROM orders as o
	JOIN
	customers as c
	ON c.customer_id = o.customer_id
	WHERE 
		o.order_date >= CURRENT_DATE - INTERVAL 3 Year
		AND 
		c.customer_name = 'Arjun Mehta'
	GROUP BY 1, 2, 3
	ORDER BY 1, 4 DESC) as t1
WHERE 'rank' <= 5
;
SELECT 
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 as start_time,
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 + 2 as end_time,
	COUNT(*) as total_orders
FROM orders
GROUP BY 1, 2
ORDER BY 3 DESC;

SELECT
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slot,
    COUNT(order_id) AS order_count
FROM Orders
GROUP BY time_slot
ORDER BY order_count DESC;

SELECT
o.customer_id,
c.customer_name, 
AVG(o.total_amount) as aov
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
GROUP BY 1 
HAVING COUNT(order_id) > 750;

SELECT 
o.customer_id,
c.customer_name,
SUM(o.total_amount) as total_spent
FROM orders AS o
JOIN customers AS C
ON o.customer_id = c.customer_id
GROUP BY 1
HAVING SUM(o.total_amount) > 100000 ;

SELECT 
r.restaurent_name,
COUNT(o.order_id) AS cnt_not_deliver_orders
FROM orders AS o
JOIN restaurants AS r
ON o.restaurant_id = r.restaurant_id
LEFT JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_id IS NULL
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
	r.restaurent_name,
	COUNT(*)
FROM orders as o
LEFT JOIN 
restaurants as r
ON r.restaurant_id = o.restaurant_id
WHERE 
	o.order_id NOT IN (SELECT order_id FROM deliveries)
GROUP BY 1
ORDER BY 2 DESC;

WITH ranking_table AS
(
SELECT 
r.city,
r.restaurent_name,
SUM(o.total_amount) AS revenue,
RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS 'RANK'
FROM orders AS o
JOIN restaurants AS r
ON r.restaurant_id = o.restaurant_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL 2 YEAR
GROUP BY r.city, r.restaurent_name
ORDER BY r.city, 'RANK'
)
SELECT * FROM ranking_table	
WHERE 'RANK' = 1;

SELECT * FROM 
(SELECT
r.city,
o.order_item AS dish,
COUNT(order_id) AS total_orders,
RANK() OVER(PARTITION BY r.city ORDER BY COUNT(order_id) DESC) AS 'rank'
FROM orders AS o
JOIN restaurants AS r
ON r.restaurant_id = o.restaurant_id
GROUP BY 1, 2
) AS t1
WHERE 'rank' = 1;

SELECT DISTINCT customer_id FROM orders
WHERE
EXTRACT(YEAR FROM order_date) =2023
AND
customer_id NOT IN (SELECT DISTINCT customer_id FROM orders
WHERE
EXTRACT(YEAR FROM order_date) =2024);
	
# 9
WITH cancel_ratio_23 AS 
 (   SELECT 
o.restaurant_id,
COUNT(o.order_id) AS total_orders,
COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
FROM orders AS o
LEFT JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2023
GROUP BY 1 
),
cancel_ratio_24 AS 
 (   SELECT 
o.restaurant_id,
COUNT(o.order_id) AS total_orders,
COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
FROM orders AS o
LEFT JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
GROUP BY 1 
),
last_year_data AS
( SELECT
restaurant_id,
total_orders,
not_delivered,
ROUND(( not_delivered * 100.0) / total_orders, 2) AS cancel_ratio
FROM cancel_ratio_23
),
current_year_data AS
( SELECT
restaurant_id,
total_orders,
not_delivered,
ROUND(( not_delivered * 100.0) / total_orders, 2) AS cancel_ratio
FROM cancel_ratio_24
)
SELECT 
    c.restaurant_id AS restaurant_id,
    c.cancel_ratio AS current_year_cancel_ratio,
    l.cancel_ratio AS last_year_cancel_ratio
FROM current_year_data AS c
JOIN last_year_data AS l
ON c.restaurant_id = l.restaurant_id;

#10

SELECT 
    o.order_id,
    o.order_time,
    d.delivery_time,
    d.rider_id,
    TIMEDIFF(d.delivery_time, o.order_time) AS time_difference,
    (TIME_TO_SEC(TIMEDIFF(d.delivery_time, o.order_time)) + 
CASE 
	WHEN d.delivery_time < o.order_time THEN 86400  # after mid night 86400sec 
	ELSE 0
END
)/60 as time_difference_insec
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered';
# 11
WITH growth_ratio
AS
(
SELECT 
	o.restaurant_id,
	EXTRACT(YEAR FROM o.order_date) as year,
	EXTRACT(MONTH FROM o.order_date) as month,
	COUNT(o.order_id) as cr_month_orders,
	LAG(COUNT(o.order_id), 1) OVER(PARTITION BY o.restaurant_id ORDER BY EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date)) as prev_month_orders
FROM orders as o
JOIN
deliveries as d
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1, 2, 3
ORDER BY 1, 2
)
SELECT
	restaurant_id,
	month,
    year,
	prev_month_orders,
	cr_month_orders,
	ROUND(
	(cr_month_orders - prev_month_orders) * 100 / prev_month_orders,2)
	as growth_ratio
FROM growth_ratio;

# 12
SELECT 
	cx_category,
	SUM(total_orders) as total_orders,
	SUM(total_spent) as total_revenue
FROM

	(SELECT 
		customer_id,
		SUM(total_amount) as total_spent,
		COUNT(order_id) as total_orders,
		CASE 
			WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'Gold'
			ELSE 'silver'
		END as cx_category
	FROM orders
	group by 1
	) as t1
GROUP BY 1;

# 13
SELECT
	d.rider_id,
	DAYOFMONTH(o.order_date) month,
    SUM(total_amount) AS revenue,
    SUM(total_amount) * 0.08 AS riders_earning
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
GROUP BY 1, 2 
ORDER BY 1, 2 ;

# 14
SELECT 
	rider_id,
	stars,
	COUNT(*) as total_stars
FROM
(
	SELECT
		rider_id,
		delivery_took_time,
		CASE 
			WHEN delivery_took_time < 15 THEN '5 star'
			WHEN delivery_took_time BETWEEN 15 AND 20 THEN '4 star'
			ELSE '3 star'
		END as stars
		
	FROM
	(
		SELECT 
			o.order_id,
			o.order_time,
			d.delivery_time,
			TIMESTAMPDIFF(MINUTE, o.order_time,
CASE 
WHEN d.delivery_time < o.order_time 
THEN d.delivery_time + INTERVAL 1 DAY 
ELSE d.delivery_time END )
			 AS delivery_took_time,
			d.rider_id
		FROM orders as o
		JOIN deliveries as d
		ON o.order_id = d.order_id
		WHERE delivery_status = 'Delivered'
	) as t1
) as t2
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

# 15
SELECT * FROM
(
	SELECT 
		r.restaurent_name,
		-- o.order_date,
		DAYNAME(o.order_date) as day,
		COUNT(o.order_id) as total_orders,
		RANK() OVER(PARTITION BY r.restaurent_name ORDER BY COUNT(o.order_id)  DESC) as order_rank
	FROM orders as o
	JOIN
	restaurants as r
	ON o.restaurant_id = r.restaurant_id
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC
	) as t1
WHERE order_rank = 1;

# 16
SELECT 
		o.customer_id,
        c.customer_name,
        SUM(o.total_amount) AS CLV
FROM orders AS o
JOIN customers AS c
ON o.customer_id = c.customer_id
GROUP BY 1, 2;

SELECT 
	EXTRACT(YEAR FROM order_date) as year,
	EXTRACT(MONTH FROM order_date) as month,
	SUM(total_amount) as total_sale,
	LAG(SUM(total_amount), 1) OVER(ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) as prev_month_sale
FROM orders
GROUP BY 1, 2;
# 18

WITH new_table
AS
(
	SELECT 
		d.rider_id as riders_id,
		TIMESTAMPDIFF( SECOND, o.order_time, 
		CASE WHEN d.delivery_time < o.order_time THEN d.delivery_time + INTERVAL 1 day ELSE d.delivery_time END
		)/60 as time_deliver
	FROM orders as o
	JOIN deliveries as d
	ON o.order_id = d.order_id
	WHERE d.delivery_status = 'Delivered'
),
riders_time
AS
(
	SELECT 
		riders_id,
		AVG(time_deliver) avg_time
	FROM new_table
	GROUP BY 1
)
SELECT 
	MIN(avg_time) AS min_avg_time,
	MAX(avg_time) AS max_avg_time
FROM riders_time;

# 19
SELECT 
	order_item,
	seasons,
	COUNT(order_id) as total_orders
FROM 
(
SELECT 
		*,
		EXTRACT(MONTH FROM order_date) as month,
		CASE 
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 4 AND 6 THEN 'Spring'
			WHEN EXTRACT(MONTH FROM order_date) > 6 AND 
			EXTRACT(MONTH FROM order_date) < 9 THEN 'Summer'
			ELSE 'Winter'
		END as seasons
	FROM orders
) as t1
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

# 20
SELECT 
	r.city,
	SUM(total_amount) as total_revenue,
	RANK() OVER(ORDER BY SUM(total_amount) DESC) as city_rank
FROM orders as o
JOIN
restaurants as r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1;
