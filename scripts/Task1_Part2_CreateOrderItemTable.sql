/* I. Create table follow schema and populate data*/

/* Create table order_item*/
CREATE TABLE IF NOT EXISTS order_item (
            order_item_id SERIAL PRIMARY KEY,
            order_id INT REFERENCES orders(order_id),
            product_id INT REFERENCES product(product_id),
	    	order_date TIMESTAMP NOT NULL,
            quantity INT NOT NULL,
            unit_price DECIMAL(12,2) NOT NULL,
            subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
	    	created_at TIMESTAMP NOT NULL
);

/* Each order contains between 3 to 4 products (belong to the same seller_id as the order),
random quantity from 1 to 5*/
INSERT INTO order_item (order_id, product_id, order_date, quantity, unit_price, created_at)
SELECT o.order_id,
       p.product_id,
       o.order_date,
       (floor(random() * 5) + 1) AS quantity,   -- 1-5
       pr.price AS unit_price,
       o.created_at
FROM orders o
JOIN LATERAL (
    SELECT product_id
    FROM product pr2
    WHERE pr2.seller_id = o.seller_id
    ORDER BY random()
    LIMIT (3 + floor(random() * 2))  -- random 3 to 4 products
) p ON TRUE
JOIN product pr ON p.product_id = pr.product_id;


/* Update total_amount orders*/
UPDATE orders o
SET total_amount = sub.sum_subtotal
FROM (
    SELECT oi.order_id, SUM(oi.subtotal) AS sum_subtotal
    FROM order_item oi
    GROUP BY oi.order_id
) sub
WHERE sub.order_id = o.order_id;
