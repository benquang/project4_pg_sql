/* I. Create table follow schema and populate data*/

/* Create table orders*/
CREATE TABLE IF NOT EXISTS orders (
            order_id SERIAL PRIMARY KEY,
            order_date TIMESTAMP NOT NULL,
            seller_id INT REFERENCES seller(seller_id),
            status VARCHAR(20) NOT NULL,
            total_amount DECIMAL(12,2) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* Insert data into orders with distribution status, random product_id*/
WITH status_pool AS (
    SELECT 'PLACED' AS status FROM generate_series(1, 5000*25)  -- 5%
    UNION ALL
    SELECT 'PAID' FROM generate_series(1, 4000*25)              -- 4%
    UNION ALL
    SELECT 'DELIVERED' FROM generate_series(1, 70000*25)        -- 70%
    UNION ALL
    SELECT 'SHIPPED' FROM generate_series(1, 11000*25)          -- 11%
    UNION ALL
    SELECT 'CANCELLED' FROM generate_series(1, 7000*25)         -- 7%
    UNION ALL
    SELECT 'RETURNED' FROM generate_series(1, 3000*25)          -- 3%
),
shuffled AS (
    SELECT status, row_number() OVER (ORDER BY random()) AS rn
    FROM status_pool
)
INSERT INTO orders (seller_id, order_date, total_amount, status)
SELECT 
    floor(random() * 25 + 1001)::int AS seller_id,   --

    DATE '2025-08-01'
        + (floor(random() * (DATE '2025-10-31' - DATE '2025-08-01'))) * interval '1 day' AS order_date,

    0 AS total_amount,

    status
FROM shuffled
ORDER BY rn;

/* Check distrubution status*/
SELECT status, COUNT(*) AS cnt,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY status
ORDER BY status;
