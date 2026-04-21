/* III. Making dynamic reports*/
/* Part 2 - Daily Revenue Report*/

-- Auto partition pruning and using index (product_id) when filter
CREATE OR REPLACE FUNCTION daily_revenue_report(
    start_date DATE,
    end_date DATE,
    product_list INT[]   -- list product_id
)
RETURNS TABLE (
    date DATE,
    total_orders BIGINT,
    total_quantity BIGINT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_date::DATE AS date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN start_date AND end_date
      AND oi.product_id = ANY(product_list)   -- filter with product_id list
    GROUP BY o.order_date::DATE
    ORDER BY date;
END;
$$;

SELECT * 
FROM daily_revenue_report('2025-08-01', '2025-08-31', ARRAY[20437, 21410, 20911]);
