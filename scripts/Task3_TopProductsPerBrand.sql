/* III. Making dynamic reports*/
/* Part 4 - Top products per Brand*/

-- Auto partition pruning and using index (product_id) when filter
CREATE OR REPLACE FUNCTION top_products_per_brand(
    start_date DATE,
    end_date DATE,
    seller_list INT[] DEFAULT NULL
)
RETURNS TABLE (
    brand_id INT,
    brand_name VARCHAR(150),
    product_id INT,
    product_name VARCHAR(150),
    total_quantity BIGINT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.brand_id,
        b.brand_name,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    JOIN product p ON oi.product_id = p.product_id
    JOIN brand b ON p.brand_id = b.brand_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND (seller_list IS NULL OR o.seller_id = ANY(seller_list))
    GROUP BY b.brand_id, b.brand_name, p.product_id, p.product_name
    ORDER BY b.brand_id, total_quantity DESC;
END;
$$;

-- All sellers from August to October 2025
SELECT * 
FROM top_products_per_brand('2025-08-01', '2025-10-31');

-- A specific list of seller
SELECT * 
FROM top_products_per_brand('2025-08-01', '2025-10-31', ARRAY[1015, 1017]);