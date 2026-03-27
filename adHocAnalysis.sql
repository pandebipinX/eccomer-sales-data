


-- CUSTOMERS
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INT,
    customer_city TEXT,
    customer_state TEXT
);	

-- ORDERS
CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES customers(customer_id),
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- ORDER ITEMS
CREATE TABLE order_items (
    order_id TEXT REFERENCES orders(order_id),
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC,
    PRIMARY KEY (order_id, order_item_id)
);

-- PRODUCTS
CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_category TEXT,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- SELLERS
CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city TEXT,
    seller_state TEXT
);

-- PAYMENTS
CREATE TABLE payments (
    order_id TEXT REFERENCES orders(order_id),
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC
);

-- GEOLOCATION
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city TEXT,
    geolocation_state TEXT
);

SELECT * FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id

SELECT * FROM order_items oi
LEFT JOIN products p
ON oi.product_id = p.product_id
JOIN payments pmt
ON oi.order_id = pmt.order_id


SELECT 
	((SUM(CASE
	    WHEN payment_installments >=1 THEN 1 
		ELSE 0
		END))/COUNT(order_id)::numeric)*100
FROM payments

SELECT 
	customer_state,
	COUNT(*) 
FROM customers
GROUP BY customer_state
ORDER 

SELECT o.product_id, AVG(p.payment_value) as price, COUNT(o.order_id) as purchase_count
FROM order_items o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.product_id


WITH total_sales AS (
SELECT 
	s.seller_id,
	SUM(o.price + o.freight_value) as sales
FROM order_items o
JOIN sellers s
ON o.seller_id = s.seller_id
GROUP BY s.seller_id

)

SELECT
	*,
	RANK() OVER(ORDER BY sales DESC) as top_sellers
FROM total_sales


SELECT 
	*,
	AVG(payment_value) OVER(PARTITION BY customer_id ORDER BY order_purchase_timestamp ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS moving_avg
FROM (
SELECT 
	customer_id,
	payment_value,
	order_purchase_timestamp
FROM orders o 
JOIN payments p
ON o.order_id = p.order_id
) as t

