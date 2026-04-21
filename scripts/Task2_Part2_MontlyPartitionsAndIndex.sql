/* II. Optimization techniques*/
/* Part 2 - Monthly partitions and index on product_id*/

/*Orders table ranges*/
CREATE TABLE IF NOT EXISTS orders_ranges (
            order_id SERIAL,
            order_date TIMESTAMP NOT NULL,
            seller_id INT REFERENCES seller(seller_id),
            status VARCHAR(20) NOT NULL,
            total_amount DECIMAL(12,2) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (order_date);

-- August 2025
CREATE TABLE orders_2025_08 PARTITION OF orders_ranges
FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

-- September 2025
CREATE TABLE orders_2025_09 PARTITION OF orders_ranges
FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

-- October 2025
CREATE TABLE orders_2025_10 PARTITION OF orders_ranges
FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');	

INSERT INTO orders_ranges (order_id, order_date, seller_id, status, total_amount, created_at)
SELECT *
FROM orders
WHERE order_id <=100000;

/*Order item table ranges*/
CREATE TABLE IF NOT EXISTS order_item_ranges (
            order_item_id SERIAL,
            order_id INT REFERENCES orders(order_id),
            product_id INT REFERENCES product(product_id),
	   		order_date TIMESTAMP NOT NULL,
            quantity INT NOT NULL,
            unit_price DECIMAL(12,2) NOT NULL,
            subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
	   		created_at TIMESTAMP NOT NULL
) PARTITION BY RANGE (order_date);

-- August 2025
CREATE TABLE order_item_2025_08 PARTITION OF order_item_ranges
FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

-- September 2025
CREATE TABLE order_item_2025_09 PARTITION OF order_item_ranges
FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

-- October 2025
CREATE TABLE order_item_2025_10 PARTITION OF order_item_ranges
FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

-- Add first 100000 order_id into order_item
INSERT INTO order_item_ranges (
    order_item_id,
    order_id,
    product_id,
    order_date,
    quantity,
    unit_price,
    created_at
)
SELECT
    order_item_id,
    order_id,
    product_id,
    order_date,
    quantity,
    unit_price,
    created_at
FROM order_item
WHERE order_id <= 100000;

CREATE INDEX idx_order_item_2025_08_product_id 
    ON order_item_2025_08(product_id);

CREATE INDEX idx_order_item_2025_09_product_id 
    ON order_item_2025_09(product_id);

CREATE INDEX idx_order_item_2025_10_product_id 
    ON order_item_2025_10(product_id);
