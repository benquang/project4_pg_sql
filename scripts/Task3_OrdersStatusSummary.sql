/* III. Making dynamic reports*/
/* Part 5 - Orders Status Summary*/

-- Auto partition pruning and using index (product_id, seller_id, category_id) when filter
CREATE OR REPLACE FUNCTION orders_status_summary(
    start_date DATE,
    end_date DATE,
    seller_list INT[] DEFAULT NULL,
    category_list INT[] DEFAULT NULL
)
RETURNS TABLE (
    status VARCHAR(20),
    total_orders BIGINT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.status,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND (seller_list IS NULL OR o.seller_id = ANY(seller_list))
      AND (category_list IS NULL OR p.category_id = ANY(category_list))
    GROUP BY o.status
    ORDER BY o.status;
END;
$$;

-- All sellers and categories
SELECT * 
FROM orders_status_summary('2025-08-01', '2025-10-31');

-- A specific list of sellers
SELECT * 
FROM orders_status_summary('2025-08-01', '2025-10-31', ARRAY[1017, 1015]);

-- A specific list of categories
SELECT * 
FROM orders_status_summary('2025-08-01', '2025-10-31', NULL, ARRAY[4, 5]);