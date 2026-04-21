/* III. Making dynamic reports*/
/* Part 3 - Seller Performance Report*/

-- Auto partition pruning and using index (product_id, seller_id) when filter
CREATE OR REPLACE FUNCTION seller_performance_report(
    start_date DATE,
    end_date DATE,
    category_filter INT DEFAULT NULL,
    brand_filter INT DEFAULT NULL
)
RETURNS TABLE (
    seller_id INT,
    seller_name TEXT,
    total_orders BIGINT,
    total_quantity BIGINT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.seller_id,
        s.seller_name::TEXT,   -- into TEXT
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN seller s ON o.seller_id = s.seller_id
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND (category_filter IS NULL OR p.category_id = category_filter)
      AND (brand_filter IS NULL OR p.brand_id = brand_filter)
    GROUP BY s.seller_id, s.seller_name
    ORDER BY total_revenue DESC;
END;
$$;

-- ALL sellers
SELECT * 
FROM seller_performance_report('2025-08-01', '2025-08-31')

-- Filter by a category
SELECT * 
FROM seller_performance_report('2025-08-01', '2025-08-31', category_filter := 4);

-- Filter by a brand
SELECT * 
FROM seller_performance_report('2025-08-01', '2025-08-31', brand_filter := 20);
